import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../mobile_theme.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;

  const MobileBottomNav({super.key, this.currentIndex = 3, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cardColor = MobileColors.cardColor(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final items = [
      (icon: Icons.settings_rounded,     label: l.navSettings, index: 0, route: '/settings'),
      (icon: Icons.explore_outlined,     label: l.navQibla,    index: 1, route: '/qibla'),
      (icon: Icons.auto_stories_rounded, label: l.navAdhkar,   index: 2, route: '/adhkar'),
      (icon: Icons.mosque_rounded,       label: l.navPrayer,   index: 3, route: '/'),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset + 12,
        left: 32,
        right: 32,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.85),
              border: Border.all(
                color: MobileColors.border(context),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: MobileColors.shadowDark(context),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      // Active item gets more horizontal space for its label
                      flex: currentIndex == item.index ? 2 : 1,
                      child: _NavItem(
                        icon: item.icon,
                        label: item.label,
                        isActive: currentIndex == item.index,
                        onTap: () => _onItemTap(context, item.index, item.route),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: isActive
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [MobileColors.primary, MobileColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MobileColors.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : const BoxDecoration(color: Colors.transparent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : MobileColors.onSurfaceMuted(context),
                size: 22,
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: MobileTextStyles.labelSm(context)
                        .copyWith(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
