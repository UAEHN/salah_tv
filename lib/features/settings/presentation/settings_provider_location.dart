part of 'settings_provider.dart';

extension SettingsProviderLocation on SettingsProvider {
  Future<void> updateSelectedCountry(String country) =>
      _update(_settings.copyWith(selectedCountry: country));

  Future<void> updateSelectedCity(String city) =>
      _update(_settings.copyWith(selectedCity: city));

  Future<void> updateLocation(String country, String city) => _update(
    _settings.copyWith(
      selectedCountry: country,
      selectedCity: city,
      isCalculatedLocation: false,
      clearSelectedTimeZoneId: true,
      clearUtcOffset: true,
    ),
  );

  Future<void> updateWorldLocation(
    String country,
    String city,
    double lat,
    double lng,
    String method, {
    String? timeZoneId,
    double? utcOffsetHours,
  }) => _update(
    _settings.copyWith(
      selectedCountry: country,
      selectedCity: city,
      selectedLatitude: lat,
      selectedLongitude: lng,
      calculationMethod: method,
      isCalculatedLocation: true,
      selectedTimeZoneId: timeZoneId,
      clearSelectedTimeZoneId: timeZoneId == null,
      utcOffsetHours: utcOffsetHours,
      clearUtcOffset: utcOffsetHours == null,
    ),
  );

  Future<void> updateCalculationMethod(String methodKey) =>
      _update(_settings.copyWith(calculationMethod: methodKey));

  Future<void> updateMadhab(String madhabKey) =>
      _update(_settings.copyWith(madhab: madhabKey));

  Future<void> updateHighLatitudeRule(String ruleKey) =>
      _update(_settings.copyWith(highLatitudeRule: ruleKey));

  Future<void> updateIqamaDelay(String prayerKey, int minutes) {
    final delays = Map<String, int>.from(_settings.iqamaDelays);
    delays[prayerKey] = minutes.clamp(0, 60);
    return _update(_settings.copyWith(iqamaDelays: delays));
  }

  Future<void> updateAdhanOffset(String prayerKey, int minutes) {
    final offsets = Map<String, int>.from(_settings.adhanOffsets);
    offsets[prayerKey] = minutes.clamp(-30, 30);
    return _update(_settings.copyWith(adhanOffsets: offsets));
  }
}
