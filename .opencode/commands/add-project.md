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
   cover: "./screenshot.png"
   ---
   ```
3. `cover` doit être un fichier local dans le dossier du projet, ratio 16:9.
   Si aucune capture n'est fournie : garde simplement `cover: "./placeholder.png"`
   dans le frontmatter, préviens Julien que la carte utilisera le placeholder
   typographique tant que la capture manque — n'invente pas de contenu visuel.
4. Le corps du Markdown décrit : contexte/motivation, ce que ça fait, choix
   techniques, défis/points notables. Cadre une structure de sections, ne
   remplis pas le contenu de fiction — laisse des espaces à compléter.
5. Rappelle à Julien d'insérer au moins une capture en dark mode.

Après création, propose l'exécution de la command /check pour valider.
