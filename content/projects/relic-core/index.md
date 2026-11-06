---
title: "Relic Core"
summary: "Offline ESP32 secret-sharing device with a captive portal and QR-based shares."
status: "actif"
period: "Jul – Oct 2026"
languages: ["C", "C++"]
repo: "https://github.com/ficaud/relic-core"
demo: "https://ficaud.github.io/relic-core/"
cover: "./cover.png"
---

Relic Core is a firmware for ESP32 boards that implements Shamir's Secret Sharing over GF(2⁸). A secret — a password, a private key, a BIP-39 seed phrase — is split into five shares, and any three of them reconstruct it. The device is fully self-hosted: it opens its own Wi-Fi access point, serves a captive portal to the phone, and never connects to the internet.

## How it works

The sharing itself is a compact C implementation built on precomputed log/exp tables over the AES polynomial `0x11B`. Coefficients come from Zephyr's RNG, shares are evaluated with Horner's method, and reconstruction uses Lagrange interpolation at zero. Secrets are capped at 256 bytes, which keeps every share small enough to print as a QR code.

Around that core, the firmware implements its own network plumbing: access point management, a DHCP server, a DNS interceptor that answers the captive-portal probe domains used by Android, Apple and Windows, and a deliberately small single-client HTTP server. QR generation uses a reduced Nayuki encoder (alphanumeric, ECC LOW); decoding is where hardware limits become visible. ESP32-S3 boards decode on-device with quirc, the XIAO S3 uses ZXing-cpp with its allocations routed to PSRAM, and the classic ESP32 falls back to decoding in the browser because it lacks the RAM.

Seed phrases can be compressed by replacing BIP-39 or SLIP-39 words with their indices, with an optional passphrase. The same C codecs are compiled to WebAssembly for the hosted demo, so the browser version runs the firmware's own sharing, QR and compression modules rather than a rewrite. A Web Serial flasher completes the loop.

The project ships 141 GoogleTest cases and three board targets in CI; the pure modules reach 95.5% line coverage, while the network layer is deliberately left out of that metric. GPL-3.0, 24 tagged releases.
