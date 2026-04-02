import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../bloc/adhkar_reader_cubit.dart';
import '../../bloc/adhkar_reader_state.dart';
import '../../widgets/mobile/mobile_adhkar_progress_bar.dart';
import '../../widgets/mobile/mobile_adhkar_reader_bottom_bar.dart';
import '../../widgets/mobile/mobile_dhikr_reader_content.dart';

class MobileAdhkarReaderScreen extends StatelessWidget {
  const MobileAdhkarReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<SettingsProvider, String>(
      (p) => p.settings.locale,
    );
    final isEnglish = locale == 'en';

    return BlocBuilder<AdhkarReaderCubit, AdhkarReaderState>(
      builder: (context, state) {
        if (state is AdhkarReaderCompleted) {
          return _CompletedView(
            categoryName: state.category.displayName(locale),
          );
        }
        if (state is! AdhkarReaderReading) return const SizedBox.shrink();

        return GestureDetector(
          onTap: state.isCurrentCompleted
              ? null
              : () {
                  if (state.currentRemaining == 1) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                  context.read<AdhkarReaderCubit>().decrementCount();
                },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReaderTopBar(
                    title: state.category.displayName(locale),
                    isEnglish: isEnglish,
                  ),
                  const SizedBox(height: 8),
                  MobileAdhkarProgressBar(
                    current: state.currentIndex,
                    total: state.adhkar.length,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 160),
                      child: MobileDhikrReaderContent(
                        dhikr: state.currentDhikr,
                        isEnglish: isEnglish,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MobileAdhkarReaderBottomBar(
                  state: state,
                  isEnglish: isEnglish,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  final String title;
  final bool isEnglish;
  const _ReaderTopBar({required this.title, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AdhkarReaderCubit>().backToCategories(),
            child: Icon(
              isEnglish
                  ? Icons.arrow_back_ios_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: MobileColors.onSurface(context),
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: MobileTextStyles.headlineMd(context),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  final String categoryName;
  const _CompletedView({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 72,
            ),
            const SizedBox(height: 20),
            Text(
              l.adhkarCompletedCategory(categoryName),
              style: MobileTextStyles.titleMd(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.adhkarMayAllahAccept,
              style: MobileTextStyles.bodyMd(context),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  context.read<AdhkarReaderCubit>().backToCategories(),
              child: Text(l.adhkarBackToCategories),
            ),
          ],
        ),
      ),
    );
  }
}
