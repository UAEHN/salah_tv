import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_mushaf_intro_item.dart';

/// One-shot welcome sheet shown the first time a user opens the Mushaf
/// reader (and re-openable from the "?" button in the app bar).
class MobileMushafIntroSheet extends StatelessWidget {
  const MobileMushafIntroSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MobileMushafIntroSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                children: [
                  _Header(
                    title: l.mushafIntroTitle,
                    subtitle: l.mushafIntroSubtitle,
                  ),
                  const SizedBox(height: 20),
                  MobileMushafIntroItem(
                    icon: Icons.swipe_rounded,
                    title: l.mushafIntroSwipeTitle,
                    body: l.mushafIntroSwipeBody,
                  ),
                  MobileMushafIntroItem(
                    icon: Icons.touch_app_rounded,
                    title: l.mushafIntroTapAyahTitle,
                    body: l.mushafIntroTapAyahBody,
                  ),
                  MobileMushafIntroItem(
                    icon: Icons.menu_book_rounded,
                    title: l.mushafIntroNavigateTitle,
                    body: l.mushafIntroNavigateBody,
                  ),
                  MobileMushafIntroItem(
                    icon: Icons.bookmark_added_rounded,
                    title: l.mushafIntroBookmarkTitle,
                    body: l.mushafIntroBookmarkBody,
                  ),
                  MobileMushafIntroItem(
                    icon: Icons.tune_rounded,
                    title: l.mushafIntroSettingsTitle,
                    body: l.mushafIntroSettingsBody,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l.mushafIntroCta,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: MobileTextStyles.headlineMd(context),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}
