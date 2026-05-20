import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/today/domain/entities/greeting.dart';
import 'package:ghasaq/features/today/domain/usecases/get_current_greeting.dart';

void main() {
  const useCase = GetCurrentGreetingUseCase();

  group('GetCurrentGreetingUseCase', () {
    test('00:00 → morning', () {
      final g = useCase(now: DateTime(2026, 5, 7));
      expect(g.period, GreetingPeriod.morning);
      expect(g.titleKey, 'greetingMorningTitle');
      expect(g.subtitleKey, 'greetingMorningSubtitle');
    });

    test('05:00 → morning', () {
      final g = useCase(now: DateTime(2026, 5, 7, 5));
      expect(g.period, GreetingPeriod.morning);
    });

    test('11:59 → still morning', () {
      final g = useCase(now: DateTime(2026, 5, 7, 11, 59));
      expect(g.period, GreetingPeriod.morning);
    });

    test('12:00 → evening (boundary)', () {
      final g = useCase(now: DateTime(2026, 5, 7, 12));
      expect(g.period, GreetingPeriod.evening);
      expect(g.titleKey, 'greetingEveningTitle');
      expect(g.subtitleKey, 'greetingEveningSubtitle');
    });

    test('19:00 → evening', () {
      final g = useCase(now: DateTime(2026, 5, 7, 19));
      expect(g.period, GreetingPeriod.evening);
    });

    test('23:59 → still evening', () {
      final g = useCase(now: DateTime(2026, 5, 7, 23, 59));
      expect(g.period, GreetingPeriod.evening);
    });
  });
}
