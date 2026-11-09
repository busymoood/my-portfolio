---
title: "Relic Core"
summary: "Offline ESP32 QR-code based secret-sharing device."
status: "actif"
period: "Jul – Oct 2026"
languages: ["C", "C++"]
repo: "https://github.com/ficaud/relic-core"
demo: "https://ficaud.github.io/relic-core/"
cover: "./cover.png"
---

## Overview

Relic Core is a firmware for ESP32 boards that implements Shamir's Secret Sharing algorithm to split and recover secrets (like passwords, private keys, bitcoin seed phrases etc.) in a secure way.

See the [demo](https://ficaud.github.io/relic-core/) in a WASM type web page hosted by github to see how it works.

## Why

Relic is, for me, a solution that answers that good old question: who will manage my most precious assets if something happens to me?

In the physical world, there are notaries, along with your country's rules and legislation, that handle this kind of question—but that isn't necessarily the case in the digital world.

Most people who grew up with the internet aren't yet on the verge of death, so there isn't really a debate about what will happen to all their digital assets if they die.

Your crypto assets will be gone forever. Your social media accounts will stay up and running, and all the other things you've initiated in your digital life will probably keep running—until someone takes care of them, or until they don't.

The core idea of Relic is to give everyone the ability to share secrets with others without the fear that they'll be used against them. It works like a Horcrux in Harry Potter: you can share your most sensitive secrets with people you trust, and unlike a single piece of your bank password, none of them can recover it easily—not until they come together to reconstruct the secret.

## How it works

The sharing itself is a compact C implementation of SSS (Shamir's Secret Sharing) algorithm. To ease the storing and retrieval of the secret generated, Relic can encode and decode QR codes. ESP32-S3 boards decode on-device with quirc, the XIAO S3 uses ZXing-cpp with its allocations routed to PSRAM, and the classic ESP32 falls back to decoding in the browser because it lacks the RAM.

Seed phrases can be compressed by replacing BIP-39 or SLIP-39 words with their indices, with an optional passphrase. The same C codecs are compiled to WebAssembly for the hosted demo, so the browser version runs the firmware's own sharing, QR and compression modules rather than a rewrite. A Web Serial flasher completes the loop.

Around that core, and for embedded targets such as the ESP32, the firmware implements its own network plumbing: access point management, a DHCP server, a DNS interceptor that answers the captive-portal probe domains used by Android, Apple and Windows.

## How to use it

You can watch a [video](https://makertube.net/w/dX99LqCXLWmRGgNFS9Bdpc) I made explaining you how to do it.

Then, there is [relic hardware](https://ficaud.xyz/projects/relic-hw) that is the full guide on how to create and use Relic.
