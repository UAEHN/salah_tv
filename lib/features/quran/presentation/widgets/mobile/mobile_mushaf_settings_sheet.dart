import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_continuous_section.dart';
import 'mobile_mushaf_font_section.dart';
import 'mobile_mushaf_reciter_section.dart';
import 'mobile_mushaf_theme_section.dart';

/// Bottom sheet that exposes all reader preferences.
/// Each section lives in its own file (CLAUDE.md §4 SRP + 150-line cap).
class MobileMushafSettingsSheet extends StatelessWidget {
  const MobileMushafSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<MushafReaderCubit>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const MobileMushafSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafReaderCubit, MushafReaderState>(
      builder: (context, state) {
        final viewInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: MobileColors.cardColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: viewInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GrabHandle(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).mushafReadingSettings,
                  style: MobileTextStyles.titleMd(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                MobileMushafThemeSection(theme: state.readingTheme),
                const SizedBox(height: 20),
                MobileMushafFontSection(size: state.fontSize),
                const SizedBox(height: 12),
                MobileMushafContinuousSection(enabled: state.continuousPlayback),
                const SizedBox(height: 18),
                MobileMushafReciterSection(reciterId: state.prefs.reciterId),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: MobileColors.onSurfaceFaint(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
