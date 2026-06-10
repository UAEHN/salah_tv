import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/page_image_download_cubit.dart';
import '../../bloc/page_image_download_state.dart';

/// "Save Mushaf on device" row inside the reader's settings sheet.
/// Matches the section style of the other rows (title + trailing
/// control). The trailing widget is state-aware: download button,
/// progress text, delete button, or retry — depending on the bulk
/// download cubit's status.
class MobileMushafStorageSection extends StatelessWidget {
  const MobileMushafStorageSection({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<PageImageDownloadCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المصحف'),
        content: const Text(
          'سيتم حذف المصحف من جهازك. يمكنك تحميله مرة أخرى لاحقاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await cubit.deleteAll();
    messenger.showSnackBar(const SnackBar(content: Text('تم حذف المصحف')));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageImageDownloadCubit, PageImageDownloadState>(
      buildWhen: (p, n) =>
          p.status != n.status || p.downloadedCount != n.downloadedCount,
      builder: (context, state) {
        if (state.status == PageImageDownloadStatus.unknown) {
          return const SizedBox.shrink();
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                'حفظ المصحف على الجهاز',
                style: MobileTextStyles.headlineMd(context),
              ),
            ),
            const SizedBox(width: 12),
            _Trailing(state: state, onDelete: () => _confirmDelete(context)),
          ],
        );
      },
    );
  }
}

class _Trailing extends StatelessWidget {
  final PageImageDownloadState state;
  final VoidCallback onDelete;
  const _Trailing({required this.state, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (state.status) {
      case PageImageDownloadStatus.complete:
        return OutlinedButton.icon(
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          label: Text(
            'حذف المصحف',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: onDelete,
        );
      case PageImageDownloadStatus.downloading:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PageImageDownloadStatus.error:
        return TextButton(
          onPressed: () =>
              context.read<PageImageDownloadCubit>().startBulkDownload(),
          child: const Text('إعادة المحاولة'),
        );
      case PageImageDownloadStatus.idle:
        return FilledButton.icon(
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('تحميل المصحف'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () =>
              context.read<PageImageDownloadCubit>().startBulkDownload(),
        );
      case PageImageDownloadStatus.unknown:
        return const SizedBox.shrink();
    }
  }
}
