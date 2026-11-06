---
name: git-commits
description: Write, review, or fix git commit messages in this repository, in English and in Conventional Commits format. Use whenever creating, staging, amending, splitting, squashing, or rebasing commits; whenever Julien asks to "commit this", "prepare a commit", "clean up my commits", or reviews history; and whenever a commit message must be drafted or rewritten — even if the request is in French (the message itself must be English). Also apply when checking that pending changes are split into clean, logical commits before a push or a release.
---

# Git commits — English + Conventional Commits

Every commit in this repository is written in **English**, in **Conventional
Commits** format. Two reasons this matters here, beyond taste:

1. The repo is public-facing and employer/peer-audited; the commit history is
   part of what peers and recruiters may read along with the portfolio.
2. Agents (you) rely on `git log` as shared context between sessions — a
   predictable format makes history skimmable and greppable (`git log
   --grep="feat(site)"`).

## Hard rules

- **English only** in subject, body, and trailers — scope names too. Julien
  often speaks French in conversation: silently translate, keep technical
  terms, filenames, and identifiers as-is. Never half-translate
  (e.g. don't leave "mise à jour du header" inside an English sentence).
- **Conventional Commits format**, always:

  ```
  <type>(<scope>): <subject>

  [optional body]
  ```

- **No AI attribution** (no "Co-authored-by", no "Generated with ...") — the
  repo owner reviews everything himself.

## Types

| Type | Use for |
|---|---|
| `feat` | New site feature, new content capability (bump MINOR) |
| `fix` | Bug fix of something that shipped (bump PATCH) |
| `docs` | Spec (`docs/spec.md`), README, project/blog prose in the repo docs |
| `content` | Portfolio/Blog content files (`content/`) — this repo's main deliverable |
| `cv` | LaTeX CV changes (`latex/`) — these go through `deploy-pdf.yml` |
| `site` | Src code: pages, components, styles, layouts |
| `build` | Astro/Node config, package.json, dependencies |
| `ci` | Only after explicit validation by Julien (`.github/workflows/` is protected) |
| `docker` | Dockerfile/compose/nginx — only after explicit validation (protected) |
| `chore` | Repo hygiene: .gitignore, .DS_Store cleanup, agent config (`.opencode/`) |
| `refactor`, `perf`, `test`, `style`, `revert` | Standard meanings |

When in doubt between `content` and others: if the change is inside
`content/`, it is `content`. `chore` is the default scope for `AGENTS.md`
and `HANDOFF.md`.

## Subject

- Imperative mood: `add`, not `added` or `adds` — a subject should complete
  "when applied, this commit will ...".
- Lowercase first letter after the prefix, no trailing period.
- ≤ 72 characters. If it doesn't fit, the commit is probably two commits.

## Body

Optional but valuable when the *why* is not obvious from the diff. Explain
context and trade-offs, not a line-by-line narration of what the diff shows.
Wrap at ~72 columns.

**Example 1**

Input: "mise à jour du CV — ajout des langues et du projet relic-core"
Output:
```
cv: add languages and relic-core project

Reflects the current LaTeX source; triggers a new PDF release
via deploy-pdf.yml.
```

**Example 2 (what to reject and fix)**

Input: `Update stuff and finalize changes before deployment phase`
Problems: vague ("stuff"), no type, not imperative, no scope.
Fix — split into what it actually is, e.g.:
```
feat(site): add 404 page
chore: clean up leftover build artifacts
```

## Commit hygiene

- **One logical change per commit.** Prefer splitting with `git add -p` over
  dumping everything in one `feat: update many things`. A "fix" mixed with a
  feature is two commits just as a `content` addition mixed with a site change.
- **Never commit**: generated LaTeX output (`.aux`, `.log`, `.pdf` under
  `latex/` — CI builds it), `node_modules/`, `.DS_Store`, any `.env`,
  `public/pdf/` (downloaded from Releases), the old nested `my-cv/` backup.
  The `.gitignore` encodes this; if something appears despite it, stop and
  flag it instead of force-adding.
- **Run `/check` before committing** when the working tree includes site code
  or content — a commit should not knowingly break the build. Committing a
  red state is acceptable only when explicitly part of the plan (e.g. a
  scaffold commit), and the subject/body then says so.
- Before squashing/rebasing published history: this repo is push-to-deploy
  oriented; rewriting branches that Julien already pushed requires his
  explicit OK.
- Prefer speaking about future work in the body, not the subject.

## Workflow sketch

1. `git status` + `git diff` — inventory what actually changed (don't guess).
2. Group into logical commits; propose the split to Julien if it's not
   obvious or includes protected areas (`.github/workflows/`, `docker-*`,
   `nginx.conf` — never commit those without his validation, per AGENTS.md).
3. Draft each message in this format; show the list before committing.
4. Commit. Report the final subject list.
