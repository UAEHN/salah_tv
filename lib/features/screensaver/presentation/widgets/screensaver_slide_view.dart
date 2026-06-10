import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/ticker_content.dart';

/// One screensaver slide: the sacred text in a Naskh face with its source
/// attribution beneath. Light text on the dark backdrop, sized for a glance
/// from across the room.
class ScreensaverSlideView extends StatelessWidget {
  final TickerItem item;
  final AccentPalette palette;

  const ScreensaverSlideView({
    super.key,
    required this.item,
    required this.palette,
  });

  static const Color _ink = Color(0xFFF3F7FF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1500),
                child: Text(
                  item.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 58,
                    color: _ink,
                    height: 2.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 44),
          Container(
            width: 70,
            height: 3,
            decoration: BoxDecoration(
              gradient: palette.gradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            item.source,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: palette.primary.withValues(alpha: 0.95),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
