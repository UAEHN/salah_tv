import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/health/health_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save → load round-trips the anchor', () async {
    final store = HealthStateStore();
    await store.saveAnchor(
      const SequenceAnchor(
        prayerKey: 'asr',
        dateKey: '2026-07-03',
        sessionId: 's1',
      ),
    );
    final loaded = await store.loadAnchor();
    expect(loaded?.prayerKey, 'asr');
    expect(loaded?.dateKey, '2026-07-03');
    expect(loaded?.sessionId, 's1');
  });

  test('loadAnchor returns null when nothing is stored', () async {
    expect(await HealthStateStore().loadAnchor(), isNull);
  });

  test('clearAnchor removes the persisted anchor', () async {
    final store = HealthStateStore();
    await store.saveAnchor(
      const SequenceAnchor(
        prayerKey: 'isha',
        dateKey: '2026-07-03',
        sessionId: 's1',
      ),
    );
    await store.clearAnchor();
    expect(await store.loadAnchor(), isNull);
  });

  test('a partial record (missing session) loads as null', () async {
    SharedPreferences.setMockInitialValues({
      'health.seq.prayer': 'asr',
      'health.seq.date': '2026-07-03',
    });
    expect(await HealthStateStore().loadAnchor(), isNull);
  });
}
