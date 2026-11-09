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

## Overview

OvalBot is a web app that watches resale listings for TOP14 rugby matches, so you no longer have to keep refreshing your favourite team's website.

It's actually up and running right now at [ovalbot.ficaux.xyz](https://ovalbot.ficaud.xyz/), you can take a look, create an account (if all the spot haven't been filled yet) and start using it.

## Why

Some teams, such as Stade Rochelais, are so popular that getting a ticket for a home match is very difficult.

For fans who still want to attend, the only option is to keep checking the resale page and hope a ticket that fits their budget and requirements becomes available.

OvalBot monitors the page for you and alerts you when a ticket matching your criteria appears can even check it out for you.

## How it works

The backend is a Rust service built on Axum. It serves a SvelteKit frontend and stores its data in SQLite.

The current version supports up to ten users. Each user can configure the bot to watch resale listings for a chosen match and set additional search parameters.

Email notifications are delivered via Resend, while Telegram notifications go through a bot that links accounts with single-use tokens. Users choose their preferred channels, and duplicate alerts are filtered out at the database level.

To secure a resale ticket, the bot can automatically log in to your account and add the ticket to your basket, giving you 20 minutes to complete the purchase.

On the secure side, Ticketing-shop credentials are encrypted at rest with AES-256-GCM using an HKDF-SHA256 key derived from a server secret. If the key is missing, automatic checkout fails closed, and plaintext credentials are never logged or returned by the API.

The project ships multi-arch arm64/amd64 images, 14 SQL migrations and 354 tests, including integration tests run against captured ticketing fixtures.
