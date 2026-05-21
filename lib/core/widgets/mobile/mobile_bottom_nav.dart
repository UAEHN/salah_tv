import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import 'mobile_bottom_nav_item.dart';

/// Floating glass bottom-nav.
///
/// Visual language: a frosted pill that sits well above the system gesture
/// area, with each tab rendered as `[ glow-circle icon ] + label`. The
/// active tab gets a tinted disc + accent glow behind the icon, and the
/// label switches to the accent colour at full weight. Inactive tabs stay
/// muted but still show their labels (modern stack style — Spotify / iOS).
class MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;

  const MobileBottomNav({super.key, this.currentIndex = 5, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (icon: Icons.settings_rounded,     label: l.navSettings, index: 0, route: '/settings'),
      (icon: Icons.explore_outlined,     label: l.navQibla,    index: 1, route: '/qibla'),
      (icon: Icons.mosque_rounded,       label: l.navPrayer,   index: 2, route: '/'),
      (icon: Icons.auto_stories_rounded, label: l.navAdhkar,   index: 3, route: '/adhkar'),
      (icon: Icons.menu_book_rounded,    label: l.navMushaf,   index: 4, route: '/'),
      (icon: Icons.home_rounded,         label: l.navToday,    index: 5, route: '/'),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset + 6,
        left: 24,
        right: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF1A1B2E) : Colors.white)
                  .withValues(alpha: isDark ? 0.55 : 0.72),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: isDark ? 0.08 : 0.05),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: MobileBottomNavItem(
                        icon: item.icon,
                        label: item.label,
                        isActive: currentIndex == item.index,
                        onTap: () =>
                            _onItemTap(context, item.index, item.route),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTap(BuildContext context, int index, String route) {
    if (currentIndex == index) return;
    if (onTabChanged != null) {
      onTabChanged!(index);
    } else {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == route) return;
      Navigator.of(context).pushReplacementNamed(route);
    }
  }
}
