import '../../../adhkar/domain/adhkar_eligibility.dart';
import '../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'prayer_state.dart';

enum HeroCardMode { nextPrayer, adhkar, iqama }

class HeroCardModel {
  final HeroCardMode mode;
  final AdhkarSession session;

  const HeroCardModel._({required this.mode, required this.session});

  const HeroCardModel.nextPrayer()
    : this._(mode: HeroCardMode.nextPrayer, session: AdhkarSession.none);

  const HeroCardModel.iqama()
    : this._(mode: HeroCardMode.iqama, session: AdhkarSession.none);

  const HeroCardModel.adhkar(AdhkarSession session)
    : this._(mode: HeroCardMode.adhkar, session: session);
}

class HeroCardLogic {
  final IAdhkarStateRepository _repo;

  const HeroCardLogic(this._repo);

  HeroCardModel mapState({
    required PrayerState prayer,
    required AppSettings settings,
  }) => mapFields(
    isIqamaCountdown: prayer.isIqamaCountdown,
    nextPrayerKey: prayer.nextPrayerKey,
    isCycleActive: prayer.isCycleActive,
    countdownSeconds: prayer.countdown.inSeconds,
    isAdhkarEnabled: settings.isAdhkarEnabled,
  );

  /// Field-based variant used by widgets that select narrow state slices.
  HeroCardModel mapFields({
    required bool isIqamaCountdown,
    required String nextPrayerKey,
    required bool isCycleActive,
    required int countdownSeconds,
    required bool isAdhkarEnabled,
  }) {
    if (isIqamaCountdown) return const HeroCardModel.iqama();

    final session = sessionFromNextPrayer(nextPrayerKey);
    final isAdhkarActive = isAdhkarEligible(
      session: session,
      repo: _repo,
      isAdhkarEnabled: isAdhkarEnabled,
      isCycleActive: isCycleActive,
      nextPrayerKey: nextPrayerKey,
      countdownSeconds: countdownSeconds,
    );

    if (isAdhkarActive) return HeroCardModel.adhkar(session);
    return const HeroCardModel.nextPrayer();
  }

  bool shouldStartMorningSession(PrayerState prev, PrayerState curr) {
    final prevOpen =
        sessionFromNextPrayer(prev.nextPrayerKey) == AdhkarSession.morning &&
        prev.countdown.inSeconds > 15 * 60;
    final currClosed =
        sessionFromNextPrayer(curr.nextPrayerKey) != AdhkarSession.morning ||
        curr.countdown.inSeconds <= 15 * 60;
    return prevOpen && currClosed;
  }

  void startMorningSessionIfNeeded() {
    if (!_repo.hasMorningAdhkarShownToday()) {
      _repo.startMorningSession();
    }
  }
}
