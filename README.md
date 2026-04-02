# salah_tv

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Optional Telegram Feedback Alerts

Feedback can optionally send a Telegram notification after saving to Firestore.
Do not hardcode secrets in source code. Pass them at build/run time:

```bash
flutter run --dart-define=TELEGRAM_BOT_TOKEN=xxx --dart-define=TELEGRAM_CHAT_ID=yyy
```

If these defines are missing, Firestore submit still works and Telegram notify is skipped.

For a one-time local setup, use `env/dev.example.json` (see `env/README.md`).
