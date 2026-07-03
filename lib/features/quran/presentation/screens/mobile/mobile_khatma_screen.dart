import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../today/presentation/widgets/bento/bento_tile.dart';
import '../../bloc/khatma_cubit.dart';
import '../../bloc/khatma_state.dart';
import '../../widgets/mobile/khatma_active_view.dart';
import '../../widgets/mobile/khatma_complete_view.dart';
import '../../widgets/mobile/khatma_create_sheet.dart';

/// Khatma (Quran completion plan) screen. Routes between three states:
/// empty (no plan → create), active (progress + juz map), and completed.
/// Hosted on the root navigator with the hoisted `KhatmaCubit` provided.
class MobileKhatmaScreen extends StatelessWidget {
  const MobileKhatmaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MobileColors.background(context),
      appBar: AppBar(
        title: Text(l.khatmaTitle, style: MobileTextStyles.headlineMd(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<KhatmaCubit, KhatmaState>(
            buildWhen: (p, n) => p.hasActive != n.hasActive,
            builder: (context, state) => state.hasActive
                ? IconButton(
                    tooltip: l.khatmaDeleteTitle,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDelete(context),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      // The Khatma cards reuse BentoTile/BentoSurface; on this standalone
      // screen there's no Today-screen BentoSurface ancestor, so provide one
      // that matches the real theme brightness — otherwise tiles fall back to
      // the light surface and render white on the dark background.
      body: BentoSurface(
        isDarkSky: MobileColors.isDark(context),
        child: BlocBuilder<KhatmaCubit, KhatmaState>(
          builder: (context, state) {
            if (!state.isLoaded) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2.4),
              );
            }
            if (state.isCompleted) {
              return KhatmaCompleteView(cubit: context.read<KhatmaCubit>());
            }
            if (state.hasActive) {
              return KhatmaActiveView(khatma: state.khatma!);
            }
            return _EmptyView(cubit: context.read<KhatmaCubit>());
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final cubit = context.read<KhatmaCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(l.khatmaDeleteTitle),
        content: Text(l.khatmaDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.clear();
  }
}

class _EmptyView extends StatelessWidget {
  final KhatmaCubit cubit;
  const _EmptyView({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_rounded, color: accent, size: 64),
            const SizedBox(height: 20),
            Text(
              l.khatmaEmptyMessage,
              textAlign: TextAlign.center,
              style: MobileTextStyles.bodyMd(context),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => KhatmaCreateSheet.show(context, cubit),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                l.khatmaStartCta,
                style: MobileTextStyles.headlineMd(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
