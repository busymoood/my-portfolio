# myPortfolio

Site personnel **CV + portfolio + blog** — CV en LaTeX, portfolio de projets détaillés,
blog en Markdown. Anglais par défaut (racine `/`), français sous `/fr/`.
Déploiement : image Docker multi-arch + **Cloudflare Tunnel** (aucun port public).

> **Statut : Phases 0 à 4 terminées** — atelier agentique, squelette bilingue,
> contenus réels (3 fiches projet), blog (routage par langue, brouillons exclus
> du build) et CI multi-arch publiant l'image sur GHCR. Reste la Phase 5
> (qualité & lancement). Voir la table d'état de `docs/spec.md`.

## Prérequis

- [Docker](https://www.docker.com/) avec Docker Compose v2 (inclus avec Docker Desktop) — c'est tout.
- Aucun éditeur spécifique requis : le développement se fait **dans le container**, avec NeoVim/LazyVim de l'environnement.

## Dev container (principal)

La définition de l'image vit dans `.devcontainer/` (LaTeX + Node 22 + Python +
neovim stable + lazygit + opencode + gh + jq + Playwright/Chromium).

```sh
# 1) Construire l'image et démarrer le container de dev (première fois ≈ 10-20 min)
docker compose up -d --build

# 2) Entrer dedans
docker compose exec dev bash

# (rebuild d'image après toute modification du Dockerfile)
docker compose build dev
```

Le container démarre dans `/workspace` (le repo monté). Tu y es utilisateur `dev`.

### Outils disponibles dans le container

| Outil | Usage |
|---|---|
| `nvim` | NeoVim + **LazyVim** (config + plugins montés depuis `~/.config/nvim` et `~/.local/share/nvim` de l'hôte) |
| `lazygit` | Git TUI (config hôte montée) |
| `opencode` | Agent IA (config + auth montés depuis l'hôte) |
| `latexmk` | Compilation du CV |
| `node`, `npm` | Node LTS 22 — build du site |
| `python3` + `playwright` | Scripts des skills, audits web (browsers dans `/opt/ms-playwright`) |
| `gh` | GitHub CLI (Releases, CI) |
| `docker` | CLI Docker via socket hôte (build de l'image du site) |
| `jq` | Traitement JSON |

### NeoVim / LazyVim (première ouverture)

Ta config hôte est montée ; le **premier** `nvim` déclenchera `lazy.nvim` pour
installer / restaurer vos plugins (une fois, patientez ~1 min) :
```sh
nvim              # laisse la bootstrap finir
:Lazy             # état des plugins
```
`lazy-lock.json` et l'état des plugins vivent dans `~/.local/share/nvim` —
partagés avec l'hôte, mêmes versions des deux côtés ; mets à jour LazyVim
comme d'habitude (`:Lazy update`).

### OpenCode (agent)

```sh
cd /workspace && opencode
```
OpenCode lit automatiquement `AGENTS.md` (conventions du repo) et donne
l'accès aux skills projet (`skill-creator`, `frontend-design`, `webapp-testing`)
et aux commands :
| Commande | Effet |
|---|---|
| `/check` | Validation santé : lint + schémas de contenu + build + résumé OK/ERREURS |
| `/add-post <slug>` | Scaffold un billet de blog (brouillon par défaut) |
| `/add-project <slug>` | Scaffold une fiche projet (frontmatter complet) |

Un agent qui prend le relais : lire `.opencode/HANDOFF.md` (état + prochaines étapes).

## Travaux courants

### Compiler le CV en local (LaTeX)

```sh
# Build une fois (ou `make -C latex`, équivalent éditeur-agnostique)
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory=latex latex/my_cv.tex

# Watch continu (rebuild à chaque save)
latexmk -pvc -pdf -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory=latex latex/my_cv.tex
```
→ `latex/my_cv.pdf` (ignoré par git). `latexmk -C ...` pour nettoyer.
En CI, le workflow `deploy-pdf.yml` compile et **publie le PDF en GitHub Release**
(tag `cv-<n>`). La CI du site télécharge la dernière Release dans
`public/pdf/` avant le build — on ne commit jamais de PDF.

### Développement du site

```sh
npm ci
npm run dev        # http://localhost:4321 (port forwardé dans le dev container)
npm run lint       # astro check + validation des covers 16:9
npm run build      # build statique dans dist/
npm run preview    # sert dist/ en local
```

### Contenus

- **Projet** : `content/projects/<slug>/index.md` + une cover locale **16:9**
  (`cover.png`/`cover.jpg`), générée par
  `python3 scripts/cover/make_cover.py <slug>` à partir de
  `cover.json` (+ `cover-focal.html`/`.css` optionnels). L'aperçu mobile
  (`/tmp/opencode/cover-preview/<slug>-mobile.png`) permet de vérifier la
  lisibilité à 400 px. `/add-project <slug>` scaffolde le dossier et le
  frontmatter.
- **Billet** : `content/blog/<slug>.md`, avec `lang: "en" | "fr"`. Un billet
  vit sous une seule URL (`/blog/...` ou `/fr/blog/...`). `/add-post <slug>`
  crée un brouillon (`draft: true`) par défaut ; un brouillon est visible en
  `astro dev` mais exclu du build de production.
- Les fiches projet sont rédigées en anglais ; le repli « traduction à venir »
  est géré côté site pour le français.

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

La CI ne déploie pas. Le VPS tire l'image et la raccorde au réseau Docker du
tunnel Cloudflare existant : voir **[`deploy/README.md`](deploy/README.md)**.

```sh
export TUNNEL_NETWORK=cloudflared_default   # réseau du compose cloudflared
docker compose -f deploy/docker-compose.vps.yml pull
docker compose -f deploy/docker-compose.vps.yml up -d --no-build
```

Dans Cloudflare, le public hostname pointe vers `http://portfolio-web:80`.
Aucun port n'est exposé sur le VPS, et aucun `TUNNEL_TOKEN` n'est nécessaire.

## Conventions & ce qui est automatique

- `AGENTS.md` : règles de contenu (frontmatter obligatoire, LaTeX, bilinguisme),
  ce que les agents ne touchent pas sans validation. Lu par OpenCode au démarrage.
- Skills projet dans `.opencode/skills/`, commands dans `.opencode/commands/`.
- Commits **sans** artefacts : `latex/*.pdf/*.aux/*.log`, `node_modules`, `dist`,
  `.env` — tout est dans `.gitignore`.
- Ancien repo CV : `my-cv/` (backup local, ignoré par git — à supprimer quand
  le nouveau repo est publié).
