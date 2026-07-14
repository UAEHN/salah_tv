import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/audio/data/quran_audio_service.dart';

void main() {
  group('QuranAudioService.retryBackoff', () {
    test('first failure uses the 8s base delay', () {
      expect(QuranAudioService.retryBackoff(0), const Duration(seconds: 8));
    });

    test('doubles each consecutive failure', () {
      expect(QuranAudioService.retryBackoff(1), const Duration(seconds: 16));
      expect(QuranAudioService.retryBackoff(2), const Duration(seconds: 32));
      expect(QuranAudioService.retryBackoff(3), const Duration(seconds: 64));
    });

    test('caps at 5 minutes so a dead network never hammers the CDN', () {
      expect(QuranAudioService.retryBackoff(100), const Duration(minutes: 5));
      // The cap must be reached and never exceeded.
      for (var n = 6; n < 40; n++) {
        expect(
          QuranAudioService.retryBackoff(n),
          lessThanOrEqualTo(const Duration(minutes: 5)),
        );
      }
    });

    test('negative input is treated as the base delay (defensive)', () {
      expect(QuranAudioService.retryBackoff(-3), const Duration(seconds: 8));
    });
  });
}
