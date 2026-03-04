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
        PrayerEntry(name: 'الفجر', key: 'fajr', time: fajr),
        PrayerEntry(name: 'الشروق', key: 'sunrise', time: sunrise, isCountable: false),
        PrayerEntry(name: 'الظهر', key: 'dhuhr', time: dhuhr),
        PrayerEntry(name: 'العصر', key: 'asr', time: asr),
        PrayerEntry(name: 'المغرب', key: 'maghrib', time: maghrib),
        PrayerEntry(name: 'العشاء', key: 'isha', time: isha),
      ];

  List<PrayerEntry> get prayersOnly => prayers.where((p) => p.isCountable).toList();
}

class PrayerEntry {
  final String name;
  final String key;
  final DateTime time;
  final bool isCountable;

  const PrayerEntry({
    required this.name,
    required this.key,
    required this.time,
    this.isCountable = true,
  });
}
