import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/prayer/data/adhan_calculation_source.dart';

void main() {
  test('compute Liege times today and compare to screenshot', () {
    final src = AdhanCalculationSource();
    for (final day in [DateTime(2026, 6, 23), DateTime(2026, 6, 24)]) {
      final t = src.calculateForDate(
        50.6326,
        5.5797,
        day,
        'france',
        timeZoneId: 'Europe/Brussels',
      );
      String f(DateTime d) =>
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      // ignore: avoid_print
      print(
        '$day  fajr=${f(t.fajr)} sunrise=${f(t.sunrise)} '
        'dhuhr=${f(t.dhuhr)} asr=${f(t.asr)} '
        'maghrib=${f(t.maghrib)} isha=${f(t.isha)} '
        'valid=${AdhanCalculationSource.isValid(t)}',
      );
    }
    // Screenshot showed: Fajr 04:48 Sunrise 06:44 Dhuhr 14:09 Asr 18:03 Maghrib 21:32 Isha 23:20
  });
}
