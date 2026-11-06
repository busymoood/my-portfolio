# Déploiement du site sur un VPS

Le site est publié sous forme d'image multi-arch sur GitHub Container Registry
(GHCR) par le workflow `.github/workflows/site.yml`. **La CI ne déploie pas** :
le VPS tire l'image et exécute la stack `deploy/docker-compose.vps.yml`.

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
- Rien d'autre : ni Node, ni le repo, ni les sources.

## Déploiement avec le tunnel géré par cette stack

```sh
# 1. Récupérer l'image
docker compose -f deploy/docker-compose.vps.yml pull

# 2. Créer deploy/.env avec le jeton du tunnel
#    TUNNEL_TOKEN=<jeton>

# 3. Démarrer le site + cloudflared
docker compose --env-file deploy/.env \
  -f deploy/docker-compose.vps.yml --profile tunnel up -d

# 4. Vérifier
docker compose -f deploy/docker-compose.vps.yml logs -f web
```

Dans le dashboard Cloudflare, l'ingress du tunnel doit pointer vers
`http://web:80`.

## Déploiement si un tunnel existe déjà sur le VPS

Si un `cloudflared` tourne déjà (hors de cette stack), ne pas utiliser le
profil `tunnel`. Il faut alors publier le site sur la loopback et pointer
l'ingress existant vers `http://127.0.0.1:8080` :

```yaml
# deploy/docker-compose.override.yml — local au VPS, non commité
services:
  web:
    ports:
      - "127.0.0.1:8080:80"
```

```sh
docker compose -f deploy/docker-compose.vps.yml \
               -f deploy/docker-compose.override.yml up -d --no-build
```

## Tester avant de brancher le tunnel

Deux options, sans exposer de port public :

**A. Conteneur jetable**

```sh
docker run -d --name portfolio-test \
  -p 127.0.0.1:8080:80 \
  ghcr.io/busymoood/my-portfolio:latest

curl -I http://127.0.0.1:8080/
curl -I http://127.0.0.1:8080/cv
curl -I http://127.0.0.1:8080/pdf/my_cv.pdf
```

**B. Override Compose** (voir le snippet ci-dessus), puis `up -d --no-build`.

Depuis ta machine, ouvre un tunnel SSH pour regarder le site sans exposer
le port :

```sh
ssh -L 8080:127.0.0.1:8080 user@vps
# → http://localhost:8080
```

## Mise à jour

Sans tunnel :

```sh
docker compose -f deploy/docker-compose.vps.yml pull
docker compose -f deploy/docker-compose.vps.yml up -d --no-build
```

Avec le tunnel géré par la stack :

```sh
docker compose --env-file deploy/.env \
  -f deploy/docker-compose.vps.yml --profile tunnel pull
docker compose --env-file deploy/.env \
  -f deploy/docker-compose.vps.yml --profile tunnel up -d --no-build
```

## Dépannage

| Symptôme | Cause probable / solution |
|---|---|
| `denied` au `pull` | Package GHCR encore privé : le rendre public ou `docker login ghcr.io`. |
| `/cv` affiche « PDF généré par la CI » | Aucune Release `cv-*` n'existait au moment du build : lancer `deploy-pdf.yml`, puis relancer `site.yml`. |
| Le site répond mais pas le tunnel | Vérifier l'ingress `http://web:80` et `docker compose ... logs cloudflared`. |
| Image amd64 sur un hôte arm64 | Vérifier `docker inspect --format '{{.Architecture}}' ghcr.io/busymoood/my-portfolio:latest`. |

## Ce qu'il n'y a **pas** sur le VPS

- Pas de volume de développement (`nvim`, `lazygit`, `opencode`, socket Docker).
- Pas de build : l'image est construite par la CI.
- Pas de sources ni de `node_modules`.
