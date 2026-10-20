# Splode.io

A tactical, turn-based chain reaction strategy game engineered with Flutter and Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](https://supabase.com)
[![Nightly Build](https://img.shields.io/badge/Release-Nightly%20APK-orange.svg)](https://github.com/Jagadeeswaran27/splode.io/releases/tag/nightly)

---

## Table of Contents

- [Overview](#overview)
- [Game Mechanics](#game-mechanics)
  - [Objective](#objective)
  - [Placement Rules](#placement-rules)
  - [Critical Mass](#critical-mass)
  - [Chain Reaction Propagation](#chain-reaction-propagation)
  - [Elimination and Victory](#elimination-and-victory)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
  - [Directory Structure](#directory-structure)
  - [Engine Design](#engine-design)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Configuration](#environment-configuration)
  - [Installation and Run](#installation-and-run)
  - [Running Tests](#running-tests)
- [Continuous Integration and Deployment](#continuous-integration-and-deployment)
- [License](#license)

---

## Overview

Splode.io is a deterministic, turn-based grid strategy game modeled after classic chain-reaction mathematics. Players take turns allocating energy orbs into cells on a bounded grid. When an accumulation of orbs exceeds a cell's critical mass, the cell detonates, dispersing kinetic energy into neighboring cells, converting opposing pieces, and triggering compounding cascade sequences across the board.

The game is designed with a Feature-First Clean Architecture, combining high-performance deterministic state calculations in pure Dart with responsive presentation, particle effects, and offline resilience.

---

## Game Mechanics

### Objective

Eliminate all opponent orbs from the board. The last remaining player with orbs on the grid wins the match.

### Placement Rules

- Matches progress in alternating turns.
- On each turn, a player must place one orb into a valid cell.
- A cell is valid if:
  - It is currently unoccupied (unclaimed).
  - It is already owned by the active player.
- Placing an orb into an opponent-owned cell is invalid.

### Critical Mass

Critical Mass represents the maximum capacity of orbs a cell can sustain before detonating. The threshold is defined as the number of orthogonally adjacent neighbors (up, down, left, right):

| Cell Position | Adjacent Neighbors | Critical Mass (Explodes At) | Safe Capacity |
| :--- | :---: | :---: | :---: |
| Corner | 2 | 2 Orbs | 1 Orb |
| Edge | 3 | 3 Orbs | 2 Orbs |
| Interior | 4 | 4 Orbs | 3 Orbs |

### Chain Reaction Propagation

When an allocated orb causes a cell's count to reach its Critical Mass:

1. **Detonation:** The cell resets its orb count to zero and relinquishes its stored potential.
2. **Dispersion:** One kinetic orb is projected into each orthogonally adjacent neighbor.
3. **Conversion:** Any adjacent cell receiving a projected orb is captured by the detonating player, instantly converting all preexisting orbs in that cell to the active player's color.
4. **Cascading Evaluation:** If an adjacent cell reaches or exceeds its Critical Mass after receiving a projected orb, it immediately detonates in the subsequent sequence step, propagating a compounding chain reaction until the entire grid reaches mathematical equilibrium.

### Elimination and Victory

- **Immunity Period:** During the initial round (each player's first turn), players claim starting territory without risk of elimination.
- **Elimination Condition:** After their first turn, any player whose orbs are completely eliminated from the board is permanently eliminated from the match.
- **Victory Condition:** The match concludes when only one player controls orbs on the board.

---

## Key Features

- **Local Pass and Play:**
  - Support for 2 to 4 players on a single device.
  - Configurable board dimensions: Small (6x4), Medium (9x6), and Large (12x8).
  - Custom player handles and distinct color identifiers.

- **Algorithmic AI Opponents:**
  - Four distinct difficulty tiers: Easy, Medium, Hard, and Expert.
  - Powered by a specialized bitboard-inspired evaluator (`FastBoard`) optimized for high-depth lookahead, chain reaction simulation, and positional stability scoring.

- **Interactive Academy with Lumi:**
  - Structured tutorial modules covering board fundamentals, critical mass manipulation, defensive positioning, and offensive chain setup.
  - Animated gesture prompts and contextual tactical guidance.

- **Authentication and Cloud Integration:**
  - Supabase integration supporting Google Sign-In and anonymous guest authentication.
  - Player profile tracking, including aggregate statistics and AI difficulty records.

- **Offline Resilience:**
  - Automatic network connectivity detection.
  - Complete offline fallback allowing unauthenticated local matches and AI play without interruption.

---

## System Architecture

The client application follows a Feature-First Clean Architecture structure, enforcing strict boundaries between business logic, application state, and user interface components.

### Directory Structure

```text
splode/
├── .github/workflows/          # CI/CD workflow definitions
├── docs/                       # Technical specifications and documentation
└── client/                     # Flutter application root
    ├── lib/
    │   ├── core/               # Cross-cutting foundational modules
    │   │   ├── config/         # Environment variable bindings and constants
    │   │   ├── router/         # Declarative navigation and authentication guards
    │   │   ├── theme/          # Design system tokens and styling rules
    │   │   └── widgets/        # Shared presentation components
    │   │
    │   ├── domain/             # Framework-agnostic business logic
    │   │   ├── engine/         # Deterministic GameEngine and chain reaction solver
    │   │   └── models/         # GameState, Cell, FastBoard, MoveRecord, AIDifficulty
    │   │
    │   ├── application/        # State management (Riverpod controllers and providers)
    │   │
    │   └── presentation/       # User interface layer
    │       ├── auth/           # Authentication screens and providers
    │       └── game/           # Game board, local setup, AI selection, and tutorials
    │
    └── test/                   # Automated unit, domain, and widget test suites
```

### Engine Design

The core game logic lives within `GameEngine` in `lib/domain/engine/game_engine.dart`. It operates as a deterministic, pure Dart state machine:

- **Immutability:** Each move returns a sequence of discrete `GameState` frames representing the stepwise explosion propagation, enabling smooth multi-step animations on the presentation layer.
- **Performance Optimization:** During chain reaction resolution, the engine utilizes a reusable internal buffer to compute complex cascade reactions without inducing garbage collector pressure.

---

## Getting Started

### Prerequisites

- Flutter SDK: `>= 3.12.2`
- Dart SDK: `>= 3.0.0`
- Java Development Kit (JDK): Version 17 (for Android compilation)
- Git command-line tools

### Environment Configuration

The application requires environment variables defined in `client/.env`. Create this file before building:

```bash
cat <<EOF > client/.env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
EOF
```

### Installation and Run

1. Clone the repository:

   ```bash
   git clone https://github.com/Jagadeeswaran27/splode.io.git
   cd splode/client
   ```

2. Fetch package dependencies:

   ```bash
   flutter pub get
   ```

3. Launch the application:

   ```bash
   flutter run
   ```

### Running Tests

Execute the comprehensive test suite to verify engine stability and game rules:

```bash
flutter test
```

---

## Continuous Integration and Deployment

The repository uses GitHub Actions for continuous delivery via `.github/workflows/nightly.yml`:

- **Execution Trigger:** Automatically initiated on every push to `main` containing modifications inside `client/**`, or manually via `workflow_dispatch`.
- **Validation:** Executes code validation and test suites (`flutter test`).
- **Caching:** Multi-tier dependency caching covering the Flutter SDK, Dart packages (`~/.pub-cache` hashed against `client/pubspec.lock`), and Gradle build dependencies in `client/android/`.
- **Artifact Generation:** Compiles an optimized release APK and publishes it to the rolling [nightly release tag](https://github.com/Jagadeeswaran27/splode.io/releases/tag/nightly).

---

## License

All rights reserved. Licensing and distribution terms will be provided upon public release.
