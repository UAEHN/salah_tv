import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/page_image_download_cubit.dart';
import '../../bloc/page_image_download_state.dart';

/// Slim status strip pinned at the top of the Quran tab. Visible only
/// while the bulk download is actively running — once it completes,
/// the banner collapses to a zero-height SizedBox so the surah list
/// reclaims the space.
///
/// Tapping the banner does nothing on purpose: the download streams
/// in the background and the user can keep reading whatever pages
/// are already cached.
class MobileQuranDownloadBanner extends StatelessWidget {
  const MobileQuranDownloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageImageDownloadCubit, PageImageDownloadState>(
      buildWhen: (p, n) =>
          p.status != n.status || p.downloadedCount != n.downloadedCount,
      builder: (context, state) {
        if (state.status != PageImageDownloadStatus.downloading &&
            state.status != PageImageDownloadStatus.error) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        final isError = state.status == PageImageDownloadStatus.error;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (isError ? theme.colorScheme.error : theme.colorScheme.primary)
                .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.cloud_download_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isError
                          ? 'فشل التحميل — اضغط لإعادة المحاولة'
                          : 'جاري تحميل المصحف',
                      style: MobileTextStyles.bodyMd(context)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!isError)
                    Text(
                      '${state.downloadedCount} / ${state.totalCount}',
                      style: MobileTextStyles.bodyMd(context)
                          .copyWith(fontSize: 12),
                    ),
                ],
              ),
              if (!isError) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 4,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('إعادة المحاولة'),
                    onPressed: () =>
                        context.read<PageImageDownloadCubit>().startBulkDownload(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
