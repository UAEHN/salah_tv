import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../bloc/prayer_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/time_formatters.dart';
import '../mobile_countdown_arc_painter.dart';

const _hijriMonths = [
  'مُحَرَّم', 'صَفَر', 'رَبِيع الأَوَّل', 'رَبِيع الثَّانِي',
  'جُمَادَى الأُولَى', 'جُمَادَى الآخِرَة', 'رَجَب', 'شَعْبَان',
  'رَمَضَان', 'شَوَّال', 'ذُو القَعْدَة', 'ذُو الحِجَّة',
];
const _dayNames = [
  'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
];

String _hijriDate(DateTime d) {
  final h = HijriCalendar.fromDate(d);
  final month = (h.hMonth >= 1 && h.hMonth <= 12)
      ? _hijriMonths[h.hMonth - 1]
      : h.longMonthName;
  return '${_dayNames[d.weekday - 1]}، ${h.hDay} $month ${h.hYear} هـ';
}

double _arcProgress(dynamic state) {
  final prayers = state.todayPrayers?.prayers ?? [];
  if (prayers.isEmpty || state.countdown == Duration.zero) return 0.0;
  final nextTime = (state.now as DateTime).add(state.countdown as Duration);
  DateTime? prevTime;
  for (final p in prayers) {
    if (!(p.time as DateTime).isAfter(state.now as DateTime)) prevTime = p.time;
  }
  if (prevTime == null) return 0.0;
  final total = nextTime.difference(prevTime).inSeconds;
  if (total <= 0) return 0.0;
  return ((state.now as DateTime).difference(prevTime).inSeconds / total)
      .clamp(0.0, 1.0);
}

class MobileHeroCard extends StatelessWidget {
  const MobileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PrayerBloc>().state;
    final nextPrayerName =
        context.select((PrayerBloc b) => b.state.nextPrayerName);
    final countdown = context.select((PrayerBloc b) => b.state.countdown);
    final isCycleActive =
        context.select((PrayerBloc b) => b.state.isCycleActive);
    final progress = _arcProgress(state);

    return Column(
      children: [
        // ── Circular arc countdown ────────────────────────────────────────
        SizedBox(
          width: 256,
          height: 256,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer border ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MobileColors.primary.withValues(alpha: 0.2),
                    width: 12,
                  ),
                ),
              ),
              // Arc painter
              CustomPaint(
                size: const Size(256, 256),
                painter: MobileCountdownArcPainter(
                  progress: progress,
                  arcColor: MobileColors.primaryContainer,
                  trackColor: MobileColors.primary.withValues(alpha: 0.15),
                  strokeWidth: 12,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCycleActive ? nextPrayerName : formatCountdown(countdown),
                    style: MobileTextStyles.displayLg.copyWith(
                      fontFamily: isCycleActive ? 'Beiruti' : 'Cairo',
                      fontSize: isCycleActive ? 36 : 56,
                      fontFeatures: isCycleActive
                          ? null
                          : const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCycleActive ? 'جارٍ الآن' : 'باقي على $nextPrayerName',
                    style: MobileTextStyles.labelSm,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Hijri date row ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: MobileColors.onSurfaceFaint,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              _hijriDate(state.now),
              style: MobileTextStyles.labelSm.copyWith(
                color: MobileColors.onSurfaceFaint,
                letterSpacing: 0.5,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ],
    );
  }
}
