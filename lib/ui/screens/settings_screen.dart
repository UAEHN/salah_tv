import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/quran_reciter.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
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
                      vertical: 16, horizontal: 32),
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
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 6),
                            Text('رجوع',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
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
                        // === CSV FILE ===
                        _SectionTitle(title: 'ملف مواقيت الصلاة (CSV)'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: glassDecoration(
                                  opacity: 0.06,
                                  borderRadius: 10,
                                ),
                                child: Text(
                                  settings.csvFilePath != null
                                      ? settings.csvFilePath!
                                          .split('/')
                                          .last
                                      : 'يستخدم الملف الافتراضي (${CsvService().totalDays} يوم)',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: kTextSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _TvButton(
                              onPressed: () =>
                                  _pickCsvFile(context, settingsProv),
                              accent: palette.primary,
                              filled: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.upload_file,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('تغيير الملف',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            if (settings.csvFilePath != null) ...[
                              const SizedBox(width: 12),
                              _TvButton(
                                onPressed: () async {
                                  await settingsProv.updateCsvPath(null);
                                  await CsvService().initialize(null);
                                  if (context.mounted) {
                                    context
                                        .read<PrayerProvider>()
                                        .reload();
                                  }
                                },
                                accent: const Color(0xFFEF4444),
                                filled: true,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.restore,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('استعادة الافتراضي',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        _formatHint(palette),

                        const SizedBox(height: 28),

                        // === QURAN BACKGROUND AUDIO ===
                        _SectionTitle(title: 'القرآن الكريم في الخلفية'),
                        const SizedBox(height: 12),
                        _quranSection(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === ADHAN OFFSETS ===
                        _SectionTitle(
                            title: 'تعديل أوقات الأذان (± دقائق)'),
                        const SizedBox(height: 12),
                        _adhanOffsetsTable(
                            context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === IQAMA DELAYS ===
                        _SectionTitle(
                            title: 'أوقات الإقامة (دقائق بعد الأذان)'),
                        const SizedBox(height: 12),
                        _iqamaTable(context, settingsProv, palette),

                        const SizedBox(height: 28),

                        // === FONT FAMILY ===
                        _SectionTitle(title: 'الخط'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: const [
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
                            final isSelected =
                                settings.themeColorKey == e.key;
                            final label =
                                kThemeLabels[e.key] ?? e.key;
                            return _TvColorChip(
                              palette: e.value,
                              label: label,
                              isSelected: isSelected,
                              onPressed: () =>
                                  settingsProv.updateTheme(e.key),
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
                                  fontSize: 20, color: kTextPrimary),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: settings.isDarkMode,
                              activeTrackColor: const Color(0xFF162035),
                              activeColor: const Color(0xFFB8C0D8),
                              inactiveTrackColor:
                                  kTextMuted.withValues(alpha: 0.3),
                              thumbColor:
                                  WidgetStateProperty.all(Colors.white),
                              onChanged: (v) =>
                                  settingsProv.updateDarkMode(v),
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
                                  fontSize: 20, color: kTextPrimary),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: settings.playAdhan,
                              activeTrackColor: palette.primary,
                              inactiveTrackColor:
                                  kTextMuted.withValues(alpha: 0.3),
                              thumbColor:
                                  WidgetStateProperty.all(Colors.white),
                              onChanged: (v) =>
                                  settingsProv.updatePlayAdhan(v),
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

                        const SizedBox(height: 28),

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
                                  const Icon(Icons.volume_up_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('اختبار الأذان',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white)),
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
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text('اختبار الإقامة',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
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

  // ── Quran Section ──────────────────────────────────────────────────────

  Widget _quranSection(BuildContext context, SettingsProvider settingsProv,
      AccentPalette palette) {
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
                color:
                    settings.isQuranEnabled ? palette.primary : kTextMuted,
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
                      horizontal: 16, vertical: 14),
                  decoration:
                      glassDecoration(opacity: 0.06, borderRadius: 10),
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded,
                          color: settings.hasQuranReciter
                              ? palette.primary
                              : kTextMuted,
                          size: 22),
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
                    const Icon(Icons.person_search_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('تغيير القاريء',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white)),
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

  void _showReciterPicker(BuildContext context, SettingsProvider settingsProv,
      AccentPalette palette) {
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

  Widget _formatHint(AccentPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: glassDecoration(opacity: 0.05, borderRadius: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تنسيق ملف CSV المطلوب:',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha\n'
              '01/01/2026,05:30,06:51,12:10,15:25,18:05,19:25',
              style: TextStyle(
                  fontSize: 13,
                  color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iqamaTable(
      BuildContext context, SettingsProvider settingsProv,
      AccentPalette palette) {
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
                    color: kTextPrimary),
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
                        shadows: [
                          Shadow(
                            color: palette.glow,
                            blurRadius: 8,
                          ),
                        ],
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
              Text(
                'دقيقة',
                style: TextStyle(
                    fontSize: 14, color: kTextMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _adhanOffsetsTable(
      BuildContext context, SettingsProvider settingsProv,
      AccentPalette palette) {
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
                    color: kTextPrimary),
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
                        color: offset == 0
                            ? kTextMuted
                            : palette.primary,
                        shadows: offset != 0
                            ? [
                                Shadow(
                                  color: palette.glow,
                                  blurRadius: 8,
                                ),
                              ]
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
              Text(
                'دقيقة',
                style: TextStyle(
                    fontSize: 14, color: kTextMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickCsvFile(
      BuildContext context, SettingsProvider settingsProv) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final savedPath = await CsvService().saveCustomFile(path);
        await settingsProv.updateCsvPath(savedPath);
        if (context.mounted) {
          context.read<PrayerProvider>().reload();
          _showSnack(context, 'تم تحميل ملف CSV بنجاح',
              const Color(0xFF10B981));
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context,
            'خطأ في قراءة الملف. تأكد من التنسيق الصحيح.',
            const Color(0xFFEF4444));
      }
    }
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    ));
  }
}
