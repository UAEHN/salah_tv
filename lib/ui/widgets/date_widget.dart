import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

const List<String> _hijriMonthsAr = [
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع الأَوَّل',
  'رَبِيع الثَّانِي',
  'جُمَادَى الأُولَى',
  'جُمَادَى الآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو القَعْدَة',
  'ذُو الحِجَّة',
];

const List<String> _gregorianMonthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

const List<String> _dayNamesAr = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

class DateWidget extends StatefulWidget {
  final AccentPalette palette;
  final bool compact;
  const DateWidget({super.key, required this.palette, this.compact = false});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  bool _showHijri = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() => _showHijri = !_showHijri);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _hijriDate(DateTime d) {
    final h = HijriCalendar.fromDate(d);
    final day = _dayNamesAr[d.weekday - 1];
    final month = (h.hMonth >= 1 && h.hMonth <= 12)
        ? _hijriMonthsAr[h.hMonth - 1]
        : h.longMonthName;
    return '$day  ${h.hDay} $month ${h.hYear} هـ';
  }

  String _gregorianDate(DateTime d) {
    final day = _dayNamesAr[d.weekday - 1];
    final month = _gregorianMonthsAr[d.month - 1];
    return '$day  ${d.day} $month ${d.year} م';
  }

  @override
  Widget build(BuildContext context) {
    final now = context.select<PrayerProvider, DateTime>(
      (p) => DateTime(p.now.year, p.now.month, p.now.day),
    );
    final isDark = context.watch<SettingsProvider>().settings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;

    final text = _showHijri ? _hijriDate(now) : _gregorianDate(now);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenH * (widget.compact ? 0.032 : 0.048),
          fontWeight: FontWeight.w500,
          color: tc.textSecondary,
        ),
      ),
    );
  }
}
