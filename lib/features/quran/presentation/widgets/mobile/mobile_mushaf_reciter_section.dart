import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/ayah_reciter.dart';
import '../../../domain/entities/available_ayah_reciters.dart';
import '../../bloc/mushaf_reader_cubit.dart';

/// Reciter picker shown inside the Mushaf settings sheet — single column
/// of tappable rows with the active one tinted in the active palette.
class MobileMushafReciterSection extends StatelessWidget {
  final String reciterId;
  const MobileMushafReciterSection({super.key, required this.reciterId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).mushafReciterSection,
          style: MobileTextStyles.headlineMd(context),
        ),
        const SizedBox(height: 8),
        for (final r in kAvailableAyahReciters)
          _ReciterRow(reciter: r, isSelected: r.id == reciterId),
      ],
    );
  }
}

class _ReciterRow extends StatelessWidget {
  final AyahReciter reciter;
  final bool isSelected;
  const _ReciterRow({required this.reciter, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => context.read<MushafReaderCubit>().setReciter(reciter.id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.45)
                : MobileColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected
                  ? primary
                  : MobileColors.onSurfaceFaint(context),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reciter.nameAr,
                style: MobileTextStyles.headlineMd(context).copyWith(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
