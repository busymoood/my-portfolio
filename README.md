# myPortfolio *(repo local : `my-cv`)*

Site personnel **CV + portfolio + blog** — CV en LaTeX, portfolio de projets détaillés,
blog en Markdown. Anglais par défaut (racine `/`), français sous `/fr/`.
Déploiement : image Docker + **Cloudflare Tunnel** (aucun port public).

> 🚧 **Statut : Phase 1 terminée** — l'atelier (dev container + skills + commands)
> et le squelette Astro bilingue du site sont en place. Pour la suite, lire
> `.opencode/HANDOFF.md` et la table d'état de `docs/spec.md`.

## Prérequis

- [Docker](https://www.docker.com/) avec Docker Compose v2 (inclus avec Docker Desktop) — c'est tout.
- Aucun éditeur spécifique requis : le développement se fait **dans le container**, avec NeoVim/LazyVim de l'environnement.

## Dev container (principal)

La définition de l'image vit dans `.devcontainer/` (LaTeX + Node 22 + Python +
neovim stable + lazygit + opencode + gh + jq + Playwright/Chromium).

```sh
# 1) Construire l'image et démarrer le container de dev (première fois ≈ 10-20 min)
docker compose --profile dev up -d --build

# 2) Entrer dedans
docker compose --profile dev exec dev bash

# (rebuild d'image après toute modification du Dockerfile)
docker compose --profile dev build dev
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
(tag `cv-<n>`) — le site téléchargera la dernière Release, on ne commit jamais de PDF.

### Build du site

```sh
# Build du site (Phase 1) : npm ci && npm run build
# Image de prod (Phase 4) :
docker compose --profile prod build web
```

### Site en prod (VPS + tunnel)

```sh
# sur le VPS, avec un .env contenant TUNNEL_TOKEN=<jeton cloudflared>
docker compose --profile prod up -d
```

## Conventions & ce qui est automatique

- `AGENTS.md` : règles de contenu (frontmatter obligatoire, LaTeX, bilinguisme),
  ce que les agents ne touchent pas sans validation. Lu par OpenCode au démarrage.
- Skills projet dans `.opencode/skills/`, commands dans `.opencode/commands/`.
- Commits **sans** artefacts : `latex/*.pdf/*.aux/*.log`, `node_modules`, `dist`,
  `.env` — tout est dans `.gitignore`.
- Ancien repo CV : `my-cv/` (backup local, ignoré par git — à supprimer quand
  le nouveau repo est publié).
