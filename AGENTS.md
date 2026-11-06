# AGENTS.md — Conventions du projet « myPortfolio » (ex-my-cv)

Site personnel : **CV + portfolio de projets + blog**, en anglais (défaut, racine `/`)
et français (`/fr/`). Public cible : recruteurs ET pairs. Style : « terminal propre »
inspiré des thèmes NeoVim (fond sombre, mono pour les accents, sobre).

Spécifications complètes : **`docs/spec.md`** (versionnée avec le repo, tenue à
jour au fil des phases — la table « État du projet » en tête fait foi).
**Agent qui démarre ici : lire d'abord `.opencode/HANDOFF.md`.**

## Structure du repo

```text
latex/                      # CV en LaTeX (source de vérité du PDF)
  my_cv.tex                 #   template Harshibar (MIT), adapté — EN (défaut)
  my_cv_fr.tex              #   variante FR (optionnelle — repli EN)
.github/workflows/
  deploy-pdf.yml            # CI existante : build PDF → GitHub Release (tag cv-<n>)
  site.yml                  # CI du site (Phase 4) : image → GHCR → deploy VPS
content/
  projects/<slug>/index.md  # une fiche par projet + captures
  blog/<slug>.md            # un fichier par billet
src/
  pages/ components/ styles/
public/pdf/                 # PDF du CV (téléchargé de la Release en CI, jamais commité)
.opencode/                  # config OpenCode, skills (skill-creator…), commands
.devcontainer/
  devcontainer.json Dockerfile
latex/Makefile             # build/watch/clean latexmk
Dockerfile nginx.conf                      # site : build + runtime
docker-compose.yml                         # dev container local
deploy/docker-compose.vps.yml              # déploiement VPS (image GHCR, réseau du tunnel existant)
```

## Règles de contenu (non négociables)

1. **Un billet de blog = `content/blog/<slug>.md`**, frontmatter obligatoire :
   `title`, `lang` (`en`|`fr`), `date` (ISO `YYYY-MM-DD`), `tags`, `summary`,
   `draft`.
   - **Un billet = une langue = une URL** : `en` sous `/blog/<slug>`, `fr` sous
     `/fr/blog/<slug>` ; pas de duplication. L'index de l'autre langue affiche
     un repli « traduction à venir » avec un lien vers la version d'origine.
   - Nouveau billet = `draft: true` par défaut ; ne jamais passer à `draft: false`
     sans l'accord explicite de Julien.
   - Les brouillons sont visibles en `astro dev` (badge) et **exclus du build de
     production** (ni index, ni page).
   - Le slug est en kebab-case, stable après publication (ne pas renommer un slug
     publié — les URLs sont maintenues).
2. **Une fiche projet = `content/projects/<slug>/index.md`**, frontmatter
   obligatoire : `title`, `summary` (une ligne), `status` (`actif`|`archive`),
   `period`, `languages` (tableau), `repo` (URL GitHub), `demo` (URL ou null),
   `cover` (image locale 16:9, dark mode).
   - Page = description détaillée libre : contexte, ce que ça fait, choix
     techniques, captures insérées au fil du texte.
3. **Le CV est en LaTeX** (`latex/my_cv.tex`). Ne jamais produire une version HTML du
   CV complet (double maintenance interdite) ; la page `/cv` du site est un résumé
   court + bouton de téléchargement du PDF.
4. **Bilinguisme** : textes d'interface en FR et EN (fichiers de traduction).
   Contenus FR/EN avec repli propre autorisé (« traduction à venir »), plutôt que
   de produire des traductions bâclées.
5. **LaTeX** : le PDF du CV est compilé uniquement dans la CI (workflow
   `deploy-pdf.yml`, action texlive). Ne jamais commiter un `.pdf` généré.
   Le site télécharge le PDF de la dernière GitHub Release — pas de recompilation
   dans la CI du site.

## Règles de build

- Étapes, dans l'ordre : `npm ci` → compilation LaTeX via la CI → `npm run build`.
- Scripts spécifiques (lint/check) : voir `package.json`.
- Le build DOIT rester vert : un frontmatter invalide doit échouer au build avec
  un message clair (validation zod), c'est voulu.

## Ce qu'un agent ne touche pas sans validation

- `.github/workflows/` (CI : PDF du CV, image du site, déploiement),
- `docker-compose.yml`, `deploy/docker-compose.vps.yml` (déploiement), `Dockerfile`, `nginx.conf`
  — jeton de tunnel, secrets, configuration réseau.
- Tout `.env` (jamais commité par ailleurs : `.gitignore`).
- Les conventions de ce fichier — proposer les changements dans la conversation.

## Style visuel — rappel

- Dark mode par défaut ; fond sombre profond, texte doux (pas de blanc pur).
- Une seule couleur d'accent (cyan/bleu ou vert doux) ; mono pour titres/tags/
  métadonnées/prompt décoratif, sans-serif lisible pour le corps de texte.
- Interdits : effets CRT/scanlines, animations « machine à écrire », faux shell
  interactif, surcharge technique.
