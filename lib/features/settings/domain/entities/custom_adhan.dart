/// A user-imported adhan sound.
///
/// The source file is copied into the app's private `custom_adhans/` folder
/// at import time (for preview/foreground playback via [AudioService]) and
/// also published to MediaStore as a system notification sound — [contentUri]
/// is the globally-readable `content://media/...` URI handed to notification
/// channels. This dual-storage is the only reliable way to get a user-picked
/// audio file to play for a scheduled notification across Android versions
/// and OEMs, since URI permission grants to the notification subsystem are
/// unreliable.
class CustomAdhan {
  /// Unique id (microsecond timestamp in base36).
  final String id;

  /// User-editable display name shown in the adhan picker.
  final String label;

  /// Basename inside the app's `custom_adhans/` directory (e.g. `abc123.mp3`).
  final String fileName;

  /// `content://media/external/audio/...` URI returned by MediaStore after
  /// publishing the file with `IS_NOTIFICATION=1`. Consumed by notification
  /// channels directly as [UriAndroidNotificationSound].
  final String contentUri;

  const CustomAdhan({
    required this.id,
    required this.label,
    required this.fileName,
    required this.contentUri,
  });

  CustomAdhan copyWith({String? label}) => CustomAdhan(
    id: id,
    label: label ?? this.label,
    fileName: fileName,
    contentUri: contentUri,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fileName': fileName,
    'contentUri': contentUri,
  };

  factory CustomAdhan.fromJson(Map<String, dynamic> json) => CustomAdhan(
    id: json['id'] as String,
    label: json['label'] as String,
    fileName: json['fileName'] as String,
    contentUri: (json['contentUri'] as String?) ?? '',
  );

  /// Key format stored in [AppSettings.adhanSound] for custom sounds.
  /// Embeds the [fileName] so playback can resolve the file without reading
  /// the settings list (avoids coupling [AudioService] to settings).
  static const String keyPrefix = 'custom:';

  /// Returns the [fileName] embedded in [settingsKey] if it's a custom-adhan
  /// key, else null.
  static String? extractFileName(String settingsKey) =>
      settingsKey.startsWith(keyPrefix)
          ? settingsKey.substring(keyPrefix.length)
          : null;

  String get settingsKey => '$keyPrefix$fileName';
}
