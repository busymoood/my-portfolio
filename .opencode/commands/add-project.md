---
description: Scaffold un nouveau projet dans le portfolio
---
Crée une nouvelle fiche projet pour le portfolio du site myPortfolio.

Infos fournies : $ARGUMENTS

Consignes :
1. Choisis un slug kebab-case (utilisé aussi pour le dossier).
2. Crée `content/projects/<slug>/index.md` avec EXACTEMENT ce frontmatter :
   ```yaml
   ---
   title: "<nom du projet>"
   summary: "<une ligne, carte du portfolio>"
   status: "actif"   # ou "archivé"
   period: "<aaaa>"
   languages: ["<...>"]
   repo: "https://github.com/<utilisateur>/<repo>"
   demo: null        # ou URL
   cover: "./cover.png"
   ---
   ```
3. Génère la cover 16:9 avec le générateur du repo — ne compose jamais une
   image à la main :
   - crée `content/projects/<slug>/cover.json` (voir les exemples existants) :
     `out`, `path` (`~/projects/<slug>`), `status`, `label`, `title`, `tagline`,
     **3 stats maximum**, `footerLeft`/`footerRight` ;
   - si tu as un asset visuel (capture, photo, badge), place-le dans le dossier
     du projet, élague-le (crop propre, fond raccord) et référence-le depuis
     `cover-focal.html` + `cover-focal.css` ;
   - sans asset : n'invente rien, laisse le monogramme de repli du template ;
   - lance `python3 scripts/cover/make_cover.py <slug>` puis vérifie l'aperçu
     `/tmp/opencode/cover-preview/<slug>-mobile.png` (lisibilité à 400 px) ;
   - `npm run lint` doit rester vert (contrôle du 16:9).
4. Le corps du Markdown décrit : contexte/motivation, ce que ça fait, choix
   techniques, défis/points notables. Cadre une structure de sections, ne
   remplis pas le contenu de fiction — laisse des espaces à compléter.
5. Rappelle à Julien d'insérer au moins une capture en dark mode dans le corps.

Après création, propose l'exécution de la command /check pour valider.
