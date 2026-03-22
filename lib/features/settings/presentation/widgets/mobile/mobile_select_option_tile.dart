import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileSelectOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MobileSelectOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? MobileColors.cardColor(context).withValues(alpha: 0.55)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? MobileColors.primaryContainer.withValues(alpha: 0.5)
                : MobileColors.border(context),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? MobileColors.onSurface(context)
                  : MobileColors.onSurfaceMuted(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: isSelected
                      ? MobileColors.onSurface(context)
                      : MobileColors.onSurfaceMuted(context),
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MobileColors.primaryContainer
                      : MobileColors.onSurfaceMuted(context),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: MobileColors.primaryContainer,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
