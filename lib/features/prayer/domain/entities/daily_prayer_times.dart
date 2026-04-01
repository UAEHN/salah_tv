class DailyPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerEntry> get prayers => [
    PrayerEntry(key: 'fajr', time: fajr),
    PrayerEntry(key: 'sunrise', time: sunrise, isCountable: false),
    PrayerEntry(key: 'dhuhr', time: dhuhr),
    PrayerEntry(key: 'asr', time: asr),
    PrayerEntry(key: 'maghrib', time: maghrib),
    PrayerEntry(key: 'isha', time: isha),
  ];

  List<PrayerEntry> get prayersOnly =>
      prayers.where((p) => p.isCountable).toList();
}

class PrayerEntry {
  final String key;
  final DateTime time;
  final bool isCountable;

  const PrayerEntry({
    required this.key,
    required this.time,
    this.isCountable = true,
  });
}
