import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/page_image_download_cubit.dart';

/// First-time prompt shown when the user lands on the Quran tab. Two
/// mutually exclusive actions:
///   * **Download the Mushaf** — kicks the bulk pre-fetch so the
///     reader works fully offline afterwards.
///   * **Continue without downloading** — pages still load on demand
///     and stay cached after each visit, but un-visited pages need
///     internet.
/// Either way, the user is never asked again — the choice is
/// persisted via [IQuranOfflineChoiceRepository].
class MobileQuranOfflineChoiceSheet extends StatelessWidget {
  const MobileQuranOfflineChoiceSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<PageImageDownloadCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const MobileQuranOfflineChoiceSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PageImageDownloadCubit>();
    return Container(
      decoration: BoxDecoration(
        color: MobileColors.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: MobileColors.onSurfaceFaint(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Icon(
            Icons.menu_book_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'تحميل المصحف للأوفلاين',
            style: MobileTextStyles.headlineMd(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'يمكنك تحميل المصحف كاملاً (~25 ميغابايت) ليعمل بدون إنترنت في أي وقت، أو الاستمرار بدون تحميل والقراءة عبر الإنترنت فقط.',
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: MobileColors.onSurfaceMuted(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('تحميل المصحف'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              cubit.chooseDownload();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              cubit.chooseStayOnline();
              Navigator.of(context).pop();
            },
            child: const Text('المتابعة بدون تحميل'),
          ),
        ],
      ),
    );
  }
}
