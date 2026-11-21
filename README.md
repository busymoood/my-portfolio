# myPortfolio

Site personnel **CV + portfolio + blog** — CV en LaTeX, portfolio de projets détaillés,
blog en Markdown. Site en anglais uniquement (racine `/`).
Déploiement : image Docker multi-arch + **Cloudflare Tunnel** (aucun port public).

> **Statut : Phases 0 à 4 terminées** — atelier agentique, squelette Astro,
> contenus réels (3 fiches projet), blog (routage par slug, brouillons exclus
> du build) et CI multi-arch publiant l'image sur GHCR. Reste la Phase 5
> (qualité & lancement). Voir la table d'état de `docs/spec.md`.

## Prérequis

- [Docker](https://www.docker.com/) avec Docker Compose v2 (inclus avec Docker Desktop) — c'est tout.
- Aucun éditeur spécifique requis : le développement se fait **dans le container**, avec NeoVim/LazyVim de l'environnement.

## Dev container (principal)

L'environnement est l'image publiée **`ghcr.io/busymoood/dotfiles-docker:main`**
(multi-arch) : Ubuntu 24.04 · NeoVim + LazyVim · tmux · zsh · lazygit ·
ripgrep/fd/fzf · opencode · jq · build-essential. Les configs zsh/tmux/NeoVim
sont **intégrées à l'image** : aucun clone ni dépôt de dotfiles au démarrage.
L'état des outils (plugins nvim, Mason, auth opencode, browsers Playwright)
persiste dans le volume `devbox-home`. **Ne pas configurer l'environnement à la
main** — suivre [`devbox-install-agents.md`](devbox-install-agents.md). Le surplus
propre au projet est posé par `scripts/devbox-bootstrap.sh` (appelée par
`postCreateCommand`/`postStartCommand`) : module Playwright + Chromium. Les
features du devcontainer ajoutent `node` 22, `gh` et la CLI Docker (features
épinglées dans `devcontainer-lock.json`, régénéré par la CLI devcontainers).

## Démarrage

```sh
# Démarrer le dev container (première fois : Playwright/Chromium ≈ quelques min)
devcontainer up --workspace-folder .

# Entrer dedans (zsh = shell par défaut ; flux normal : tmux → nvim)
devcontainer exec --workspace-folder . zsh

# Serveur de dev Astro : http://localhost:4321
devcontainer exec --workspace-folder . npm run dev

# Mise à jour : re-puller l'image puis recréer le conteneur
docker pull ghcr.io/busymoood/dotfiles-docker:main
devcontainer up --workspace-folder . --remove-existing-container
```

> La CLI réutilise l'image locale même si elle est périmée : faites `docker pull`
> avant `devcontainer up` (sinon : outils d'une version antérieure).

Le container démarre dans `/workspace` (le repo monté). Tu y es utilisateur
`dev`. Git sur GitHub passe via l'agent SSH de l'hôte (Bitwarden), exposé dans
le conteneur par `devbox-agent-relay` (helper de l'image) — aucune clé privée ne
vit dans le container. Sur **Docker Desktop** (un socket Unix non-docker ne peut
pas être monté), l'hôte relaie l'agent en TCP via socat (service launchd
`com.busymoood.socat-ssh-agent` sur 4242) et le helper recrée le socket local ;
sur **Docker natif** (Linux/WSL2), le socket est monté directement. Les configs
étant intégrées à l'image, un agent indisponible n'empêche pas le démarrage :
seules les opérations git nécessitent un agent déverrouillé. Le helper arme un
rattrapage : dès que les clés apparaissent (≤10 min), il rejoue `onstart` tout
seul. Manuellement :

```sh
# diagnostic (relais, socket, clés, configs, toolchain projet)
docker exec -it <conteneur> bash /workspace/scripts/devbox-bootstrap.sh doctor
# réarmer le relais + rejouer le bootstrap (après déverrouillage de Bitwarden)
docker exec -it <conteneur> bash /workspace/scripts/devbox-bootstrap.sh start
```

> `devcontainer up` sur un conteneur déjà démarré ne rejoue **pas**
> `postStartCommand` : pour repartir d'un cycle complet, recréer le container
> (`devcontainer up --remove-existing-container`). Le volume `devbox-home` est
> conservé.

### Outils disponibles dans le container

| Outil | Usage |
|---|---|
| `nvim` | NeoVim + **LazyVim** (config intégrée à l'image dans `~/.config/nvim`, état dans le volume `devbox-home`) |
| `tmux` | Multiplexeur (flux normal : tmux → nvim) |
| `lazygit` | Git TUI |
| `opencode` | Agent IA (auth persistée dans `devbox-home`) |
| `node`, `npm` | Node LTS 22 — feature `node` en dev container, installé dans le volume par `scripts/devbox-bootstrap.sh` en mode compose |
| `python3` + `playwright` | Scripts des skills, couvertures 16:9 (browsers dans `~/.local/ms-playwright`, volume persistant) |
| `gh` | GitHub CLI (Releases, CI) — **dev container uniquement** |
| `docker` | CLI Docker via socket hôte (build de l'image du site) — **dev container uniquement** |
| `rg`, `fd`, `fzf`, `jq` | Recherche et traitement |

Côté NeoVim : dictionnaires spell `fr` + `en` déjà installés (aucun prompt),
binaire **Supermaven** + clé API persistés dans `devbox-home` (authentification
une seule fois via `:SupermavenUsePro` / `:SupermavenUseFree`).

Le CV n'est **pas** compilé en local dans le container : uniquement dans la CI
(`deploy-pdf.yml`, règle AGENTS.md) ; le site télécharge le PDF de la dernière
GitHub Release.

## Travaux courants

### Compiler le CV (LaTeX)

Le PDF est compilé **uniquement dans la CI** (règle AGENTS.md) :

- le workflow `deploy-pdf.yml` compile et **publie le PDF en GitHub Release**
  (tag `cv-<n>`) ;
- la CI du site télécharge la dernière Release dans `public/pdf/` avant le
  build — on ne commit jamais de PDF.

Le container de dev n'embarque pas de toolchain LaTeX ; pour itérer sur le
contenu, éditer `latex/my_cv.tex` et pousser (ou tester ailleurs avec le
`Makefile` de `latex/` si l'hôte a déjà texlive — jamais de `.pdf` commité).

### Développement du site

```sh
npm ci
npm run dev        # http://localhost:4321 (port forwardé dans le dev container)
npm run lint       # astro check + validation des covers 16:9
npm run build      # build statique dans dist/
npm run preview    # sert dist/ en local
```

### CI & image

À chaque push sur `main`, `.github/workflows/site.yml` :

1. lance le lint ;
2. construit l'image **amd64 + arm64** sur runners natifs ;
3. télécharge `my_cv.pdf` depuis la dernière Release `cv-*` ;
4. smoke-teste l'image amd64 ;
5. publie le manifeste sur GHCR.

```text
ghcr.io/busymoood/my-portfolio:latest
ghcr.io/busymoood/my-portfolio:sha-<court>
```

Le package doit être **public** (sinon `docker login ghcr.io` sur la cible).
Le workflow se relance aussi à la fin de `deploy-pdf.yml` pour embarquer le
PDF fraîchement publié.

### Déploiement VPS

La CI ne déploie pas : le VPS fait tourner **deux stacks Docker Compose**
reliées par un réseau Docker — voir **[`deploy/README.md`](deploy/README.md)**.

1. la **stack du tunnel** : un compose `cloudflared` dédié (hors de ce repo)
   crée et gère le tunnel Cloudflare ;
2. la **stack du site** (image GHCR) rejoint le **réseau Docker** de ce
   compose : c'est le « tunnel network » — aucun `TUNNEL_TOKEN`, aucun port
   publié sur l'hôte.

```sh
docker network ls | grep cloudflared        # repérer le réseau, ex. cloudflared_default

export TUNNEL_NETWORK=cloudflared_default   # réseau du compose cloudflared
docker compose -f deploy/docker-compose.vps.yml pull
docker compose -f deploy/docker-compose.vps.yml up -d --no-build
```

Dans le dashboard Cloudflare (Zero Trust → Networks → Tunnels → Public
Hostname), **Service** = `HTTP` → `http://portfolio-web:80` : le port doit
être celui sur lequel écoute le conteneur (80 pour l'image nginx de prod ;
si le site écoute sur un autre port, reporter ce port ici).
