import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Tile for a user-imported adhan. Mirrors [MobileAdhanSoundTile] visuals
/// but exposes rename/delete buttons instead of being a simple radio row.
class MobileCustomAdhanTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onSelect;
  final VoidCallback onPreview;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const MobileCustomAdhanTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isPlaying,
    required this.onSelect,
    required this.onPreview,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            _RadioDot(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: isSelected
                      ? MobileColors.onSurface(context)
                      : MobileColors.onSurfaceMuted(context),
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _IconBtn(
              icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              isActive: isPlaying,
              onTap: onPreview,
            ),
            const SizedBox(width: 6),
            _IconBtn(
              icon: Icons.edit_rounded,
              isActive: false,
              onTap: onRename,
            ),
            const SizedBox(width: 6),
            _IconBtn(
              icon: Icons.delete_outline_rounded,
              isActive: false,
              onTap: onDelete,
              danger: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? MobileColors.primaryContainer
              : MobileColors.onSurfaceMuted(context),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: isSelected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.primaryContainer,
              ),
            )
          : null,
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool danger;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = danger ? Colors.redAccent : MobileColors.primaryContainer;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? accent.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isActive ? accent : MobileColors.border(context),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive || danger
              ? accent
              : MobileColors.onSurfaceMuted(context),
        ),
      ),
    );
  }
}
