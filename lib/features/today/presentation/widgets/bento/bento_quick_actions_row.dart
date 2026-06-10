import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';
import '../../../../tasbih/presentation/widgets/tasbih_icon.dart';
import 'bento_tile.dart';

/// Section with three navigational tiles. Headed by an editorial eyebrow
/// label so the row reads as a proper "Quick access" section rather than
/// floating buttons.
class BentoQuickActionsRow extends StatelessWidget {
  const BentoQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final muted = BentoSurface.of(context).foregroundMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l.todayQuickAccessTitle.toUpperCase(),
                  style: MobileTextStyles.labelSm(context).copyWith(
                    fontSize: 11,
                    color: muted,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ActionTile(
                icon: TasbihIcon(
                  size: 22,
                  color: MobileColors.activePrimary(context),
                ),
                label: l.todayQuickActionTasbih,
                onTap: () => Navigator.of(context).pushNamed('/tasbih'),
              ),
              const SizedBox(width: 10),
              _ActionTile(
                icon: Icon(
                  Icons.auto_stories_rounded,
                  size: 20,
                  color: MobileColors.activePrimary(context),
                ),
                label: l.todayQuickActionAdhkar,
                onTap: () => MobileShell.switchTab(context, 3),
              ),
              const SizedBox(width: 10),
              _ActionTile(
                icon: Icon(
                  Icons.explore_outlined,
                  size: 20,
                  color: MobileColors.activePrimary(context),
                ),
                label: l.todayQuickActionQibla,
                onTap: () => MobileShell.switchTab(context, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.32),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ]
                  : const [],
            ),
            child: BentoTile(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              radius: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: widget.icon,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    style: MobileTextStyles.labelSm(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: surface.foreground,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
