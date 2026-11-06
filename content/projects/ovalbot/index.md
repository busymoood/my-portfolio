---
title: "OvalBot"
summary: "Production ticket-resale watcher for TOP14 rugby, running on a Raspberry Pi."
status: "actif"
period: "Oct – Nov 2026"
languages: ["Rust", "TypeScript"]
repo: "https://github.com/ficaud/Ovalbot"
demo: "https://ovalbot.ficaud.xyz/"
cover: "./cover.png"
---

OvalBot is a production web app that watches TOP14 rugby. It keeps a calendar of fixtures, alerts users when a match gets an official date, and tracks ticket resale for Stade Rochelais home games. It runs on a Raspberry Pi behind a Cloudflare tunnel, with a ten-account waitlist that keeps the beta small.

## How it works

The backend is Rust/Axum serving a SvelteKit frontend and a SQLite database. A dedicated calendar crate scrapes the official LNR site, derives stable match ids from the fixture links, and refreshes every 20 minutes; the diff between two snapshots is what triggers scheduling alerts. Notifications go out over Resend for email and a Telegram bot with single-use account-linking tokens, with per-user channel preferences and database-level de-duplication.

The resale bot is the harder half. It discovers resale links on the club's ticketing site, stores them in a durable registry, then polls them directly and parses Drupal/BigPipe pages into packs and seats. New seats are recorded with an insert-on-conflict guard, so restarts and repeated scans never re-alert the same seat. A matcher maps free-form French titles and dates back to calendar matches, rejects meals and parking cards, and fails closed when a match is ambiguous. The checkout phase goes further: it logs into the shop with per-user credentials, adds matching packs to the cart, and claims seats atomically — dry-run by default, with diagnostic dumps when a checkout fails.

Shop credentials are encrypted at rest with AES-256-GCM under an HKDF-SHA256 key derived from a server secret. The feature fails closed when the key is absent, and plaintext is never logged or returned by the API.

The project ships multi-arch arm64/amd64 images, 14 SQL migrations and 354 tests, including integration tests over captured ticketing fixtures.

*The calendar covers all fourteen TOP14 clubs; ticket automation currently covers Stade Rochelais home games only.*
