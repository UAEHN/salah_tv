import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Standard settings row: rounded card with a leading themed icon, a title,
/// an optional subtitle, and a trailing chevron. Press feedback gently
/// tints the surface so the touch is felt before the navigation lands.
class MobileSettingsTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;

  const MobileSettingsTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  @override
  State<MobileSettingsTile> createState() => _MobileSettingsTileState();
}

class _MobileSettingsTileState extends State<MobileSettingsTile> {
  bool _isPressed = false;

  void _setPressed(bool v) {
    if (_isPressed != v) setState(() => _isPressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    final cardColor = MobileColors.cardColor(context);
    final accent = MobileColors.activePrimary(context);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed
              ? cardColor.withValues(alpha: isDark ? 0.85 : 1.0)
              : cardColor.withValues(alpha: isDark ? 0.55 : 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MobileColors.border(context), width: 1),
          boxShadow: MobileShadows.sleekCard(context),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            if (widget.icon != null) ...[
              _LeadingIcon(icon: widget.icon!, accent: accent),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: _TitleSubtitle(
                title: widget.title,
                subtitle: widget.subtitle,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_left_rounded,
              color: MobileColors.onSurfaceMuted(
                context,
              ).withValues(alpha: 0.55),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _LeadingIcon({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: accent, size: 18),
    );
  }
}

class _TitleSubtitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _TitleSubtitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: MobileTextStyles.titleMd(context).copyWith(
            color: MobileColors.onSurface(context),
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: MobileColors.onSurfaceMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}
