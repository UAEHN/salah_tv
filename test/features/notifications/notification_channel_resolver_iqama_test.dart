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

  test('default iqama maps to the bundled v2 channel, no content URI', () {
    final r = resolver.resolveIqama(const AppSettings());
    expect(r.channelId, NotificationChannelResolver.iqamaV2);
    expect(r.contentUri, isNull);
  });

  test('custom iqama maps to its own channel + content URI', () {
    final s = const AppSettings().copyWith(
      iqamaSound: 'custom:call.mp3',
      customIqamas: [custom('call.mp3', uri: 'content://media/42')],
    );
    final r = resolver.resolveIqama(s);
    expect(r.channelId, '${NotificationChannelResolver.iqamaCustomPrefix}call');
    expect(r.contentUri, 'content://media/42');
  });

  test('custom key with no matching file falls back to default', () {
    final s = const AppSettings().copyWith(
      iqamaSound: 'custom:gone.mp3',
      customIqamas: [custom('other.mp3')],
    );
    final r = resolver.resolveIqama(s);
    expect(r.channelId, NotificationChannelResolver.iqamaV2);
    expect(r.contentUri, isNull);
  });

  test('custom entry with empty content URI falls back to default', () {
    final s = const AppSettings().copyWith(
      iqamaSound: 'custom:call.mp3',
      customIqamas: [custom('call.mp3', uri: '')],
    );
    final r = resolver.resolveIqama(s);
    expect(r.channelId, NotificationChannelResolver.iqamaV2);
    expect(r.contentUri, isNull);
  });
}
