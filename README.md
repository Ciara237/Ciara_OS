# ciaraos

Ciara OS — personal productivity app (local-only v1).

## Project structure

```
lib/
├── main.dart
├── database/              # Drift schema + generated code
├── models/                # Domain types + enums
├── repositories/          # Data access (Drift queries)
├── providers/             # Riverpod wiring
├── services/              # App-level services (e.g. OnboardingNotifier)
│                          # — not repositories or providers
├── router/                # GoRouter configuration
├── screens/
│   ├── primary/           # Main shell destinations
│   └── secondary/         # Detail, create/edit, onboarding, etc.
├── widgets/               # Reusable UI components
└── theme/                 # Colors, typography, spacing, ThemeData
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
