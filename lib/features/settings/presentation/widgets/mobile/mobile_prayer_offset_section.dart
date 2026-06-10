import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Visual grouping for a list of prayer-offset rows. Renders an icon-prefixed
/// title, an optional subtitle, and a single rounded card that hosts the
/// rows separated by thin dividers.
class MobilePrayerOffsetSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> rows;

  const MobilePrayerOffsetSection({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = MobileColors.activePrimary(context);
    final dividerColor = MobileColors.border(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: MobileTextStyles.headlineMd(context).copyWith(
                  color: MobileColors.onSurface(context),
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(width: 8),
              Icon(icon, color: primary, size: 20),
            ],
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 10),
            child: Text(
              subtitle!,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
        Container(
          decoration: MobileDecorations.pillCard(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: rows[i],
                ),
                if (i != rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: dividerColor.withValues(alpha: 0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
