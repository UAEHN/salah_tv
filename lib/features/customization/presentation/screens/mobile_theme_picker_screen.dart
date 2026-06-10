import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/entities/theme_palette_info.dart';
import '../bloc/theme_picker_cubit.dart';
import '../bloc/theme_picker_state.dart';
import '../logic/customization_l10n_resolver.dart';
import '../widgets/customization_screen_header.dart';
import '../widgets/theme_picker_grid.dart';

class MobileThemePickerScreen extends StatelessWidget {
  const MobileThemePickerScreen({super.key});

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
                  title: l.themePickerTitle,
                  subtitle: l.themePickerSubtitle,
                ),
                Expanded(
                  child: BlocBuilder<ThemePickerCubit, ThemePickerState>(
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

  Widget _buildBody(BuildContext context, ThemePickerState state) {
    return switch (state) {
      ThemePickerInitial() || ThemePickerLoading() => const Center(
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
      ThemePickerError(:final messageKey) => _ErrorView(messageKey: messageKey),
      ThemePickerLoaded(
        :final palettes,
        :final selectedId,
        :final isApplying,
      ) =>
        _LoadedView(
          palettes: palettes,
          selectedId: selectedId,
          isApplying: isApplying,
        ),
    };
  }
}

class _LoadedView extends StatelessWidget {
  final List<ThemePaletteInfo> palettes;
  final String selectedId;
  final bool isApplying;

  const _LoadedView({
    required this.palettes,
    required this.selectedId,
    required this.isApplying,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ThemePickerCubit>();
    return ThemePickerGrid(
      palettes: palettes,
      selectedId: selectedId,
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
