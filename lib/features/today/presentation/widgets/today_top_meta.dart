import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/city_translations.dart';
import '../../../../core/localization/date_localizer.dart';
import '../../../../core/mobile_theme.dart';
import '../../domain/entities/greeting.dart';
import '../logic/today_l10n_resolver.dart';
import 'bento/bento_tile.dart';

/// Magazine-style top of the screen.
///
/// Layout intent: every element (greeting, city, divider, dates) sits at
/// the same 24px inset from both edges so the column reads as a single
/// coherent block — no element drifts off to a different gutter.
class TodayTopMeta extends StatelessWidget {
  final Greeting greeting;
  final String city;
  final String country;
  final DateTime now;

  const TodayTopMeta({
    super.key,
    required this.greeting,
    required this.city,
    required this.country,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final surface = BentoSurface.of(context);
    final cityName = cityLabel(city, locale: l.localeName, countryKey: country);
    final title = resolveGreetingTitle(l, greeting);
    final hijri = HijriCalendar.fromDate(now);
    final hijriLine =
        '${localizedWeekdayName(l, now.weekday)}${l.localeComma} '
        '${hijri.hDay} ${localizedHijriMonthName(l, hijri.hMonth)} '
        '${hijri.hYear}';
    final gregorianLine =
        '${now.day} ${localizedGregorianMonthName(l, now.month)} ${now.year}';

    return Padding(
      // Single uniform 24px gutter on both sides — every child renders
      // inside this same block so nothing drifts off-axis.
      padding: const EdgeInsetsDirectional.fromSTEB(24, 14, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(greeting.period),
                size: 26,
                color: surface.foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: MobileTextStyles.titleMd(context).copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: surface.foreground,
                    height: 1.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // City sits indented under the greeting title (past the icon +
          // gap = 36px) with its own small pin so it reads as a "where you
          // are" subline tied to the greeting, not a stray label.
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 40),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: surface.foregroundMuted,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cityName,
                    style: MobileTextStyles.labelSm(context).copyWith(
                      fontSize: 13,
                      letterSpacing: 0.2,
                      color: surface.foregroundMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _MetaDivider(color: surface.foregroundMuted),
          const SizedBox(height: 10),
          Text(
            hijriLine,
            style: MobileTextStyles.labelSm(context).copyWith(
              fontSize: 15,
              color: surface.foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            gregorianLine,
            style: MobileTextStyles.labelSm(context).copyWith(
              fontSize: 12,
              color: surface.foregroundMuted,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(GreetingPeriod period) {
    switch (period) {
      case GreetingPeriod.morning:
        return Icons.wb_sunny_rounded;
      case GreetingPeriod.evening:
        return Icons.nightlight_round;
    }
  }
}

class _MetaDivider extends StatelessWidget {
  final Color color;

  const _MetaDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 1,
      color: color.withValues(alpha: 0.30),
    );
  }
}
