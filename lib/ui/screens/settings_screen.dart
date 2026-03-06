import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/city_translations.dart';
import '../../models/quran_reciter.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/audio_service.dart';
import '../../services/csv_service.dart';
import '../../services/quran_api_service.dart';

part 'settings/tv_buttons.dart';
part 'settings/tv_chips.dart';
part 'settings/quran_widgets.dart';
part 'settings/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient()),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: palette.gradient,
                    boxShadow: [
                      BoxShadow(
                        color: palette.glow,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _TvButton(
                        autofocus: true,
                        onPressed: () => Navigator.pop(context),
                        accent: palette.primary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'رجوع',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'الإعدادات',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === COUNTRY & CITY SELECTOR ===
                        _SectionTitle(title: 'الدولة والمدينة'),
                        const SizedBox(height: 12),
                        _countrySection(context, settingsProv, palette),
                        const SizedBox(height: 12),
                        _citySection(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === QURAN BACKGROUND AUDIO ===
                        _SectionTitle(title: 'القرآن الكريم في الخلفية'),
                        const SizedBox(height: 12),
                        _quranSection(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === ADHAN OFFSETS ===
                        _SectionTitle(title: 'تعديل أوقات الأذان (± دقائق)'),
                        const SizedBox(height: 12),
                        _adhanOffsetsTable(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === IQAMA DELAYS ===
                        _SectionTitle(
                          title: 'أوقات الإقامة (دقائق بعد الأذان)',
                        ),
                        const SizedBox(height: 12),
                        _iqamaTable(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === FONT FAMILY ===
                        _SectionTitle(title: 'الخط'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children:
                              const [
                                ('Cairo', 'كايرو'),
                                ('Tajawal', 'تجوال'),
                                ('Beiruti', 'بيروتي'),
                              ].map((f) {
                                final key = f.$1;
                                final label = f.$2;
                                final isSelected = settings.fontFamily == key;
                                return _TvFontChip(
                                  fontKey: key,
                                  label: label,
                                  isSelected: isSelected,
                                  palette: palette,
                                  onPressed: () =>
                                      settingsProv.updateFontFamily(key),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 28),

                        // === THEME COLOR ===
                        _SectionTitle(title: 'لون القالب'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: kThemePalettes.entries.map((e) {
                            final isSelected = settings.themeColorKey == e.key;
                            final label = kThemeLabels[e.key] ?? e.key;
                            return _TvColorChip(
                              palette: e.value,
                              label: label,
                              isSelected: isSelected,
                              onPressed: () => settingsProv.updateTheme(e.key),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 28),

                        // === DARK MODE ===
                        _SectionTitle(title: 'المظهر'),
                        const SizedBox(height: 12),
                        _TvSwitchRow(
                          value: settings.isDarkMode,
                          accent: palette.primary,
                          onChanged: (v) => settingsProv.updateDarkMode(v),
                          children: [
                            Icon(
                              settings.isDarkMode
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              color: settings.isDarkMode
                                  ? const Color(0xFF6A7494)
                                  : const Color(0xFFF59E0B),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'الوضع الليلي:',
                              style: TextStyle(
                                fontSize: 20,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: settings.isDarkMode,
                              activeTrackColor: const Color(0xFF162035),
                              activeColor: const Color(0xFFB8C0D8),
                              inactiveTrackColor: kTextMuted.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: WidgetStateProperty.all(Colors.white),
                              onChanged: (v) => settingsProv.updateDarkMode(v),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              settings.isDarkMode ? 'مفعّل' : 'معطّل',
                              style: TextStyle(
                                fontSize: 20,
                                color: settings.isDarkMode
                                    ? kDarkTextSecondary
                                    : kTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // === PLAY ADHAN ===
                        _SectionTitle(title: 'الأذان'),
                        const SizedBox(height: 12),
                        _TvSwitchRow(
                          value: settings.playAdhan,
                          accent: palette.primary,
                          onChanged: (v) => settingsProv.updatePlayAdhan(v),
                          children: [
                            Text(
                              'تشغيل الأذان تلقائياً:',
                              style: TextStyle(
                                fontSize: 20,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: settings.playAdhan,
                              activeTrackColor: palette.primary,
                              inactiveTrackColor: kTextMuted.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: WidgetStateProperty.all(Colors.white),
                              onChanged: (v) => settingsProv.updatePlayAdhan(v),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              settings.playAdhan ? 'مفعّل' : 'معطّل',
                              style: TextStyle(
                                fontSize: 20,
                                color: settings.playAdhan
                                    ? palette.primary
                                    : kTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        if (settings.playAdhan) ...[
                          const SizedBox(height: 16),
                          _SectionTitle(title: 'صوت الأذان'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: glassDecoration(
                                    opacity: 0.06,
                                    borderRadius: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.volume_up_rounded,
                                        color: palette.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          AudioService.adhanSounds
                                              .firstWhere(
                                                (s) =>
                                                    s.key ==
                                                    settings.adhanSound,
                                                orElse: () => AudioService
                                                    .adhanSounds
                                                    .first,
                                              )
                                              .label,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: kTextPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _TvButton(
                                onPressed: () => _showAdhanSoundPicker(
                                  context,
                                  settingsProv,
                                  palette,
                                ),
                                accent: palette.primary,
                                filled: true,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تغيير الأذان',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 28),

                        // === TIME FORMAT ===
                        _SectionTitle(title: 'تنسيق الوقت'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _TvFormatButton(
                              label: '24 ساعة',
                              isSelected: settings.use24HourFormat,
                              palette: palette,
                              onPressed: () =>
                                  settingsProv.updateTimeFormat(true),
                            ),
                            const SizedBox(width: 16),
                            _TvFormatButton(
                              label: '12 ساعة',
                              isSelected: !settings.use24HourFormat,
                              palette: palette,
                              onPressed: () =>
                                  settingsProv.updateTimeFormat(false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // === LAYOUT STYLE ===
                        _SectionTitle(title: 'تصميم الواجهة'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _TvFormatButton(
                              label: 'حديث',
                              isSelected: settings.layoutStyle == 'modern',
                              palette: palette,
                              onPressed: () =>
                                  settingsProv.updateLayoutStyle('modern'),
                            ),
                            const SizedBox(width: 16),
                            _TvFormatButton(
                              label: 'كلاسيكي',
                              isSelected: settings.layoutStyle == 'classic',
                              palette: palette,
                              onPressed: () =>
                                  settingsProv.updateLayoutStyle('classic'),
                            ),
                          ],
                        ),

                        // === TEST ADHAN / IQAMA ===
                        _SectionTitle(title: 'اختبار'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _TvButton(
                              onPressed: () {
                                context.read<PrayerProvider>().testAdhan();
                                Navigator.pop(context);
                              },
                              accent: palette.primary,
                              filled: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'اختبار الأذان',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            _TvButton(
                              onPressed: () {
                                context.read<PrayerProvider>().testIqama();
                                Navigator.pop(context);
                              },
                              accent: palette.primary,
                              filled: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'اختبار الإقامة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // === CLOSE APP ===
                        _SectionTitle(title: 'التطبيق'),
                        const SizedBox(height: 12),
                        _TvButton(
                          onPressed: () => SystemNavigator.pop(),
                          accent: const Color(0xFFEF4444),
                          filled: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.power_settings_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إغلاق التطبيق',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── City Section ───────────────────────────────────────────────────────

  // ── Country Section ─────────────────────────────────────────────────

  Widget _countrySection(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final country = settingsProv.settings.selectedCountry;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: glassDecoration(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: palette.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    countryLabel(country),
                    style: TextStyle(
                      fontSize: 18,
                      color: kTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _TvButton(
          onPressed: () => _showCountryPicker(context, settingsProv, palette),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'تغيير الدولة',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCountryPicker(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    // Show ALL countries — cities are resolved from the loaded CSV on selection
    final allCsvCities = CsvService().availableCities;

    showDialog<void>(
      context: context,
      builder: (_) => _CountryPickerDialog(
        palette: palette,
        selectedCountry: settingsProv.settings.selectedCountry,
        countries: kCountries, // always show all countries
        onSelected: (countryKey) async {
          // Pre-load the new country data
          await settingsProv.updateSelectedCountry(countryKey);

          // Now fetch the available cities from the newly loaded CSV
          final allCsvCities = CsvService().availableCities;
          final filtered = citiesForCountry(countryKey, allCsvCities);

          if (filtered.isNotEmpty &&
              !filtered.contains(settingsProv.settings.selectedCity)) {
            settingsProv.updateSelectedCity(filtered.first);
          }
        },
      ),
    );
  }

  // ── City Section ───────────────────────────────────────────────────

  Widget _citySection(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final settings = settingsProv.settings;
    final hasCity = settings.selectedCity.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: glassDecoration(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: hasCity ? palette.primary : kTextMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasCity
                        ? cityLabel(settings.selectedCity)
                        : 'لم يتم اختيار مدينة',
                    style: TextStyle(
                      fontSize: 18,
                      color: hasCity ? kTextPrimary : kTextMuted,
                      fontWeight: hasCity ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _TvButton(
          onPressed: () => _showCityPicker(context, settingsProv, palette),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_city_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'تغيير المدينة',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCityPicker(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final filtered = citiesForCountry(
      settingsProv.settings.selectedCountry,
      CsvService().availableCities,
    );
    showDialog<void>(
      context: context,
      builder: (_) => _CityPickerDialog(
        palette: palette,
        selectedCity: settingsProv.settings.selectedCity,
        cities: filtered,
        onSelected: (city) {
          settingsProv.updateSelectedCity(city);
        },
      ),
    );
  }

  // ── Adhan Sound Picker ─────────────────────────────────────────────────

  void _showAdhanSoundPicker(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _AdhanSoundPickerDialog(
        palette: palette,
        selectedKey: settingsProv.settings.adhanSound,
        onSelected: (key) {
          settingsProv.updateAdhanSound(key);
        },
      ),
    );
  }

  // ── Quran Section ──────────────────────────────────────────────────────

  Widget _quranSection(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final settings = settingsProv.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/Disable toggle
        _TvSwitchRow(
          value: settings.isQuranEnabled,
          accent: palette.primary,
          onChanged: (v) => settingsProv.updateIsQuranEnabled(v),
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: settings.isQuranEnabled ? palette.primary : kTextMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              'تشغيل القرآن في الخلفية:',
              style: TextStyle(fontSize: 20, color: kTextPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isQuranEnabled,
              activeTrackColor: palette.primary,
              inactiveTrackColor: kTextMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: (v) => settingsProv.updateIsQuranEnabled(v),
            ),
            const SizedBox(width: 12),
            Text(
              settings.isQuranEnabled ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 20,
                color: settings.isQuranEnabled ? palette.primary : kTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Reciter picker (visible when enabled)
        if (settings.isQuranEnabled) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: glassDecoration(opacity: 0.06, borderRadius: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: settings.hasQuranReciter
                            ? palette.primary
                            : kTextMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings.hasQuranReciter
                              ? settings.quranReciterName
                              : 'لم يتم اختيار قاريء',
                          style: TextStyle(
                            fontSize: 18,
                            color: settings.hasQuranReciter
                                ? kTextPrimary
                                : kTextMuted,
                            fontWeight: settings.hasQuranReciter
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _TvButton(
                onPressed: () =>
                    _showReciterPicker(context, settingsProv, palette),
                accent: palette.primary,
                filled: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_search_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تغيير القاريء',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: glassDecoration(opacity: 0.05, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.wifi_rounded, color: kTextMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يتطلب اتصالاً بالإنترنت لتحميل قائمة القراء وتشغيل القرآن.',
                    style: TextStyle(fontSize: 14, color: kTextMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showReciterPicker(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _ReciterPickerDialog(
        palette: palette,
        currentServerUrl: settingsProv.settings.quranReciterServerUrl,
        onSelected: (name, serverUrl) {
          settingsProv.updateQuranReciter(name, serverUrl);
        },
      ),
    );
  }

  Widget _iqamaTable(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final delays = settingsProv.settings.iqamaDelays;
    const prayers = [
      ('fajr', 'الفجر'),
      ('dhuhr', 'الظهر'),
      ('asr', 'العصر'),
      ('maghrib', 'المغرب'),
      ('isha', 'العشاء'),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: prayers.map((p) {
        final key = p.$1;
        final name = p.$2;
        final delay = delays[key] ?? 10;

        return Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: glassDecoration(opacity: 0.06, borderRadius: 14),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TvSmallButton(
                    icon: Icons.remove,
                    palette: palette,
                    onPressed: () =>
                        settingsProv.updateIqamaDelay(key, delay - 1),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$delay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                        shadows: [Shadow(color: palette.glow, blurRadius: 8)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TvSmallButton(
                    icon: Icons.add,
                    palette: palette,
                    onPressed: () =>
                        settingsProv.updateIqamaDelay(key, delay + 1),
                  ),
                ],
              ),
              Text('دقيقة', style: TextStyle(fontSize: 14, color: kTextMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _adhanOffsetsTable(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    final offsets = settingsProv.settings.adhanOffsets;
    const prayers = [
      ('fajr', 'الفجر'),
      ('sunrise', 'الشروق'),
      ('dhuhr', 'الظهر'),
      ('asr', 'العصر'),
      ('maghrib', 'المغرب'),
      ('isha', 'العشاء'),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: prayers.map((p) {
        final key = p.$1;
        final name = p.$2;
        final offset = offsets[key] ?? 0;

        return Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: glassDecoration(opacity: 0.06, borderRadius: 14),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TvSmallButton(
                    icon: Icons.remove,
                    palette: palette,
                    onPressed: () =>
                        settingsProv.updateAdhanOffset(key, offset - 1),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      offset >= 0 ? '+$offset' : '$offset',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: offset == 0 ? kTextMuted : palette.primary,
                        shadows: offset != 0
                            ? [Shadow(color: palette.glow, blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TvSmallButton(
                    icon: Icons.add,
                    palette: palette,
                    onPressed: () =>
                        settingsProv.updateAdhanOffset(key, offset + 1),
                  ),
                ],
              ),
              Text('دقيقة', style: TextStyle(fontSize: 14, color: kTextMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }
}

// ── Country Picker Dialog ───────────────────────────────────────────────────

class _CountryPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCountry;
  final List<CountryInfo> countries;
  final ValueChanged<String> onSelected;

  const _CountryPickerDialog({
    required this.palette,
    required this.selectedCountry,
    required this.countries,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(Icons.public_rounded, color: palette.primary, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    'اختر الدولة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),

              // Body
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, i) {
                    final c = countries[i];
                    final isSelected = c.key == selectedCountry;
                    return ListTile(
                      leading: Icon(
                        Icons.flag_rounded,
                        color: isSelected ? palette.primary : Colors.white38,
                      ),
                      title: Text(
                        c.arabicName,
                        style: TextStyle(
                          color: isSelected ? palette.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: palette.primary,
                            )
                          : null,
                      onTap: () {
                        onSelected(c.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Adhan Sound Picker Dialog ───────────────────────────────────────────────

class _AdhanSoundPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const _AdhanSoundPickerDialog({
    required this.palette,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = AudioService.adhanSounds;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    color: palette.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'اختر صوت الأذان',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),

              // Body
              ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, i) {
                  final key = entries[i].key;
                  final label = entries[i].label;
                  final isSelected = key == selectedKey;
                  return ListTile(
                    leading: Icon(
                      Icons.music_note_rounded,
                      color: isSelected ? palette.primary : Colors.white38,
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? palette.primary : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: palette.primary,
                          )
                        : null,
                    onTap: () {
                      onSelected(key);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── City Picker Dialog ──────────────────────────────────────────────────────

class _CityPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCity;
  final List<String> cities;
  final ValueChanged<String> onSelected;

  const _CityPickerDialog({
    required this.palette,
    required this.selectedCity,
    required this.cities,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: palette.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'اختر المدينة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),

              // Body
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    final isSelected = city == selectedCity;
                    return ListTile(
                      leading: Icon(
                        Icons.location_city_rounded,
                        color: isSelected ? palette.primary : Colors.white38,
                      ),
                      title: Text(
                        cityLabel(city),
                        style: TextStyle(
                          color: isSelected ? palette.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: palette.primary,
                            )
                          : null,
                      onTap: () {
                        onSelected(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
