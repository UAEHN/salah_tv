import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_config.dart';
import '../../../../core/widgets/focus_scroll.dart';

/// Button to check for updates (opens Google Play Store)
class SettingsUpdateButton extends StatefulWidget {
  final ThemeColors tc;
  final AccentPalette palette;

  const SettingsUpdateButton({
    required this.tc,
    required this.palette,
    super.key,
  });

  @override
  State<SettingsUpdateButton> createState() => _SettingsUpdateButtonState();
}

class _SettingsUpdateButtonState extends State<SettingsUpdateButton> {
  bool _isFocused = false;

  Future<void> _launchPlayStore() async {
    final Uri marketUri = Uri.parse(AppConfig.playStoreMarketUrl);
    final Uri webUri = Uri.parse(AppConfig.playStoreUrl);
    
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    
    return Focus(
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _launchPlayStore();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _launchPlayStore,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _isFocused ? widget.palette.primary : widget.palette.primary.withValues(alpha: 0.12),
            border: Border.all(
              color: _isFocused
                  ? Colors.white.withValues(alpha: 0.55)
                  : widget.palette.primary.withValues(alpha: 0.35),
              width: _isFocused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: widget.palette.primary.withValues(alpha: 0.40),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.system_update_rounded,
                color: _isFocused ? Colors.white : widget.palette.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  l.settingsCheckUpdate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _isFocused ? Colors.white : widget.palette.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
