import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/quran_quick_links.dart';

/// Horizontal pill row of quick navigation shortcuts. Pure-text
/// chips with a neutral hairline border — no icons, no tinted
/// background — so they read as formal index entries rather than
/// branded CTAs.
class MobileMushafQuickLinksRow extends StatelessWidget {
  final void Function(QuranQuickLink link) onTap;
  const MobileMushafQuickLinksRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: kQuranQuickLinks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final link = kQuranQuickLinks[i];
          return _Chip(label: link.label, onTap: () => onTap(link));
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: MobileColors.onSurfaceFaint(context).withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: MobileTextStyles.bodyMd(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.0,
                color: MobileColors.onSurface(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
