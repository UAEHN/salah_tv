import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/custom_adhan.dart';
import '../../bloc/adhan_preview_cubit.dart';
import '../../bloc/custom_adhan_cubit.dart';
import 'mobile_custom_adhan_rename_dialog.dart';
import 'mobile_custom_adhan_tile.dart';

class MobileCustomAdhanSection extends StatelessWidget {
  final List<CustomAdhan> adhans;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  const MobileCustomAdhanSection({
    super.key,
    required this.adhans,
    required this.selectedKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l.settingsCustomAdhansTitle,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: MobileColors.onSurfaceMuted(context),
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        BlocBuilder<AdhanPreviewCubit, AdhanPreviewState>(
          builder: (ctx, previewState) => Column(
            children: adhans
                .map(
                  (a) => MobileCustomAdhanTile(
                    label: a.label,
                    isSelected: selectedKey == a.settingsKey,
                    isPlaying:
                        previewState is AdhanPreviewPlaying &&
                        previewState.soundKey == a.settingsKey,
                    onSelect: () => onSelect(a.settingsKey),
                    onPreview: () =>
                        ctx.read<AdhanPreviewCubit>().toggle(a.settingsKey),
                    onRename: () => _openRename(ctx, a),
                    onDelete: () => _confirmDelete(ctx, a),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        BlocConsumer<CustomAdhanCubit, CustomAdhanState>(
          listener: (ctx, state) {
            if (state is CustomAdhanError) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              ctx.read<CustomAdhanCubit>().clearError();
            }
          },
          builder: (ctx, state) {
            final busy = state is CustomAdhanBusy;
            return OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => ctx.read<CustomAdhanCubit>().pickAndImport(''),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
              label: Text(l.settingsAddCustomAdhan),
            );
          },
        ),
      ],
    );
  }

  void _openRename(BuildContext context, CustomAdhan a) {
    final cubit = context.read<CustomAdhanCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => MobileCustomAdhanRenameDialog(
        initialLabel: a.label,
        onSave: (newLabel) => cubit.rename(a.id, newLabel),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CustomAdhan a) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<CustomAdhanCubit>();
    showDialog<void>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: MobileColors.cardColor(dCtx),
        title: Text(l.settingsDeleteAdhan),
        content: Text(a.label, textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () {
              cubit.remove(a.id);
              Navigator.pop(dCtx);
            },
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
  }
}
