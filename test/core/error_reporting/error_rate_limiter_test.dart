import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/policy/error_rate_limiter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('per-fingerprint session cap', () async {
    final limiter = ErrorRateLimiter(
      perFingerprintPerSession: 2,
      perSession: 100,
      perDay: 100,
    );
    expect(await limiter.allow('fp_a'), isTrue);
    expect(await limiter.allow('fp_a'), isTrue);
    expect(await limiter.allow('fp_a'), isFalse);
    expect(await limiter.allow('fp_b'), isTrue);
  });

  test('per-session total cap across fingerprints', () async {
    final limiter = ErrorRateLimiter(
      perFingerprintPerSession: 10,
      perSession: 3,
      perDay: 100,
    );
    expect(await limiter.allow('a'), isTrue);
    expect(await limiter.allow('b'), isTrue);
    expect(await limiter.allow('c'), isTrue);
    expect(await limiter.allow('d'), isFalse);
  });

  test('daily cap persists and resets on day rollover', () async {
    var now = DateTime(2026, 7, 3, 22);
    final limiter = ErrorRateLimiter(
      perFingerprintPerSession: 10,
      perSession: 100,
      perDay: 2,
      clock: () => now,
    );
    expect(await limiter.allow('a'), isTrue);
    expect(await limiter.allow('b'), isTrue);
    expect(await limiter.allow('c'), isFalse);

    // Midnight passes — the persisted day key changes and the count resets.
    now = DateTime(2026, 7, 4, 0, 5);
    expect(await limiter.allow('c'), isTrue);
  });

  test('daily counter survives a "restart" (new limiter instance)', () async {
    final clock = DateTime(2026, 7, 3);
    final first = ErrorRateLimiter(perDay: 2, clock: () => clock);
    expect(await first.allow('a'), isTrue);
    expect(await first.allow('b'), isTrue);

    final second = ErrorRateLimiter(perDay: 2, clock: () => clock);
    expect(await second.allow('c'), isFalse);
  });
}
