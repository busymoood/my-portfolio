---
title: "Sample draft post"
date: "2026-11-06"
tags: ["meta"]
summary: "Fake draft used to exercise the blog template end to end. Never published."
draft: true
---

> Placeholder draft. It stays in `draft: true` unless Julien explicitly agrees
> otherwise: drafts are never listed in production and are flagged `noindex`.

## Why a draft exists in the skeleton

Phase 1 needs to prove the whole blog path works: collection validation,
index ordering, post page rendering and tags. This fake post does that and
will be deleted before any real launch.

## Structure of a post

- Body is plain Markdown, kept readable first.
- Date and tags show in the post header.
- Code blocks use the site's terminal palette.

```bash
# A draft is invisible in production build:
grep -r "draft: true" content/blog/ # nothing listed on /blog
```
