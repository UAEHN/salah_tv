import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';

/// Three-swatch picker for the reader's [ReadingTheme] (ورقي / مصحف / ليلي).
/// Extracted from the settings sheet to keep that file under 150 lines.
class MobileMushafThemeSection extends StatelessWidget {
  final ReadingTheme theme;
  const MobileMushafThemeSection({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.mushafThemeSection, style: MobileTextStyles.headlineMd(context)),
        const SizedBox(height: 10),
        Row(
          children: [
            _Swatch(
              t: ReadingTheme.paper,
              label: l.mushafThemePaper,
              current: theme,
            ),
            const SizedBox(width: 10),
            _Swatch(
              t: ReadingTheme.sepia,
              label: l.mushafThemeSepia,
              current: theme,
            ),
            const SizedBox(width: 10),
            _Swatch(
              t: ReadingTheme.night,
              label: l.mushafThemeNight,
              current: theme,
            ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final ReadingTheme t;
  final String label;
  final ReadingTheme current;
  const _Swatch({required this.t, required this.label, required this.current});

  @override
  Widget build(BuildContext context) {
    final palette = ReadingPalette.of(t);
    final isSelected = t == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<MushafReaderCubit>().setReadingTheme(t),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: palette.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : palette.pageBorder,
              width: isSelected ? 2.2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 16,
              color: palette.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
