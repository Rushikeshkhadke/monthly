# AGENTS.md - Development Rules & Guidelines for Monthly

Welcome to **Monthly**. As an AI pair-programmer or coding agent, adhere to the following strict rules:

## 1. Zero Network / Zero Telemetry Rule
- NEVER add third-party analytics, crashlytics, or cloud sync services that require external network servers unless explicitly requested.
- Ensure all storage remains 100% on-device (SQLite, local files, `flutter_secure_storage`).
- All prediction logic MUST remain on-device statistical math. DO NOT make network calls or import heavy LLM packages.

## 2. Design Integrity & Pixel Consistency
- Always refer to `design.md` for color hex codes, corner radii, and spacing tokens.
- Maintain soft, rounded corners on buttons and cards (`BorderRadius.circular(16)` to `BorderRadius.circular(24)`).
- Ensure high accessibility: strong contrast between text and background, support for dynamic font scaling.
- Maintain consistent bottom navigation across all 5 primary tabs: Today, Calendar, Insights, Learn, Me.

## 3. Code Standards & Architecture
- Maintain strict separation of concerns following `architecture.md`.
- Keep widgets small and composable; extract reusable components into feature `widgets/` folders.
- Write pure unit tests for any modifications to the cycle prediction engine (`cycle_predictor.dart`).
- Avoid global mutable state. Use structured state management (`flutter_riverpod`).

## 4. Error Handling & Privacy
- If an encrypted backup fails, never log sensitive cycle data or symptom contents to standard console logs in production builds.
- Sanitize any file operations and gracefully handle permissions for storage and biometric authentication.
