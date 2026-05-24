import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Two-state segmented control used to flip the index between the
/// surah list and the juz list.
enum MushafIndexMode { surahs, juz }

class MobileMushafIndexToggle extends StatelessWidget {
  final MushafIndexMode mode;
  final ValueChanged<MushafIndexMode> onChanged;
  const MobileMushafIndexToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'السور',
            selected: mode == MushafIndexMode.surahs,
            onTap: () => onChanged(MushafIndexMode.surahs),
          ),
          _Segment(
            label: 'الأجزاء',
            selected: mode == MushafIndexMode.juz,
            onTap: () => onChanged(MushafIndexMode.juz),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: MobileTextStyles.bodyMd(context).copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.primary
                    : MobileColors.onSurfaceMuted(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
