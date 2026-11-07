# Cover generator

Produces the 16:9 dark cover banners shown on project cards and detail pages.

```
content/projects/<slug>/
  cover.json         # shell text: title, tagline, stats (<=3), footers, out
  cover-focal.html   # optional focal-zone markup (image, card, badge…)
  cover-focal.css    # optional styles for the focal markup
  cover.png|jpg      # generated output (committed)
```

Run:

```sh
python3 scripts/cover/make_cover.py relic-core      # one project
python3 scripts/cover/make_cover.py --all           # every cover.json
npm run cover -- relic-core                         # same as the first form
```

The script renders `template.html` in Chromium (Playwright is available in the
devcontainer, browsers in `/opt/ms-playwright`), using the site's own tokens
(`src/styles/tokens.css`, dark `:root`) and self-hosted IBM Plex fonts, so a
banner always matches the live palette and typography.

Checks built into the run:

- a 400 px-wide mobile preview is written to
  `/tmp/opencode/cover-preview/<slug>-mobile.png` — the banner is legible at
  that size by design (big title, tagline, <=3 stats, large focal asset);
- a warning is printed if the focal content or the left column overflows its
  box (would overlap the header or the stats);
- `npm run lint` still enforces the 16:9 ratio (`scripts/check-covers.mjs`).

Without `cover-focal.html` the template falls back to a sober typographic
monogram instead of inventing decorative content. Regenerate rather than
hand-editing the PNG; the JSON + focal files are the source of truth.
