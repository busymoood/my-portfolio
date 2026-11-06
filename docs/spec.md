# Spécifications — Site Web Personnel (CV + Portfolio + Blog)

**Version :** 0.4
**Date :** 2026-11-06

**État du projet** — table tenue à jour par les agents à la fin de chaque phase ; en cas de divergence, cette table fait foi sur l'avancement (le reste du document décrit le produit, pas le planning) :

| Phase | État | Détail |
|---|---|---|
| 0 — Atelier agentique | ✅ Réalisée | Init git local (`main`, sans remote), devcontainer + `.opencode/` (skills, commands, AGENTS.md), CI PDF existante migrée |
| 1 — Squelette | ✅ Réalisée | Astro navigable bilingue (`/` + `/fr/`), pages `cv`/`projects`/`blog`/`404`, layouts + design tokens Kanagawa, collections zod strictes, contenus factices (2 projets placeholder + 2 billets brouillon), lint + build verts |
| 2 — Contenus réels | ✅ Réalisée | 3 fiches EN (relic-core, Ovalbot, Relic Hardware Guide) avec couvertures 16:9 dark, ordre éditorial sur `/projects`, repli « traduction à venir » sur `/fr` ; CV LaTeX conservé tel quel (pas de variante FR) |
| 3 — Blog | ✅ Réalisée | Billets routés par langue (une URL par billet), brouillons exclus du build de production (404 en prod, visibles en dev), extraits dans l'index, état vide et repli inter-langue ; blog vide au lancement |
| 4 — Infra | ✅ Réalisée | `site.yml` : lint, build **amd64 + arm64** sur runners natifs, smoke test avant publication, merge du manifeste et push GHCR (package public) ; PDF téléchargé de la dernière Release `cv-*` (repli si absente) ; page `/cv` sans lien mort ; compose aligné sur l'image publiée. Pas de job de déploiement : la cible tire l'image et gère son tunnel. |
| 5 — Qualité & lancement | ⏳ À faire | Audits, 404, sitemap, tunnel en prod, DNS `ficaud.xyz` |

Remote : `busymoood/my-portfolio` (origine existante conservée). Voir §7 pour le détail des phases.

---

## 1. Vision & objectifs

Le site est la **présence en ligne unique** de Julien Fichet. Il sert deux audiences simultanées :

| Audience | Ce qu'elle vient chercher |
|---|---|
| **Recruteurs** | Parcours, compétences, preuves de savoir-faire, moyen de contacter |
| **Pairs** | Projets personnels, qualité technique, ce que je construis |

**Principe directeur :** simplicité. Le contenu est la star ; le site se doit d'être sobre, vite, et évident à parcourir. Pas d'ornement décoratif, pas de parcours compliqué.

**Critères de succès (mesurables) :**
- Un recruteur comprend en < 10 secondes qui je suis et ce que je fais (page d'accueil).
- Navigation claire : n'importe quelle page accessible en ≤ 2 clics depuis l'accueil.
- Temps de chargement initial < 2 s sur connexion mobile raisonnable (site statique).
- Score Lighthouse ≥ 90 sur Performance, Accessibilité et SEO de base.

---

## 2. Périmètre fonctionnel

### 2.1 Carte du site

```
/                      → Accueil (présentation courte + points d'entrée)
/cv                    → Page CV : résumé court + téléchargement du PDF (LaTeX compilé en CI)
/projects              → Portfolio : grille/liste des projets
/projects/<slug>       → Fiche détaillée d'un projet
/blog                  → Index des billets (vide au lancement)
/blog/<slug>           → Billet de blog
/404                   → Page introuvable (style terminal : commande non trouvée)
/contact (footer)      → Modalités de contact : email, LinkedIn, GitHub
```

### 2.2 Navigation

- **Header fixe, minimaliste** : logo/titre (gauche) — liens `CV · Projets · Blog` (droite) + sélecteur de langue FR/EN.
- **Footer** : liens de contact (email, GitHub, LinkedIn), mention légale/copyright, langue.
- Fil d'Ariane léger sur les pages de détail (projet, billet) pour revenir à l'index.
- Mobilité : les liens se replient dans un menu burger simple si nécessaire (3 liens suffisent — on peut aussi rester en header compact sans burger).

### 2.3 Pages — description détaillée

**Accueil (`/`)**
- H1 : nom + phrase d'accroche (qui je suis / ce que je fais, orientée double audience).
- Court paragraphe de présentation (3-4 lignes max). **Sans photo/avatar** — présentation purement typographique.
- 2-3 appels à l'action : « Voir mon CV », « Explorer mes projets ».
- Optionnel : mise en avant des 3 derniers projets (cartes).

**CV (`/cv`)**
- **Source de vérité = fichier LaTeX** (`cv/cv-en.tex`), maintenu à la main et versionné dans le repo. Le PDF est **compilé dans la CI** (GitHub Actions, step sur image TeX Live) à chaque build → le PDF servi sur le site reflète toujours la source.
- **Page HTML légère** (pas de copie complète du CV en HTML — double maintenance interdite) : 2-3 points clés en résumé, gros bouton « Télécharger le CV (PDF) », date de dernière mise à jour.
- **Langues** : PDF **EN par défaut** (langue du site) ; variante FR compilée par le même step si `cv-fr.tex` fourni, repli EN sinon.
- Date de mise à jour affichée (métadonnée du LaTeX).

**Portfolio (`/projects`)**
- Liste/grille de projets avec, par carte : nom, résumé d'une ligne, langages principaux, capture d'écran (si dispo), statut.
- Tri par défaut : pertinence/ordre voulu (pas nécessairement chronologique).

**Fiche projet (`/projects/<slug>`)**
- Contenu écrit **manuellement** : un fichier Markdown par projet.
- Titre, description détaillée, contexte/motivation, stack technique, défis/points notables.
- Liens : repo GitHub, démo éventuelle, captures d'écran.
- Bloc « métadonnées » en tête de fiche : statut (actif/archivé), période, langages principaux, repo URL.

**Blog (`/blog`, `/blog/<slug>`)**
- Index : liste des billets par date (titre, date, éventuels tags, extrait).
- **Au lancement : la section est vide** — la page affiche un état propre (« Billets à venir » ou liste vide discrète) plutôt qu'une page cassée.
- Page billet : rendu Markdown, typographie lisible, date + tags.

---

## 3. Modèle de contenu

### 3.1 CV — `latex/my_cv.tex` (LaTeX, SOURCE EXISTANTE migrée)

```text
latex/
├── my_cv.tex       # template Harshibar (MIT) adapté — EN, défaut (déjà existant)
└── my_cv_fr.tex    # variante FR (optionnelle — repli EN si absente)
```

- **Réutilisation de l'existant** : le repo d'origine (`Thejulfi/my-cv` — backup local `my-cv/`)
  contenait déjà un CV LaTeX compilé via `latexmk`.
- **Compilation en CI, jamais commité** : le workflow existant `deploy-pdf.yml`
  (action `xu-cheng/latex-action`) produit `my_cv.pdf` et le **publie en GitHub
  Release** avec tag `cv-<n>`. Le site n'a PAS à recompiler : la CI du site
  télécharge le PDF de la dernière Release dans `public/pdf/`.
- Page `/cv` du site = résumé court + bouton de téléchargement (pas de copie HTML).
- Le PDF est **en anglais** par défaut (langue du site) ; la variante française est compilée en parallèle si `my_cv_fr.tex` existe.

### 3.2 Projets — `content/projects/<slug>/index.md`

Un dossier par projet, fichier Markdown avec **frontmatter** :

```yaml
---
title: "Nom du projet"
summary: "Une ligne (utilisée dans les cartes du portfolio)"
status: "actif | archivé"
period: "2025"
languages: ["Python", "TypeScript"]
repo: "https://github.com/.../<repo>"
demo: null            # ou URL
cover: "./screenshot.png"   # image locale avec le projet
---
```

Le corps du Markdown = description détaillée libre (contexte, ce que ça fait, choix techniques, captures insérées au fil du texte).

**Convention captures d'écran** : ratio uniforme **16:9** pour les `cover`, nommage cohérent, rendu en dark mode ; si un projet n'a pas de capture utile, un placeholder sobre (carte typographique du nom du projet) plutôt qu'une grille hétérogène.

### 3.3 Billets de blog — `content/blog/<slug>.md`

```yaml
---
title: ""
lang: "en"      # "en" | "fr" — un billet vit sous /blog/… (en) ou /fr/blog/… (fr)
date: "2026-11-06"
tags: []
summary: ""     # extrait pour l'index
draft: true     # true = brouillon visible en dev, exclu du build de production
---
```

Purement Markdown. Un billet = une langue = une URL (pas de duplication ;
repli « traduction à venir » sur l'index de l'autre langue). Aucun article au
lancement.

### 3.4 Traductions d'interface

Textes d'interface (labels de nav, « Voir mon CV », etc.) dans des fichiers de traduction `fr`/`en`. Pour les contenus : **CV avec PDF EN par défaut** (variante FR optionnelle via `cv-fr.tex`), **projets en FR et EN avec fallback** ; **blog en une seule langue au départ** (celle du billet, librement FR ou EN).

**Fallback i18n des contenus** : publier un projet ou un billet en une seule langue est acceptable ; sur l'autre locale, un affichage de repli propre (lien vers la version d'origine + mention « traduction à venir ») plutôt que de dupliquer systématiquement — évite la double maintenance à chaque publication.

---

## 4. Exigences non fonctionnelles

| Domaine | Exigence |
|---|---|
| **Responsive** | Mobile-first ; lisible et agréable de 320 px à desktop large. Non négociable. |
| **Thème** | **Dark mode par défaut.** Le clair est une évolution possible, pas une exigence V1. |
| **Performance** | Site statique, peu ou pas de JavaScript. Pas de bibliothèque UI lourde. Images optimisées. |
| **Accessibilité** | Contrastes suffisants en dark mode, structure sémantique (landmarks, titres), focus visible. |
| **SEO de base** | Titres/meta-description par page, Open Graph, sitemap.xml, robots.txt, URLs propres. Pas de stratégie SEO avancée. |
| **Typographie** | Double visage : une police **à chasse fixe (mono)** pour les éléments « marques du terminal » (titre/nom, tags, métadonnées, prompt décoratif), une police **sans-serif lisible** pour le corps de texte — pour rester digeste pour une audience non technique. |
| **Palette** | Inspirée des thèmes NeoVim modernes (ex. *tokyonight*, *kanagawa*) : fond sombre profond, texte doux (pas de blanc pur), **une couleur d'accent unique** (bleu/cyan ou vert doux) pour liens et mises en évidence. |
| **Direction artistique** | Style « terminal propre » : touches discrètes comme un prompt décoratif (`~`, `>`, chemin du breadcrumb en style path), bordures fines, blocs de code mis en valeur. **Éviter explicitement** : effets CRT/scanlines, animations de machine à écrire, faux shell interactif, surcharge de caractères techniques. |
| **Fiabilité** | Déploiement automatique à chaque push sur la branche principale. |

---

## 5. Stack technique & déploiement

### 5.1 Exigences techniques exprimées

| # | Exigence |
|---|---|
| T1 | **Facile à maintenir** : ajouter/modifier des pages, publier un billet, ajuster une fiche projet = édition de fichiers simples, sans plonger dans le code du site. |
| T2 | **Environnement de dev normé** : le projet s'ouvre dans un **dev container** — le même environnement pour tout contributeur et pour l'agent IA. |
| T3 | **Servable via Docker Compose** : le site doit pouvoir tourner sur un **VPS** derrière un `docker compose up` (image web + reverse proxy éventuel). |
| T4 | **CI simple** : les déploiements se font via la CI, sans manipulation manuelle sur le serveur. |
| T5 | **Servi via Cloudflare** : DNS + **Cloudflare Tunnel** vers le VPS — aucun port public exposé sur le serveur, TLS terminé au bord Cloudflare, filtrage des bots au niveau du bord. |

### 5.2 Choix proposé

**Générateur : Astro (sortie statique)**
- Contenu = fichiers : blog et projets via *Content Collections* (Markdown + frontmatter), CV via JSON. Ajouter un billet = créer un fichier `.md`, c'est tout.
- Zéro JS par défaut côté client → léger, s'aligne avec les exigences perf/SEO.
- i18n supporté au niveau du routing.

**Containerisation**
- **`Dockerfile` multi-stage** : build (Node → `astro build`) puis exécution minimale (`nginx:alpine`) servant les fichiers statiques. Image finale de quelques Mo.
- **`docker-compose.yml`** à la racine : **dev container uniquement** (service `dev`), montages des configs hôte.
- **`deploy/docker-compose.vps.yml`** : déploiement sur VPS — service `web` (image publiée sur GHCR) et `cloudflared` **optionnel** (profil `tunnel`). Aucun volume, aucun build côté serveur.
- **`cloudflared`** (tunnel Cloudflare) : relie le site au réseau Cloudflare sans ouvrir de port public ; HTTPS géré par le bord Cloudflare. Aucun reverse proxy TLS à maintenir côté serveur.
- **Domaine : `ficaud.xyz`** (racine) via Cloudflare DNS () ; redirection `www.` → apex à gérer côté Cloudflare.
- **`devcontainer.json`** : Node LTS + Astro extensions éditoriales ; un coup de `docker compose up` sur la cible `dev` et le site tourne localement en mode dev.

**CI/CD (GitHub Actions)**
- À chaque push sur `main` : lint, build de l'image **multi-arch (amd64 + arm64)** sur runners natifs, smoke test puis publication sur **GHCR** (registry GitHub, gratuit, colocalisé avec le repo, package public).
- **Déploiement** : la CI ne déploie pas. La cible tire l'image (`docker compose pull && docker compose up -d`) et gère elle-même son tunnel Cloudflare ; aucun job SSH ni secret de serveur dans la CI du site.
- Le workflow écoute aussi la fin de `deploy-pdf.yml` (`workflow_run`) pour reconstruire l'image avec le PDF fraîchement publié.
- Bonus : le **workflow existant `deploy-pdf.yml`** produit le PDF (GitHub Release tag `cv-<n>`) ; la CI du site **télécharge** ce PDF de la dernière Release dans `public/pdf/` (voir 3.1).

### 5.3 Structure d'arborescence cible

```
myPortfolio/               # nouveau repo (init local fait, remote à créer)
├── latex/my_cv.tex        # CV LaTeX (existant, migré)
├── .github/workflows/
│   ├── deploy-pdf.yml     # CI CV existante (build → Release)
│   └── site.yml           # CI du site (Phase 4)
├── devcontainer.json      # dérivé du .devcontainer LaTeX existant (Node en Phase 1)
├── docker-compose.yml     # dev container local
├── deploy/
│   ├── docker-compose.vps.yml   # VPS : image GHCR + cloudflared optionnel
│   └── README.md
├── Dockerfile / nginx.conf
├── .opencode/             # skills + commands + AGENTS.md
├── content/
│   ├── projects/<slug>/index.md
│   └── blog/<slug>.md
└── src/
    ├── pages/
    ├── components/
    └── styles/
```

### 5.4 Reste à trancher (implémentation)

- Configuration du **tunnel Cloudflare** (création du tunnel, ingress vers le service `web`) — prod vs preview.
- ~~PDF du CV~~ **Tranché : source LaTeX dans le repo, compilation en CI** (voir 3.1 et 5.2).
- Obfuscation de l'email de contact (utile même derrière Cloudflare pour les scrapers qui collectent le contenu des pages).

---

## 6. Contraintes & évolutions futures (hors V1)

- **Thème clair** + détection préférence système / toggle manuel.
- **Image Open Graph par page/projet** générée au build (style terminal : nom, langages, palette du site) — rend les partages LinkedIn/X de vos projets distinctifs ; V1 : une image OG globale suffit.
- **Recherche** ou filtres sur le blog/portfolio quand le volume le justifie.
- **Analytics** (respectueux de la vie privée, ex. Plausible).
- **Flux RSS** du blog.
- **Tags/langues sur le blog**, pagination si beaucoup d'articles.
- **Formulaire de contact** (avec **Cloudflare Turnstile** en anti-spam) si un jour le simple email affiché ne suffit plus. Implication : un petit backend (Cloudflare Worker ou endpoint tiers).
- CMS headless / édition en ligne des contenus si l'écriture Markdown via git devient frustrante.

---

## 7. Stratégie de réalisation & workflow agentique

**La première étape n'est pas le site, c'est l'atelier** : construire d'abord le pipeline de travail agentique, exécutable via OpenCode dans le dev container, pour que les phases suivantes soient faites par des agents dans un environnement normé.

### 7.1 Phase 0 — Environnement & outillage agentique (prérequis)

- **`devcontainer.json` finalisé** : Node LTS, dépendances Astro, cloudflared (CLI), lint/format, git — le même conteneur pour humain et agents.
- **`AGENTS.md` à la racine** : conventions durables du projet — structure de contenu, schémas de frontmatter obligatoires, règles de style, conventions de nommage, ce qu'il ne faut jamais toucher sans validation.
- **Configuration OpenCode versionnée dans le repo** (`.opencode/`) : instructions globales + agents/commandes spécialisés.
- **Commandes projet personnalisées** :
  - `/add-post <slug>` — scaffolding d'un billet (frontmatter complet, brouillon par défaut)
  - `/add-project <slug>` — scaffolding d'une fiche projet (dossier + capture placeholder)
  - `/check` — lint + **validation des schémas de contenu** + build + résumé de ce qui est cassé
- **Critère de sortie** : un agent fraîchement lancé dans le conteneur peut exécuter `/check` et obtenir un rapport cohérent, même si le site est encore vide.

### 7.2 Phases du projet (après la Phase 0)

| Phase | Contenu | Critère de sortie |
|---|---|---|
| **1. Squelette** | Layouts, navigation, design tokens (palette, polices, dark), pages vides mais routées | Site navigable avec contenus factices, `/check` vert |
| **2. Contenus réels** | CV LaTeX enrichi + **3 à 5 fiches projet réelles** | `/cv` et `/projects` à contenu réel (PDF compilé en CI) |
| **3. Blog** | Collections Markdown, index avec état vide propre, gabarit de billet | Un billet de test en brouillon fonctionne de bout en bout |
| **4. Infra** | Dockerfile multi-stage, compose + cloudflared, CI multi-arch (GHCR), PDF du CV | Image amd64/arm64 publiée sur GHCR et pullable ; la cible déploie via son compose (tunnel géré côté cible) |
| **5. Qualité & lancement** | Audit responsive/mobile, accessibilité, Lighthouse, 404, sitemap, tunnel en prod, DNS | Site en production, checklist finale verte |

**Règle d'or** : chaque phase se termine par un état déployable — « `docker compose up` local + `/check` vert » à chaque jalon, et la CI de déploiement branchée dès la phase 1 (l'image existe tôt, le site reste publiable en continu).

**Point clé pour les agents** : les schémas de contenu validés (collections Astro + zod) font qu'un frontmatter mal rempli **casse le build** → erreur précise, corrigible automatiquement dans la boucle agent. C'est ce qui rend le pipeline véritablement agentique sans supervision constante.

### 7.3 Projets initiaux du portfolio (matière de la Phase 2)

Les **3 fiches** à créer (via `/add-project`, en anglais par défaut, description détaillée). Matière première extraite des README — à approfondir dans le dev container (lecture des doc/, CHANGELOG, historique git, captures) avant rédaction :

| # | Repo | Ce que c'est (seed) | Frontmatter cible |
|---|---|---|---|
| 1 | **`ficaud/relic-core`** | **Firmware ESP32 (Zephyr RTOS v4.5, C)** implémentant *Shamir's Secret Sharing* sur GF(2⁸) — secrets (mots de passe, seed phrases) découpés en 5 parts, 3 requises pour restaurer. **100% offline** (AP Wi-Fi + portail web captif), QR codes (génération Nayuki réduite ; décodage via ses forks `relic-quirc` & `relic-zxing-cpp`), web flasher navigateur, démo **WASM** hébergée sur GitHub Pages. CI build + coverage. 201 commits, GPL-3.0. | langs `["C", "Zephyr"]`, demo : `https://ficaud.github.io/relic-core/`, status actif |
| 2 | **`ficaud/relic-hw`** | **Docs MkDocs** (GitHub Pages) : guide pas-à-pas pour débutants construisant le boîtier Relic physique qui héberge relic-core. Sœur du projet 1 — lien croisé entre les deux fiches. 54 commits, Python/MkDocs + CI Pages. | langs `["Python", "MkDocs"]`, demo : `https://ficaud.github.io/relic-hw`, status actif |
| 3 | **`ficaud/Ovalbot`** | **App production en service** : Rust/Axum + SvelteKit + SQLite, **hébergée sur Raspberry Pi arm64**. Surveille le TOP14 (dates de matchs + revente de places), notifie (Resend + bot Telegram), coffre-fort de credentials boutique (AES-256-GCM/HKDF), scanner + checkout bot en Phases, waitlist 10 personnes. Multi-arch arm64/amd64. En ligne sur `ovalbot.ficaud.xyz` (même famille de domaine que le site). 135 commits, CI ci/deploy + codecov, GPL-3.0. | langs `["Rust", "TypeScript"]`, repo + demo : `https://ovalbot.ficaud.xyz/`, status actif |

**À faire dans le container (Phase 2, par l'agent)** :
1. Ciler en profondeur chaque repo (README + `doc/`, CHANGELOG, workflows, histoire git) pour du contenu technique vérifié — pas de paraphrase du README.
2. Choisir/produire les captures 16:9 dark mode (les projets embarquent déjà des captures dans `doc/img/`, et les démos en ligne tournent) + logo Relic comme visuel possible.
3. Rédiger les fiches EN (les recruteurs lisent l'EN), résumer pour les cartes, pointer vers démo + repo.
4. Valider via `/check`.

---

## 8. Décisions finales

1. ~~Nom de domaine~~ **Tranché : `ficaud.xyz`** — servie via Cloudflare DNS + Tunnel ; redirection `www` → apex côté Cloudflare. **Orthographe confirmée** : handle GitHub `ficaud` + `ovalbot.ficaud.xyz` en production.
2. ~~PDF du CV~~ **Tranché : CV LaTeX existant (`latex/my_cv.tex`), workflow `deploy-pdf.yml` déjà en place → PDF publié en GitHub Release ; le site télécharge la dernière Release.** (voir 3.1)
3. ~~Contact~~ **Tranché : email simple affiché, pas de formulaire ; captcha reporté** (voir 6). Reste (mineur) : affichage en clair ou obfusqué, à trancher à l'implémentation.
4. ~~Photo/avatar à l'accueil~~ **Tranché : non** — accueil sans photo, texte/typographie comme élément principal.
5. ~~Langue par défaut~~ **Tranché : anglais par défaut à la racine `/`, français sous `/fr/`** avec sélecteur FR/EN dans le header et le footer.
