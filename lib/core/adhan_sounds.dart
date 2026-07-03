/// Single source of truth for available adhan sounds.
/// To add a new adhan: add an entry here and register the asset in pubspec.yaml.
const kAdhanSounds = [
  (key: 'default', label: 'Adhan 1', asset: 'audio/adhan.mp3'),
  (key: 'adhan2', label: 'Adhan 2', asset: 'audio/adhan2.mp3'),
];

/// Bundled default iqama asset (selection key `'default'`).
const kIqamaDefaultAsset = 'audio/iqama.mp3';

/// Preview-only key for the bundled iqama sound. The iqama *selection* key is
/// `'default'`, which the shared sound resolver maps to the default *adhan*
/// asset — so the picker passes this distinct key when previewing the default
/// iqama so the iqama clip plays instead.
const kIqamaDefaultPreviewKey = 'iqama_default';
