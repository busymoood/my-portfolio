---
name: versioning
description: Semantic versioning (SemVer), Keep a Changelog, and release/delivery planning for this repository. Use whenever planning or preparing a release, bumping the version, updating CHANGELOG.md, creating a tag, publishing a GitHub Release, deciding if a change is major/minor/patch, or discussing release cadence, milestones, and what ships when. Trigger on requests like "bump the version", "prepare the release", "what's in Unreleased", "tag v1.0.0", "ship it", or "what goes in the next release" — even casually phrased or in French. Pairs with the git-commits skill: commits are Conventional Commits, and this skill turns them into versions and changelog entries.
---

# Versioning, changelog & releases

The repo follows three standard, boring conventions on purpose: **SemVer
2.0.0**, **Conventional Commits**, **Keep a Changelog**. They're boring
because peers and tooling already know them — no custom scheme to learn, and
a `CHANGELOG.md` that any reader can scan.

## Version numbering (SemVer)

`MAJOR.MINOR.PATCH`, tags are always prefixed: `v1.4.2`.

- **MAJOR** — incompatible change for a consumer of the artifact. For this
  site: URL/content-schema breaking changes after launch (renamed routes,
  breaking frontmatter schema).
- **MINOR** — new capability, backward compatible (`feat`).
- **PATCH** — bug fix, backward compatible (`fix`).

Derivation from commits since the last tag:

| Commits | Bump |
|---|---|
| Any with `!` or `BREAKING CHANGE:` trailer | MAJOR |
| At least one `feat` | MINOR |
| Only `fix` (plus docs/chore/content) | PATCH |
| Only `docs`, `content`, `chore`, `ci`, `style`, `refactor`, `test` | No bump needed — but batch them with the next real release |

**Pre-1.0 rule**: until the site goes to production (end of Phase 5), the
version stays `0.y.z`. In `0.y`, breaking changes bump MINOR, not MAJOR —
the API/URL contract isn't published yet. `1.0.0` is tagged **when the site
is live on `ficaud.xyz`**, not before.

## Two independent release streams

1. **Site releases**: tags `vX.Y.Z` — the site's delivered state. One
   release per phase milestone at minimum (see `docs/spec.md` §7), plus a
   release whenever something meaningful ships.
2. **CV PDF releases**: tags `cv-<n>` — produced by `deploy-pdf.yml`, one
   per CV change. **Never** reuse `vX.Y.Z` for the PDF, and never touch the
   `cv-<n>` numbering by hand; it is CI-owned.

Never invent a version: read the current one first with
`git describe --tags --abbrev=0` or `git tag -l 'v*' | sort -V | tail -1`.
If there are no tags yet, the repo is at `0.0.0` and the first tag will be
`v0.1.0`.

## CHANGELOG.md

Keep a Changelog format, at the repo root, **in English**:

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- ...

## [0.1.0] - 2026-11-06

### Added
- Initial Astro skeleton with routed pages `/`, `/cv`, `/projects`, `/blog`, `/404`.

[Unreleased]: https://github.com/<owner>/myPortfolio/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/<owner>/myPortfolio/releases/tag/v0.1.0
```

Rules that keep it useful:

- **Write for a reader, not for git.** Group under `Added`, `Changed`,
  `Deprecated`, `Removed`, `Fixed`, `Security` — not one line per commit.
  A phase that added a blog is one `Added` bullet, not twelve.
- **`Unreleased` accumulates continuously**; at release time it is renamed
  to the version + date and a fresh empty `Unreleased` is added.
- Entries link to the relevant phase/issue when it helps (`docs/spec.md` §7.2
  is a good reference anchor).
- Technical setup steps that don't change behavior (chore, deps) may stay
  out unless they matter to the reader.

## Release checklist

Run these in order; don't skip because it's "just a small release":

1. **Working tree clean** and `main` up to date.
2. **`/check` green** (lint + content schema validation + build).
3. **Review commits since the last tag**: `git log v<last>..HEAD
   --pretty='%s'`; classify them with the bump table above and confirm the
   next version number.
4. **Update `CHANGELOG.md`**: move `Unreleased` → `[X.Y.Z] - YYYY-MM-DD`,
   add the compare/release links, add a new empty `Unreleased`.
5. **Bump `package.json` version** (site stream only — keep it equal to the
   tag without the `v`). The CV stream never touches `package.json`.
6. **Commit**: `chore(release): vX.Y.Z` (see the `git-commits` skill; the
   body may list the changelog bullets).
7. **Tag**: `git tag -a vX.Y.Z -m "vX.Y.Z"`, then push the commit and the
   tag together (`git push --follow-tags` — only with Julien's OK on push
   targets; there is no remote yet).
8. **GitHub Release** from the tag, notes = the `[X.Y.Z]` changelog section
   (à terme via `gh release create`). Use `gh release list` first to check
   the previous one.
9. **Verify CI** (`site.yml` once Phase 4 exists) and that the deployed
   site serves the new state.

## Planning a delivery

The unit of delivery is **the phase milestone in `docs/spec.md` §7.2** — each
phase ends in a deployable state, so each phase end is at least a MINOR
release while pre-1.0. Between milestones, batch fixes and content updates
into the next release rather than tagging every day: a site with 40 micro
releases has a noisy changelog and no readable "what changed" story.

When a release is being prepared, propose the version number and the draft
changelog section to Julien **before** tagging — the decision of what ships
is his, the mechanical work is yours.

Things that are explicitly NOT releases:
- a draft blog post (`draft: true`) — invisible in prod, stays out of the
  changelog until published;
- a CV-only change — that's a `cv-<n>` PDF release, not a site version;
- an infrastructure-only tweak that doesn't change delivered behavior may be
  mentioned under `Changed` but doesn't force a tag by itself.
