enum HeroCardMode { nextPrayer, iqama }

/// Which hero-card face the TV home view shows: the iqama countdown while one is
/// active, otherwise the next-prayer card. Morning/evening adhkar now render as
/// the full-screen `AdhkarTakeoverScreen` takeover, not a hero-card mode.
class HeroCardModel {
  final HeroCardMode mode;

  const HeroCardModel._(this.mode);

  const HeroCardModel.nextPrayer() : this._(HeroCardMode.nextPrayer);
  const HeroCardModel.iqama() : this._(HeroCardMode.iqama);
}

class HeroCardLogic {
  const HeroCardLogic();

  HeroCardModel mapFields({required bool isIqamaCountdown}) => isIqamaCountdown
      ? const HeroCardModel.iqama()
      : const HeroCardModel.nextPrayer();
}
