import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/notifications/data/notification_channel_resolver.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_copy_with.dart';
import 'package:ghasaq/features/settings/domain/entities/custom_adhan.dart';

void main() {
  final resolver = NotificationChannelResolver();
  CustomAdhan custom(String fileName, {String? uri}) => CustomAdhan(
    id: 'id',
    label: 'l',
    fileName: fileName,
    contentUri: uri ?? 'content://x/$fileName',
  );

  test('silent selection keeps the built-in silent pre-adhan channel', () {
    final r = resolver.resolvePreAdhan(const AppSettings(), 'fajr');
    expect(r.channelId, NotificationChannelResolver.preAdhan);
    expect(r.contentUri, isNull);
  });

  test('custom per-prayer sound maps to its own sounded channel + URI', () {
    final s = const AppSettings().copyWith(
      customAdhans: [custom('call.mp3', uri: 'content://media/42')],
      preAdhanReminderSound: {'fajr': 'custom:call.mp3'},
    );
    final r = resolver.resolvePreAdhan(s, 'fajr');
    expect(
      r.channelId,
      '${NotificationChannelResolver.preAdhanCustomPrefix}call',
    );
    expect(r.contentUri, 'content://media/42');
  });

  test('a prayer left silent still resolves to the silent channel', () {
    final s = const AppSettings().copyWith(
      customAdhans: [custom('call.mp3', uri: 'content://media/42')],
      preAdhanReminderSound: {'fajr': 'custom:call.mp3'},
    );
    final r = resolver.resolvePreAdhan(s, 'dhuhr');
    expect(r.channelId, NotificationChannelResolver.preAdhan);
    expect(r.contentUri, isNull);
  });

  test('custom key with no matching file falls back to silent', () {
    final s = const AppSettings().copyWith(
      customAdhans: [custom('other.mp3')],
      preAdhanReminderSound: {'fajr': 'custom:gone.mp3'},
    );
    final r = resolver.resolvePreAdhan(s, 'fajr');
    expect(r.channelId, NotificationChannelResolver.preAdhan);
    expect(r.contentUri, isNull);
  });

  test('custom entry with empty content URI falls back to silent', () {
    final s = const AppSettings().copyWith(
      customAdhans: [custom('call.mp3', uri: '')],
      preAdhanReminderSound: {'fajr': 'custom:call.mp3'},
    );
    final r = resolver.resolvePreAdhan(s, 'fajr');
    expect(r.channelId, NotificationChannelResolver.preAdhan);
    expect(r.contentUri, isNull);
  });
}
