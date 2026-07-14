import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/startup/startup_platform.dart';

void main() {
  group('imageCacheBudget scales the TV image cache by device RAM', () {
    test('mobile is unchanged at 30 MB / 100 entries', () {
      final b = imageCacheBudget(isTV: false, ramTotalMb: 4096);
      expect(b.mb, 30);
      expect(b.entries, 100);
    });

    test('capable TV (>1.5 GB or unknown RAM) keeps the full 50 MB', () {
      expect(imageCacheBudget(isTV: true, ramTotalMb: 3072).mb, 50);
      expect(imageCacheBudget(isTV: true, ramTotalMb: 2048).mb, 50);
      // Unknown RAM (old native build) must not shrink a capable box.
      expect(imageCacheBudget(isTV: true, ramTotalMb: null).mb, 50);
    });

    test('mid TV (~1.5 GB) gets a trimmed 28 MB', () {
      final b = imageCacheBudget(isTV: true, ramTotalMb: 1409); // real device
      expect(b.mb, 28);
      expect(b.entries, 120);
    });

    test('weak TV (<=1 GB, the countdown_stall boxes) gets 16 MB', () {
      // 907 MB Changhong / 917 MB TCL from the Control Room stall reports.
      expect(imageCacheBudget(isTV: true, ramTotalMb: 907).mb, 16);
      expect(imageCacheBudget(isTV: true, ramTotalMb: 917).entries, 60);
      expect(imageCacheBudget(isTV: true, ramTotalMb: 1024).mb, 16);
    });

    test('the weakest box gets a strictly smaller budget than a capable one', () {
      expect(
        imageCacheBudget(isTV: true, ramTotalMb: 900).mb,
        lessThan(imageCacheBudget(isTV: true, ramTotalMb: 3000).mb),
      );
    });
  });
}
