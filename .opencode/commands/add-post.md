---
description: Créer un nouveau billet de blog (brouillon par défaut)
---
Crée un nouveau billet de blog pour le site my-cv.

Sujet : $ARGUMENTS

Consignes :
1. Choisis un slug kebab-case court et durable (il deviendra l'URL du billet
   et ne doit pas être renommé plus tard).
2. Crée `content/blog/<slug>.md` avec EXACTEMENT ce frontmatter :
   ```yaml
   ---
   title: "<titre>"
   date: "<date du jour ISO YYYY-MM-DD>"
   tags: []
   summary: "<une ligne pour l'index>"
   draft: true
   ---
   ```
3. `draft` doit être **true** : la publication se fera via un passage à
   `draft: false` validé par Julien, jamais automatisé.
4. Écris un squelette de billet (titres de sections, points à développer) —
   du Markdown valide, prêt à être complété par la rédaction de Julien.
5. Si le sujet est trop vague pour un slug, demande une précision avant d'écrire.

Après création, propose l'exécution de la command /check pour valider.
