# Env Files

Create your local file:

1. Copy `dev.example.json` to `dev.json`
2. Put real values in `dev.json`

Run app with:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Build release with:

```bash
flutter build apk --release --dart-define-from-file=env/dev.json
```

`dev.json` is ignored by git.
