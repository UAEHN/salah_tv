import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/prayer/domain/prayer_time_zone.dart';

void main() {
  group('PrayerTimeZone', () {
    test('keeps device local time when no target offset is provided', () {
      final now = DateTime(2026, 4, 13, 12, 30);

      final resolved = PrayerTimeZone.resolve(now);

      expect(resolved, now);
    });

    test('converts device time to target city offset', () {
      final emiratesNow = DateTime.utc(2026, 4, 13, 8, 0);

      final algeriaNow = PrayerTimeZone.resolve(
        emiratesNow,
        utcOffsetHours: 1,
      );

      expect(algeriaNow, DateTime(2026, 4, 13, 9, 0));
    });

    test('supports half-hour offsets', () {
      final utcNow = DateTime.utc(2026, 4, 13, 0, 0);

      final kabulNow = PrayerTimeZone.fromUtc(utcNow, utcOffsetHours: 4.5);

      expect(kabulNow, DateTime(2026, 4, 13, 4, 30));
    });
  });
}
