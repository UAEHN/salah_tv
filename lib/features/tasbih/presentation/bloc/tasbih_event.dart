sealed class TasbihEvent {
  const TasbihEvent();
}

class TasbihStarted extends TasbihEvent {
  const TasbihStarted();
}

class TasbihTapped extends TasbihEvent {
  const TasbihTapped();
}

class TasbihReset extends TasbihEvent {
  const TasbihReset();
}

class TasbihPresetChanged extends TasbihEvent {
  final int presetIndex;
  const TasbihPresetChanged(this.presetIndex);
}
