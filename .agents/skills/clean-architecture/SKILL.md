---
name: clean-architecture
description: Defines the strict Feature-First Clean Architecture layers (Domain, Data, Presentation) and dependency rules for this project. Use this skill whenever structuring a new feature, refactoring code, or creating new models and repositories.
---
# Feature-First Clean Architecture

This project strictly adheres to a **Feature-First Clean Architecture**. The application is divided into self-contained features, where each feature implements the Clean Architecture layers. The strict dependency rule remains: **Dependencies must always point inward toward the Domain layer within each feature.**

## Directory Structure

```
lib/
  core/
    theme/
    widgets/
    utils/
  features/
    [feature_name]/
      domain/
      data/
      presentation/
```

## 1. Domain Layer (The Core of the Feature)
This is the most isolated layer within a feature. It contains the business logic and core data structures.
- **Rules:** 
  - Must NOT contain any Flutter-specific imports (`package:flutter/...`).
  - Must NOT know about external services, databases, or Firebase.
  - Depends on nothing.
- **Components:**
  - `features/[feature]/domain/models/`: Immutable data classes representing core business entities (e.g., `User`, `Story`).
  - `features/[feature]/domain/repositories/`: Abstract interfaces (contracts) that define how data is accessed, without implementing the fetching logic.
  - `features/[feature]/domain/use_cases/`: Classes that encapsulate specific business logic or orchestrate calls to repositories.

## 2. Data Layer
This layer is responsible for fetching, storing, and pushing data. It implements the contracts defined by its feature's Domain layer.
- **Rules:**
  - Depends on the Domain layer (to implement its interfaces and return its models).
  - Contains all the technical details of API calls, Firebase interactions, and local caching.
- **Components:**
  - `features/[feature]/data/services/`: Concrete implementations of data sources (e.g., `FirebaseAuthService`, `FirestoreService`). These return Data Transfer Objects (DTOs) or raw JSON.
  - `features/[feature]/data/models/`: Data Transfer Objects (DTOs) representing the raw structure of external data. These should include methods to convert to/from Domain models (e.g., `toDomain()`).
  - `features/[feature]/data/repositories/`: Concrete implementations of the abstract repository interfaces defined in the Domain layer. These map raw DTOs to clean Domain models.
  - **Dependency Injection:** Repositories and Services are exposed via Riverpod `Provider`s.

## 3. Presentation (UI) Layer
This layer is responsible for presenting data to the user and handling user input.
- **Rules:**
  - Depends on the Domain layer (to use Use Cases or Models).
  - Should be as "dumb" as possible regarding business logic.
  - Utilizes Riverpod (`Notifier` / `AsyncNotifier`) to manage UI state.
- **Components:**
  - `features/[feature]/presentation/views/`: Flutter widgets (`ConsumerWidget` or `ConsumerStatefulWidget`) that render the UI based on state.
  - `features/[feature]/presentation/view_models/`: Riverpod Notifiers that hold UI state, interact with the Domain/Data layers, and expose data to the UI.

## 4. Core (Shared Layer)
Contains shared UI components, design tokens, and utilities used across multiple features.
- **Components:**
  - `core/widgets/`: Shared widgets like custom buttons, nav bars, etc.
  - `core/theme/`: Shared theming, colors, and typography.
  - `core/utils/`: Common utilities and helpers.

## Workflow Example (with Riverpod)
1. UI triggers a method on the ViewModel (e.g., `ref.read(homeViewModelProvider.notifier).loadData()`).
2. `Notifier` (ViewModel) reads a `Provider` to get a `Repository` or `UseCase`.
3. `Repository` (Data) fetches raw data from a `Service` (Data).
4. `Repository` maps raw Data models to clean Domain models.
5. `Repository` returns Domain models to the `Notifier`.
6. `Notifier` updates its `state` (e.g., `state = AsyncValue.data(stories)`).
7. UI automatically rebuilds because it is watching the provider.
