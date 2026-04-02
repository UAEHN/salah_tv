import 'package:flutter/material.dart';

const mobilePrayerIcons = <String, IconData>{
  'fajr': Icons.wb_twilight_rounded,
  'dhuhr': Icons.wb_sunny_rounded,
  'asr': Icons.brightness_medium_rounded,
  'maghrib': Icons.nights_stay_rounded,
  'isha': Icons.bedtime_rounded,
};

const mobilePrayerAccentPairs = <String, (Color, Color)>{
  'fajr': (Color(0xFFE8C77A), Color(0xFFD4A843)),
  'dhuhr': (Color(0xFFE8C77A), Color(0xFFD4A843)),
  'asr': (Color(0xFFE8C77A), Color(0xFFD4A843)),
  'maghrib': (Color(0xFFE8C77A), Color(0xFFD4A843)),
  'isha': (Color(0xFFE8C77A), Color(0xFFD4A843)),
};
