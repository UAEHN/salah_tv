import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/entities/quran_font_info.dart';
import '../bloc/font_picker_cubit.dart';
import '../bloc/font_picker_state.dart';
import '../logic/customization_l10n_resolver.dart';
import '../widgets/customization_screen_header.dart';
import '../widgets/font_picker_list.dart';

class MobileFontPickerScreen extends StatelessWidget {
  const MobileFontPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final gradientColors = MobileColors.homeGradient(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                CustomizationScreenHeader(
                  title: l.fontPickerTitle,
                  subtitle: l.fontPickerSubtitle,
                ),
                Expanded(
                  child: BlocBuilder<FontPickerCubit, FontPickerState>(
                    builder: _buildBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, FontPickerState state) {
    return switch (state) {
      FontPickerInitial() || FontPickerLoading() => const Center(
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
      FontPickerError(:final messageKey) => _ErrorView(messageKey: messageKey),
      FontPickerLoaded(
        :final fonts,
        :final selectedFamily,
        :final isApplying,
      ) =>
        _LoadedView(
          fonts: fonts,
          selectedFamily: selectedFamily,
          isApplying: isApplying,
        ),
    };
  }
}

class _LoadedView extends StatelessWidget {
  final List<QuranFontInfo> fonts;
  final String selectedFamily;
  final bool isApplying;

  const _LoadedView({
    required this.fonts,
    required this.selectedFamily,
    required this.isApplying,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FontPickerCubit>();
    return FontPickerList(
      fonts: fonts,
      selectedFamily: selectedFamily,
      isLocked: isApplying,
      onPick: cubit.select,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String messageKey;

  const _ErrorView({required this.messageKey});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          resolveErrorMessage(l, messageKey),
          style: MobileTextStyles.bodyMd(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
