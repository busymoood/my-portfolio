# Déploiement du site sur un VPS

Le site est publié sous forme d'image multi-arch sur GitHub Container Registry
(GHCR) par le workflow `.github/workflows/site.yml`. **La CI ne déploie pas** :
le VPS tire l'image et la raccorde au réseau Docker du tunnel Cloudflare qui
tourne déjà sur la machine.

Il n'y a **ni jeton de tunnel ni `cloudflared` dans cette stack** : le
connecteur Cloudflare est géré séparément, et le site le rejoint par le réseau.

## Image

```text
ghcr.io/busymoood/my-portfolio:latest
ghcr.io/busymoood/my-portfolio:sha-<court>
```

- `latest` suit `main`.
- `sha-<court>` permet d'épingler un commit précis.
- Architectures : `linux/amd64` et `linux/arm64` (le tag sélectionne la bonne
  architecture automatiquement).

Le package GHCR doit être **public** (Settings → Packages → my-portfolio →
Change visibility), sinon la cible doit faire `docker login ghcr.io` avec un
PAT ayant le scope `read:packages`.

## Prérequis sur le VPS

- Docker Engine + le plugin Compose v2.
- Un tunnel Cloudflare déjà en place (compose `cloudflared`).
- Le **nom de son réseau Docker**.

## 1. Identifier le réseau du tunnel

```sh
docker network ls
# ou, dans le compose du tunnel :
grep -A5 '^networks:' docker-compose.yml
```

Exemples : `cloudflared_default` (réseau par défaut du projet) ou un nom
explicite comme `tunnel`.

## 2. Démarrer le site

```sh
export TUNNEL_NETWORK=cloudflared_default   # ← nom exact trouvé ci-dessus

docker compose -f deploy/docker-compose.vps.yml pull
docker compose -f deploy/docker-compose.vps.yml up -d --no-build
```

Le conteneur s'appelle `portfolio-web` et écoute sur le port 80, uniquement
sur le réseau du tunnel. Aucun port n'est publié sur l'hôte.

> Variante : tu peux mettre `TUNNEL_NETWORK=...` dans `deploy/.env` (ignoré par
> git) et ajouter `--env-file deploy/.env` aux commandes compose.

## 3. Déclarer le public hostname dans Cloudflare

Zero Trust → Networks → Tunnels → *ton tunnel* → Public Hostname :

| Champ | Valeur |
|---|---|
| Hostname | `ficaud.xyz` (puis `www` si tu veux) |
| Service | `HTTP` → `portfolio-web:80` |

Cloudflare termine le TLS au bord ; le conteneur reste en HTTP sur le réseau
interne.

## Tester avant de brancher le DNS

**A. Conteneur jetable** (le plus simple, sans le tunnel) :

```sh
docker run -d --name portfolio-test \
  -p 127.0.0.1:8080:80 \
  ghcr.io/busymoood/my-portfolio:latest

curl -I http://127.0.0.1:8080/
curl -I http://127.0.0.1:8080/cv
curl -I http://127.0.0.1:8080/pdf/my_cv.pdf
```

Puis, depuis ta machine :

```sh
ssh -L 8080:127.0.0.1:8080 user@vps
# → http://localhost:8080
```

**B. Avec la stack Compose** : ajouter un override local (non commité) qui
publie la loopback :

```yaml
# deploy/docker-compose.override.yml
services:
  web:
    ports:
      - "127.0.0.1:8080:80"
```

```sh
docker compose -f deploy/docker-compose.vps.yml \
               -f deploy/docker-compose.override.yml up -d --no-build
```

## Mise à jour

```sh
export TUNNEL_NETWORK=cloudflared_default
docker compose -f deploy/docker-compose.vps.yml pull
docker compose -f deploy/docker-compose.vps.yml up -d --no-build
```

## Dépannage

| Symptôme | Cause probable / solution |
|---|---|
| `network ... not found` | `TUNNEL_NETWORK` ne correspond à aucun réseau : vérifier `docker network ls`. |
| `denied` au `pull` | Package GHCR encore privé : le rendre public ou `docker login ghcr.io`. |
| Cloudflare répond 502 | Le site n'est pas joignable par le tunnel : vérifier que `portfolio-web` est bien sur le réseau (`docker network inspect "$TUNNEL_NETWORK"`). |
| `/cv` affiche « PDF généré par la CI » | Aucune Release `cv-*` n'existait au moment du build : lancer `deploy-pdf.yml`, puis relancer `site.yml`. |
| Mauvaise architecture | `docker inspect --format '{{.Architecture}}' ghcr.io/busymoood/my-portfolio:latest`. |

## Ce qu'il n'y a **pas** sur le VPS

- Pas de `cloudflared` supplémentaire : un seul tunnel, géré hors de cette stack.
- Pas de `TUNNEL_TOKEN` ni de secret Cloudflare dans ce compose.
- Pas de volume de développement (`nvim`, `lazygit`, `opencode`, socket Docker).
- Pas de build : l'image est construite par la CI.
- Pas de sources ni de `node_modules`.
