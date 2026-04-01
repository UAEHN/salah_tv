import 'package:flutter/foundation.dart';

@immutable
class TasbihPreset {
  final String key;
  final int target;

  const TasbihPreset({required this.key, required this.target});
}

const kTasbihPresets = [
  TasbihPreset(key: 'subhanallah', target: 33),
  TasbihPreset(key: 'alhamdulillah', target: 33),
  TasbihPreset(key: 'allahuakbar', target: 33),
  TasbihPreset(key: 'lailahaillallah', target: 100),
];
