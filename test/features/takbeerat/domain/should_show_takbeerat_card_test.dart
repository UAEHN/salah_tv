import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/takbeerat/domain/entities/eid_type.dart';
import 'package:ghasaq/features/takbeerat/domain/entities/eid_visibility.dart';
import 'package:ghasaq/features/takbeerat/domain/entities/hijri_snapshot.dart';
import 'package:ghasaq/features/takbeerat/domain/entities/takbeerat_config.dart';
import 'package:ghasaq/features/takbeerat/domain/i_hijri_date_provider.dart';
import 'package:ghasaq/features/takbeerat/domain/i_takbeerat_config_repository.dart';
import 'package:ghasaq/features/takbeerat/domain/usecases/should_show_takbeerat_card.dart';

void main() {
  final anyDate = DateTime(2026, 5, 18);

  group('kill switches', () {
    test('feature disabled → hidden even on Eid day', () async {
      final v = await ShouldShowTakbeeratCard(
        configRepo: _FakeConfigRepo(
          _config(enabled: false),
        ),
        hijri: _FakeHijri(_eidDay()),
      ).call(anyDate);
      expect(v.getOrElse(() => EidVisibility.hidden()).hasCard, isFalse);
    });

    test('forceHide wins over forceShow and Eid window', () async {
      final v = await ShouldShowTakbeeratCard(
        configRepo: _FakeConfigRepo(
          _config(enabled: true, hasForceHide: true, hasForceShow: true),
        ),
        hijri: _FakeHijri(_eidDay()),
      ).call(anyDate);
      expect(v.getOrElse(() => EidVisibility.hidden()).hasCard, isFalse);
    });

    test('forceShow surfaces card outside any window', () async {
      final v = await ShouldShowTakbeeratCard(
        configRepo: _FakeConfigRepo(_config(enabled: true, hasForceShow: true)),
        hijri: _FakeHijri(_ordinaryDay()),
      ).call(anyDate);
      final res = v.getOrElse(() => EidVisibility.hidden());
      expect(res.hasCard, isTrue);
      expect(res.isForcedByRemote, isTrue);
      expect(res.activeEid, isNull);
    });
  });

  group('Fitr window', () {
    test('last day of 30-day Ramadan → fitr', () async {
      final v = await _enabledRun(_hijri(month: 9, day: 30, length: 30));
      expect(v.activeEid, EidType.fitr);
    });

    test('last day of 29-day Ramadan → fitr', () async {
      final v = await _enabledRun(_hijri(month: 9, day: 29, length: 29));
      expect(v.activeEid, EidType.fitr);
    });

    test('28 Ramadan (30-day) → hidden when start offset is 1', () async {
      final v = await _enabledRun(_hijri(month: 9, day: 28, length: 30));
      expect(v.hasCard, isFalse);
    });

    test('1 Shawwal → fitr', () async {
      final v = await _enabledRun(_hijri(month: 10, day: 1, length: 29));
      expect(v.activeEid, EidType.fitr);
    });

    test('2 Shawwal with default end offset 0 → hidden', () async {
      final v = await _enabledRun(_hijri(month: 10, day: 2, length: 29));
      expect(v.hasCard, isFalse);
    });
  });

  group('Adha window', () {
    test('8 Dhul-Hijjah (Tarwiyah) → adha with start offset 2', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 8, length: 29));
      expect(v.activeEid, EidType.adha);
    });

    test('9 Dhul-Hijjah (Arafah) → adha', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 9, length: 29));
      expect(v.activeEid, EidType.adha);
    });

    test('10 Dhul-Hijjah → adha', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 10, length: 29));
      expect(v.activeEid, EidType.adha);
    });

    test('13 Dhul-Hijjah (last Tashreeq) → adha', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 13, length: 29));
      expect(v.activeEid, EidType.adha);
    });

    test('14 Dhul-Hijjah → hidden', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 14, length: 29));
      expect(v.hasCard, isFalse);
    });

    test('7 Dhul-Hijjah → hidden when start offset is 2', () async {
      final v = await _enabledRun(_hijri(month: 12, day: 7, length: 29));
      expect(v.hasCard, isFalse);
    });
  });

  test('ordinary day (15 Rajab) → hidden', () async {
    final v = await _enabledRun(_hijri(month: 7, day: 15, length: 29));
    expect(v.hasCard, isFalse);
  });
}

Future<EidVisibility> _enabledRun(HijriSnapshot snap) async {
  final result = await ShouldShowTakbeeratCard(
    configRepo: _FakeConfigRepo(_config(enabled: true)),
    hijri: _FakeHijri(snap),
  ).call(DateTime(2026));
  return result.getOrElse(() => EidVisibility.hidden());
}

TakbeeratConfig _config({
  bool enabled = true,
  bool hasForceHide = false,
  bool hasForceShow = false,
}) =>
    TakbeeratConfig(
      isFeatureEnabled: enabled,
      hasForceHide: hasForceHide,
      hasForceShow: hasForceShow,
      fitrStartOffsetDays: 1,
      fitrEndOffsetDays: 0,
      adhaStartOffsetDays: 2,
      adhaEndOffsetDays: 3,
      reciters: const [],
    );

HijriSnapshot _hijri({
  required int month,
  required int day,
  required int length,
}) =>
    HijriSnapshot(year: 1447, month: month, day: day, lengthOfMonth: length);

HijriSnapshot _eidDay() => _hijri(month: 10, day: 1, length: 29);
HijriSnapshot _ordinaryDay() => _hijri(month: 7, day: 15, length: 29);

class _FakeConfigRepo implements ITakbeeratConfigRepository {
  _FakeConfigRepo(this._cfg);
  final TakbeeratConfig _cfg;
  @override
  Future<Either<Failure, TakbeeratConfig>> fetchConfig() async => Right(_cfg);
}

class _FakeHijri implements IHijriDateProvider {
  _FakeHijri(this._snap);
  final HijriSnapshot _snap;
  @override
  HijriSnapshot fromGregorian(DateTime gregorian) => _snap;
}
