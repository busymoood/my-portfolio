---
description: Valider le projet (lint, schémas de contenu, build)
agent: build
---
Vérifie la santé du projet my-cv et rapporte précisément ce qui est cassé.

Étapes à exécuter (macOS hôte OU conteneur dev selon l'environnement courant) :
1. Si `package.json` et `node_modules` existent : `npm run lint` (si présent,
   sinon skip), puis `npx astro check` (si dispo, sinon skip).
2. Si un build est possible, lance `npm run build` et capture les erreurs.
3. Si le projet n'est pas encore scaffoldé (pas de package.json), vérifie à la
   place :
   - cohérence des frontmatters de `content/**` contre les règles du `AGENTS.md`
     (champs obligatoires, types, slug kebab-case),
   - cohérence du dépôt (fichiers attendus, secrets non commités).
4. Rapporte un résumé final en 3 blocs : **OK / AVERTISSEMENTS / ERREURS**, avec
   chemins exacts et propositions de correctifs pour chaque erreur.

Ne corrige rien automatiquement au-delà des erreurs triviales sûres (typo, champ
manquant évident) sans proposer d'abord le correctif dans la conversation.
