import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/khatma_cubit.dart';
import 'mushaf_arabic_digits.dart';

/// Bottom sheet to start a new Khatma by choosing a duration. The convention
/// (Quran.com / classic khatma) is duration-based: the range is split equally
/// across the chosen number of days. 30 days is highlighted as the Ramadan
/// preset (one juz a day).
class KhatmaCreateSheet extends StatelessWidget {
  const KhatmaCreateSheet({super.key});

  static const List<int> _durations = [30, 60, 90];

  static Future<void> show(BuildContext context, KhatmaCubit cubit) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: MobileColors.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const KhatmaCreateSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MobileColors.onSurfaceFaint(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(l.khatmaCreateTitle, style: MobileTextStyles.titleMd(context)),
            const SizedBox(height: 6),
            Text(
              l.khatmaCreateSubtitle,
              style: MobileTextStyles.bodyMd(context),
            ),
            const SizedBox(height: 18),
            for (final days in _durations) ...[
              _DurationOption(
                days: days,
                isRamadan: days == 30,
                onTap: () {
                  context.read<KhatmaCubit>().createByDuration(days);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final int days;
  final bool isRamadan;
  final VoidCallback onTap;

  const _DurationOption({
    required this.days,
    required this.isRamadan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: accent, size: 22),
              const SizedBox(width: 14),
              Text(
                l.khatmaDurationDaysLabel(digitsForLocale(context, days)),
                style: MobileTextStyles.headlineMd(context),
              ),
              const Spacer(),
              if (isRamadan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.khatmaDurationRamadanNote,
                    style: MobileTextStyles.labelSm(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
