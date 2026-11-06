# HANDOFF — Note pour l'agent qui prend le relais dans le dev container

Bonjour collègue. Tu prends la suite dans l'environnement normé du projet.
Lis ceci AVANT de commencer, puis acte-toi des conventions de `AGENTS.md`
(lu automatiquement au démarrage).

## Où tu en es

- **Spécifications** : v0.4 validées — voir la spec du projet (CV + portfolio
  + blog, bilingue EN défaut `/` + FR `/fr/`, thème terminal propre façon
  NeoVim, Astro statique, Docker + Cloudflare Tunnel).
- **Phase 0 réalisée et committée** (init git local, branche `main`, pas de
  remote — le repo distant sera créé par Julien sous un nom genre `myPortfolio`).
- **Existant hérité de l'ancien repo CV** : `latex/my_cv.tex` (CV EN, template
  Harshibar MIT), `.github/workflows/deploy-pdf.yml` (CI : build PDF → GitHub
  Release tag `cv-<n>`), `.vscode/tasks.json` (latexmk), `.devcontainer/` (tu
  y es).

## Environnement du container (tu y es)

- Ubuntu 24.04 + **Node LTS 22** + Python 3 (scripts des skills) + toolchain
  **LaTeX/latexmk** + **neovim** (stable) + **lazygit** + **opencode** (npm).
- Configs montées depuis l'hôte : `~/.config/nvim` + `~/.local/share/nvim`
  (LazyVim de Julien), `~/.config/lazygit`, OpenCode `~/.config/opencode` +
  `~/.local/share/opencode` (auth à l'hôte).
- Outils : `nvim`, `lazygit`, `opencode`, `latexmk`, `node`, `npm`.

## Ce qui t'attend : la Phase 1 « Squelette »

Objectif : site Astro navigable avec contenus factices, build vert.

1. `npm create astro@latest . -- --template minimal` (ou écrire les fichiers à
   la main, plus contrôlé) — **jamais** par-dessus les dossiers existants
   (`latex/`, `content/`, `cv/`, `.opencode/`).
2. Content Collections avec **schémas zod** stricts pour `projects` (frontmatter
   : `title, summary, status, period, languages, repo, demo, cover`) et `blog`
   (`title, date, tags, summary, draft`) — voir `AGENTS.md` « Règles de contenu ».
3. Layouts + navigation (header : `CV · Projets · Blog` + sélecteur FR/EN) et
   **design tokens CSS** (fond sombre profond, texte doux, UNE couleur d'accent
   cyan/bleu ou vert doux, mono pour titres/tags, sans-serif pour le corps).
   La skill `frontend-design` (dispo via le tool `skill`) est là pour ça.
4. Pages vides mais routées : `/`, `/cv`, `/projects`, `/blog`, `/404`.
5. Scripts npm : `build` au minimum, `lint` si facile.

## Règles de sécurité (rappel AGENTS.md)

- NE Touche JAMAIS à : `.github/workflows/`, `docker-compose.yml` (prod),
  `Dockerfile`, `nginx.conf`, tout `.env` — sans validation explicite de Julien.
- Billets : jamais de `draft: false` sans son accord.
- Un frontmatter invalide doit casser le build avec un message CLAIR (zod) —
  c'est voulu, c'est ce qui rend le pipeline agentique fiable.

## Comment vérifier ton travail

Command OpenCode `/check` (dans `.opencode/commands/check.md`) : lint +
validation des schémas + build + résumé OK/AVERTISSEMENTS/ERREURS. Exécute-la
avant chaque fin de tâche et avant tout commit.
