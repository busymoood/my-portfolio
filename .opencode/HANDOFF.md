# HANDOFF — Note pour l'agent qui prend le relais dans le dev container

Bonjour collègue. Tu prends la suite dans l'environnement normé du projet.
Lis ceci AVANT de commencer, puis acte-toi des conventions de `AGENTS.md`
(lu automatiquement au démarrage).

## Où tu en es

- **Spécifications** : v0.4 validées, versionnées dans le repo — **`docs/spec.md`**
  (CV + portfolio + blog, bilingue EN défaut `/` + FR `/fr/`, thème terminal
  propre façon NeoVim, Astro statique, Docker + Cloudflare Tunnel).
  **La table « État du projet » en tête de la spec fait foi sur l'avancement** ;
  la mettre à jour à chaque fin de phase.
- **Phase 0 réalisée et committée** (init git local, branche `main`, pas de
  remote — le repo distant sera créé par Julien sous le nom `myPortfolio`).
- **Existant hérité de l'ancien repo CV** : `latex/my_cv.tex` (CV EN, template
  Harshibar MIT), `.github/workflows/deploy-pdf.yml` (CI : build PDF → GitHub
  Release tag `cv-<n>`), `.vscode/tasks.json` (latexmk), `.devcontainer/` (tu
  y es).

## Environnement du container (tu y es)

- Ubuntu 24.04 + **Node LTS 22** + Python 3 (scripts des skills) + toolchain
  **LaTeX/latexmk** + **neovim** (dernière stable) + **lazygit** (latest au build)
  + **opencode** (npm `@latest`).
- **Outils agent** : **CLI Docker** (via socket hôte monté — tu peux builder
  l'image du site), **gh** (GitHub CLI : Releases du PDF, estado de la CI),
  **jq**, **Playwright + Chromium** (browsers partagés dans /opt/ms-playwright
  — pour la skill `webapp-testing` et les audits Phase 5).
- Configs montées depuis l'hôte : `~/.config/nvim` + `~/.local/share/nvim`
  (LazyVim de Julien), `~/.config/lazygit`, OpenCode `~/.config/opencode` +
  `~/.local/share/opencode` (auth de l'hôte).
- Outils en ligne : `nvim`, `lazygit`, `opencode`, `latexmk`, `node`, `npm`,
  `python3`, `playwright`, `gh`, `docker`, `jq`.

## Ce qui t'attend : la Phase 1 « Squelette »

**Statut : réalisée (voir la table d'état de `docs/spec.md`).** Les pages, layouts,
tokens, collections et contenus factices sont en place ; la Phase 2 démarre ci-dessous.
Historique de ce que la Phase 1 devait couvrir, si besoin de comprendre le squelette :

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

## La matière de la Phase 2 : les 3 projets du portfolio

Les fiches portfolio seront créées avec `/add-project`. Seed validé par Julien —
à approfondir en lisant chaque repo (README complet, `doc/`, CHANGELOG, workflows,
historique git) AVANT d'écrire la fiche. Rédaction **EN**, description détaillée,
pas de paraphrase naïve du README :

1. **`github.com/ficaud/relic-core`** — Firmware ESP32 (Zephyr RTOS v4.5, C) :
   *Shamir's Secret Sharing* GF(2⁸), 3-de-5 parts, 100 % offline (AP Wi-Fi +
   portail web captif), QR codes (génération Nayuki réduite + décodage via ses
   forks `relic-quirc` / `relic-zxing-cpp`), web flasher navigateur, démo WASM
   sur GitHub Pages. CI build + coverage. 201 commits, GPL-3.0.
   Demo : `https://ficaud.github.io/relic-core/`
2. **`github.com/ficaud/relic-hw`** — Docs MkDocs (GitHub Pages) : guide pas-à-pas
   pour débutants construisant le boîtier Relic physique. **Lien croisé** avec la
   fiche relic-core. Python/MkDocs + CI Pages. 54 commits.
   Demo : `https://ficaud.github.io/relic-hw`
3. **`github.com/ficaud/Ovalbot`** — App production en service sur Raspberry Pi
   arm64 : Rust/Axum + SvelteKit + SQLite. Surveille le TOP14 (dates de matchs +
   revente), notifie via Resend + bot Telegram, coffre de credentials boutique
   (AES-256-GCM/HKDF), scanner/checkout en Phases, waitlist à 10 personnes.
   Multi-arch arm64/amd64. 135 commits, CI ci/deploy + codecov. GPL-3.0.
   Demo : `https://ovalbot.ficaud.xyz/`

Captures 16:9 dark mode : les projets embarquent des images (doc/img/, frontend
static) et les démos en ligne sont visibles — capturer soi-même plutôt que de
stocker à la hâte.

## Comment vérifier ton travail

Command OpenCode `/check` (dans `.opencode/commands/check.md`) : lint +
validation des schémas + build + résumé OK/AVERTISSEMENTS/ERREURS. Exécute-la
avant chaque fin de tâche et avant tout commit.
