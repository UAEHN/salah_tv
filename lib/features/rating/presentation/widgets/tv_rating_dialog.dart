import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/i_rating_service.dart';
import '../../../settings/presentation/settings_screen.dart';
import 'tv_rating_qr_panel.dart';

/// Landscape TV dialog: two QR codes (Play Store + Telegram) side by side.
/// Navigable via D-pad — "قيّمت" is auto-focused.
class TvRatingDialog extends StatelessWidget {
  const TvRatingDialog({super.key, required this.service});

  final IRatingService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TvRatingHeader(l: l),
            const SizedBox(height: 16),
            TvRatingQrPanel(
              url: AppConfig.playStoreUrl,
              icon: Icons.star_rounded,
              label: l.ratingDialogQrRate,
            ),
            const SizedBox(height: 16),
            _TvRatingActions(service: service),
          ],
        ),
      ),
    );
  }
}

class _TvRatingHeader extends StatelessWidget {
  const _TvRatingHeader({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Text(
      l.ratingDialogTitle,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TvRatingActions extends StatelessWidget {
  const _TvRatingActions({required this.service});

  final IRatingService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TvButton(
          label: l.ratingDialogYes,
          autofocus: true,
          isPrimary: true,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.markAsRated();
            final marketUri = Uri.parse(AppConfig.playStoreMarketUrl);
            final webUri = Uri.parse(AppConfig.playStoreUrl);
            final launched = await launchUrl(
              marketUri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              await launchUrl(webUri, mode: LaunchMode.externalApplication);
            }
          },
        ),
        const SizedBox(width: 20),
        _TvButton(
          label: l.ratingDialogSuggest,
          autofocus: false,
          isPrimary: false,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.snooze();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(initialIndex: 7),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        _TvButton(
          label: l.ratingDialogLater,
          autofocus: false,
          isPrimary: false,
          onPressed: () async {
            Navigator.of(context).pop();
            await service.snooze();
          },
        ),
      ],
    );
  }
}

class _TvButton extends StatefulWidget {
  const _TvButton({
    required this.label,
    required this.autofocus,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool autofocus;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  State<_TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<_TvButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isPrimary
        ? (_isFocused ? Colors.amberAccent : Colors.amber)
        : Colors.transparent;
    final borderColor = widget.isPrimary
        ? (_isFocused ? Colors.white : Colors.transparent)
        : (_isFocused ? Colors.amberAccent : Colors.white30);
    final fgColor = widget.isPrimary ? Colors.black : Colors.white;

    return AnimatedScale(
      scale: _isFocused ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 200,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 2.5 : 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Focus(
          autofocus: widget.autofocus,
          onFocusChange: (v) => setState(() => _isFocused = v),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
              widget.onPressed();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: widget.onPressed,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onPressed,
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 15,
                    fontWeight: widget.isPrimary
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
