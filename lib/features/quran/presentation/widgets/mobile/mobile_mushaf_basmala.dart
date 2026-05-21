import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';

/// Plain «بسم الله الرحمن الرحيم» line shown at the top of a surah, just
/// above its first ayah. Matches the ayah text font exactly (same family,
/// same size, same weight) so it reads as a natural part of the page.
///
/// Returns an empty widget for:
///   • surah 1 (the Basmala is itself the first ayah of Al-Fatihah)
///   • surah 9 (At-Tawbah has no Basmala by tradition)
class MobileMushafBasmala extends StatelessWidget {
  final int surahNumber;
  static const String _text = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';

  const MobileMushafBasmala({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    if (surahNumber == 1 || surahNumber == 9) {
      return const SizedBox.shrink();
    }
    final theme = context.select<MushafReaderCubit, ReadingTheme>(
      (c) => c.state.readingTheme,
    );
    final fontSize = context.select<MushafReaderCubit, double>(
      (c) => c.state.fontSize,
    );
    final palette = ReadingPalette.of(theme);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'AmiriQuran',
          fontFamilyFallback: const ['Cairo'],
          fontSize: fontSize,
          color: palette.text,
          height: 1.4,
        ),
      ),
    );
  }
}
