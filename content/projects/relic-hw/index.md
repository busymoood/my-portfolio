---
title: "Relic Hardware Guide"
summary: "Beginner guide to using the Relic device, from flashing to physical share hygiene."
status: "actif"
period: "Aug – Sep 2026"
languages: ["Python"]
repo: "https://github.com/ficaud/relic-hw"
demo: "https://ficaud.github.io/relic-hw"
cover: "./cover.jpg"
---

The Relic Hardware guide is the companion to Relic Core: a MkDocs site that takes a complete beginner from a bare ESP32 board to shares they can actually keep safe. Splitting a secret is only half the problem — a scheme fails if the shares are lost, unreadable ten years later, or stored in the same place.

## How it works

The guide follows the full lifecycle: pick and flash a board, join the device's captive portal, split a secret, distribute the shares, then reconstruct it from any three. It explains Shamir's Secret Sharing without mathematics, documents the supported boards (and why the classic ESP32 delegates QR decoding to the phone), and covers BIP-39 and SLIP-39 compression plus the optional passphrase — including the rule that the same mode must be enabled at recovery time.

The strongest section is share hygiene: how to label a share so it still makes sense a decade later (purpose, owner, date, firmware version), why to print QR codes on a thermal printer instead of leaving them on a computer, how to distribute shares against loss, theft and collusion, and when to re-split. The guide records the firmware version on each label, which is also how the two projects stay coupled.

It is built with MkDocs Material, deployed to GitHub Pages by a small Actions workflow, and written as docs-as-code: a chapter is a Markdown file, a fix is a pull request. The site ships nine pages, twenty media assets and a 1080p demo video.
