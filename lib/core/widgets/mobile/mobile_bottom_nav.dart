import 'dart:ui';
import 'package:flutter/material.dart';
import '../../mobile_theme.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;

  const MobileBottomNav({
    super.key,
    this.currentIndex = 3,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.85),
              border: Border.all(color: MobileColors.border(context), width: 1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: MobileColors.shadowDark(context),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  label: 'الإعدادات',
                  isActive: currentIndex == 0,
                  onTap: () => _onItemTap(context, 0, '/settings'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.explore_outlined,
                  label: 'القبلة',
                  isActive: currentIndex == 1,
                  onTap: () => _onItemTap(context, 1, '/qibla'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.auto_stories_rounded,
                  label: 'الأذكار',
                  isActive: currentIndex == 2,
                  onTap: () => _onItemTap(context, 2, '/adhkar'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.mosque_rounded,
                  label: 'الصلاة',
                  isActive: currentIndex == 3,
                  onTap: () => _onItemTap(context, 3, '/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
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
              const SizedBox(width: 8),
              Text(
                label,
                style: MobileTextStyles.labelSm(
                  context,
                ).copyWith(color: Colors.white, fontSize: 12),
              ),
            ],
          ],
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
