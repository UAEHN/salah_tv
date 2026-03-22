import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileLocationOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const MobileLocationOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? MobileColors.primary.withValues(alpha: 0.15)
            : MobileColors.cardColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? MobileColors.primary.withValues(alpha: 0.5)
              : MobileColors.border(context),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? MobileColors.primary
                : MobileColors.onSurface(context),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Tajawal',
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: MobileColors.primary)
            : Icon(
                Icons.arrow_forward_ios,
                color: MobileColors.onSurfaceMuted(context),
                size: 16,
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
