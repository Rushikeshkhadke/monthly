# architecture.md - Software Architecture for Monthly

## 1. Architectural Philosophy
Monthly follows **Clean Architecture & Feature-Driven Layering** with strict local-first, zero-network guarantees:
- **Presentation Layer:** Flutter Widgets (Material 3 with custom tokens), responsive layouts, smooth animations.
- **Application / State Management:** Riverpod (`flutter_riverpod`) or BLoC (`flutter_bloc`) for predictable reactive state without tight coupling.
- **Domain Layer:** Pure Dart entities, use-cases, and mathematical prediction calculations (zero external dependencies, fully unit testable).
- **Data Layer:** SQLite (`sqflite` or `drift`) repository implementations, secure local storage (`flutter_secure_storage`), local notification services.

---

## 2. Directory Structure

```
monthly/
├── lib/
│   ├── app/
│   │   ├── app.dart                   # Root MaterialApp with themes & routing
│   │   ├── router.dart                # App navigation & route guards (PIN lock)
│   │   └── theme/                     # Colors, typography, shapes matching design.md
│   │       ├── app_colors.dart
│   │       ├── app_typography.dart
│   │       └── app_theme.dart
│   ├── core/
│   │   ├── database/                  # SQLite db helper, migrations, table definitions
│   │   │   ├── app_database.dart
│   │   │   └── migrations.dart
│   │   ├── math/                      # Deterministic statistical cycle prediction engine
│   │   │   ├── cycle_predictor.dart
│   │   │   └── statistics_helper.dart
│   │   ├── security/                  # Biometrics, PIN hashing, app disguise facade
│   │   │   ├── app_lock_service.dart
│   │   │   └── backup_cipher.dart
│   │   ├── notifications/             # Local OS scheduled notifications
│   │   │   └── local_notification_service.dart
│   │   └── utils/                     # Date formatters, extensions
│   ├── features/
│   │   ├── onboarding/                # Intro screens & initial cycle survey
│   │   ├── today/                     # Home screen: Circular cycle dial, quick log, daily tip
│   │   ├── calendar/                  # Calendar month grid, phase dots, cycle progress
│   │   ├── logging/                   # Log day bottom sheet (flow, mood, symptoms, notes)
│   │   ├── insights/                  # Statistics, cycle variation, symptom charts
│   │   ├── learn/                     # Offline articles, search & category filters
│   │   ├── settings/                  # Me tab, cycle settings, trackers, appearance
│   │   ├── doctor_report/             # Health report summary & PDF exporter
│   │   └── privacy/                   # Disguise mode, app lock, encrypted export
│   └── main.dart                      # App entry point (lock verification + init)
├── assets/
│   ├── icons/                         # Custom SVG icons (flow droplets, cycle phases)
│   ├── illustrations/                 # Vector/PNG art for onboarding and education
│   └── articles/                      # Bundled offline medical educational markdown files
├── test/
│   ├── unit/                          # Unit tests for cycle math & prediction formulas
│   └── widget/                        # UI and interaction tests
└── pubspec.yaml
```

---

## 3. Security & Disguise Mode Architecture
1. **Authentication Gate:**
   - On app startup or resume from background, if `app_lock_enabled == 1`, render `LockScreen` overlay before any medical data is populated into state.
   - Supports Biometric (`local_auth`) and fallback 4-digit PIN (`flutter_secure_storage`).
2. **Disguise Facade:**
   - When enabled, app icon and launch activity mimics a functional Calculator.
   - Entering a specific passcode or calculation equation unmasks the actual Monthly tracker interface.
3. **Zero Network Traffic Guarantee:**
   - Manifest permissions do not include unnecessary internet access where possible, ensuring complete user peace of mind.
