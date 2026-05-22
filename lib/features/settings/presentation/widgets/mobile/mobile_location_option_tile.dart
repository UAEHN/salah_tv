import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Single country / city row in the location bottom sheet. Slim, theme-aware
/// design with a leading accent dot when selected and a trailing chevron.
class MobileLocationOptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const MobileLocationOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.45)
                    : MobileColors.border(context),
                width: 1,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _LeadingDot(isSelected: isSelected, accent: accent),
                const SizedBox(width: 12),
                Expanded(child: _Texts(
                  title: title,
                  subtitle: subtitle,
                  isSelected: isSelected,
                  accent: accent,
                )),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_rounded
                      : Icons.chevron_left_rounded,
                  color: isSelected
                      ? accent
                      : MobileColors.onSurfaceMuted(context)
                          .withValues(alpha: 0.55),
                  size: isSelected ? 20 : 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadingDot extends StatelessWidget {
  final bool isSelected;
  final Color accent;
  const _LeadingDot({required this.isSelected, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? accent
            : MobileColors.onSurfaceMuted(context).withValues(alpha: 0.25),
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final Color accent;

  const _Texts({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isSelected ? accent : MobileColors.onSurface(context),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              color: MobileColors.onSurfaceMuted(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}
