import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

class MobileAdhanSoundTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const MobileAdhanSoundTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isPlaying,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            _RadioCircle(isSelected: isSelected),
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
              ),
            ),
            _PreviewButton(isPlaying: isPlaying, onTap: onPreview),
          ],
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PreviewButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying
              ? MobileColors.primaryContainer.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isPlaying
                ? MobileColors.primaryContainer
                : MobileColors.border(context),
          ),
        ),
        child: Icon(
          isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          size: 18,
          color: isPlaying
              ? MobileColors.primaryContainer
              : MobileColors.onSurfaceMuted(context),
        ),
      ),
    );
  }
}
