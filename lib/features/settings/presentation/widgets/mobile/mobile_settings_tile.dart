import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileSettingsTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const MobileSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  State<MobileSettingsTile> createState() => _MobileSettingsTileState();
}

class _MobileSettingsTileState extends State<MobileSettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? cardColor.withValues(alpha: 0.8)
              : cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MobileColors.border(context).withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: MobileShadows.sleekCard(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left icon
            Icon(
              Icons.chevron_left_rounded,
              color: MobileColors.onSurfaceMuted(
                context,
              ).withValues(alpha: 0.6),
              size: 20,
            ),

            // Text Content (Right-aligned for RTL)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: MobileTextStyles.titleMd(context).copyWith(
                      color: MobileColors.onSurface(context),
                      fontSize: 16,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: MobileTextStyles.bodyMd(context).copyWith(
                        color: MobileColors.onSurfaceMuted(context),
                        fontSize: 12,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
