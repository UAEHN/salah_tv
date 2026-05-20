import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';

/// Focusable D-Pad button that opens Google Play.
/// Tries the `market://` deep link first (opens Play Store app directly),
/// then falls back to the web URL passed in [storeUrl].
class TvOpenStoreButton extends StatefulWidget {
  const TvOpenStoreButton({
    super.key,
    required this.storeUrl,
    required this.label,
    this.autofocus = true,
    this.onAfterLaunch,
  });

  final String storeUrl;
  final String label;
  final bool autofocus;
  final VoidCallback? onAfterLaunch;

  @override
  State<TvOpenStoreButton> createState() => _TvOpenStoreButtonState();
}

class _TvOpenStoreButtonState extends State<TvOpenStoreButton> {
  bool _isFocused = false;

  Future<void> _open() async {
    final market = Uri.parse(AppConfig.playStoreMarketUrl);
    final web = Uri.parse(widget.storeUrl);
    try {
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    widget.onAfterLaunch?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _isFocused = v),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          _open();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: _isFocused
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  )
                : null,
            color: _isFocused ? null : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF10B981)
                  : Colors.white.withValues(alpha: 0.2),
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    const BoxShadow(
                      color: Color(0x6010B981),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.system_update_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
