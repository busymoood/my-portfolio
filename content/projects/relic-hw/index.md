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

## Overview

The Relic Hardware guide is the companion to Relic Core: a MkDocs site that takes a complete beginner from a bare ESP32 board to shares they can actually keep safe.

Here is the doc [link](https://ficaud.github.io/relic-hw/) if you want to read it.

## Why

The guide follows the full lifecycle: pick and flash a board, join the device's captive portal, split a secret, distribute the shares, then reconstruct it from any three.

The strongest section is share hygiene: how to label a share so it still makes sense a decade later (purpose, owner, date, firmware version), why to print QR codes on a thermal printer instead of leaving them on a computer, how to distribute shares against loss, theft and collusion, and when to re-split.

The guide records the firmware version on each label, which is also how the two projects stay coupled.

## How it works

This documentation is built with MkDocs Material, deployed to GitHub Pages by a small Actions workflow, and written as docs-as-code: a chapter is a Markdown file, a fix is a pull request. The site ships nine pages, twenty media assets and a 1080p demo video.
