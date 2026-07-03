import '../../../core/adhan_sounds.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/domain/entities/custom_adhan.dart';

/// Maps an [AppSettings.adhanSound] selection to the Android channel id
/// the native engine should post on. Mirrors the Kotlin
/// `NotificationChannelIds` constants exactly so per-channel preferences
/// (sound, importance, DND bypass) survive across migrations.
class NotificationChannelResolver {
  static const adhanPrefix = 'prayer_times_v5_';
  static const adhanCustomPrefix = 'prayer_times_v5_custom_';
  static const preAdhan = 'prayer_reminder_v1';
  static const iqama = 'prayer_iqama_v1';
  // v2 = the sounded iqama channel (default `iqama.mp3` or a custom import).
  static const iqamaV2 = 'prayer_iqama_v2';
  static const iqamaCustomPrefix = 'prayer_iqama_v2_custom_';
  static const preIqama = 'prayer_pre_iqama_v1';
  static const adhkar = 'adhkar_reminder_v1';
  static const alKahf = 'al_kahf_reminder_v1';

  /// Returns the channel id for the adhan + an optional content URI for
  /// the custom-channel registration the engine performs at sync time.
  ({String channelId, String? contentUri}) resolveAdhan(AppSettings s) {
    final fileName = CustomAdhan.extractFileName(s.adhanSound);
    if (fileName != null) {
      final entry = s.customAdhans
          .where((c) => c.fileName == fileName)
          .toList(growable: false);
      if (entry.isNotEmpty && entry.first.contentUri.isNotEmpty) {
        final stem = _stripExtension(fileName);
        return (
          channelId: '$adhanCustomPrefix$stem',
          contentUri: entry.first.contentUri,
        );
      }
    }
    final fallback = kAdhanSounds.firstWhere(
      (a) => a.key == s.adhanSound,
      orElse: () => kAdhanSounds.first,
    );
    final raw = _rawName(fallback.asset);
    return (channelId: '$adhanPrefix$raw', contentUri: null);
  }

  /// Returns the channel id for the iqama + an optional content URI for the
  /// custom-channel registration the engine performs at sync time. Mirrors
  /// [resolveAdhan]; iqama has a single built-in (`iqama.mp3`) so a non-custom
  /// selection always maps to the bundled [iqamaV2] channel.
  ({String channelId, String? contentUri}) resolveIqama(AppSettings s) {
    final fileName = CustomAdhan.extractFileName(s.iqamaSound);
    if (fileName != null) {
      final entry = s.customIqamas
          .where((c) => c.fileName == fileName)
          .toList(growable: false);
      if (entry.isNotEmpty && entry.first.contentUri.isNotEmpty) {
        final stem = _stripExtension(fileName);
        return (
          channelId: '$iqamaCustomPrefix$stem',
          contentUri: entry.first.contentUri,
        );
      }
    }
    return (channelId: iqamaV2, contentUri: null);
  }

  static String _rawName(String asset) =>
      asset.split('/').last.replaceAll(RegExp(r'\.\w+$'), '');

  static String _stripExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }
}
