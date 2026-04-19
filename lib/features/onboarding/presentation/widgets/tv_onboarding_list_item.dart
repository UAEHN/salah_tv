import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/brand_colors.dart';

/// A premium, D-Pad navigable list item for TV onboarding.
/// Features a scale effect, glassmorphism, and golden glow on focus.
class TvOnboardingListItem extends StatefulWidget {
  const TvOnboardingListItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onSelect,
    this.autofocus = false,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onSelect;
  final bool autofocus;

  @override
  State<TvOnboardingListItem> createState() => _TvOnboardingListItemState();
}

class _TvOnboardingListItemState extends State<TvOnboardingListItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isFocused;
    final scale = _isFocused ? 1.05 : 1.0;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _isFocused = v),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          widget.onSelect();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isFocused
                    ? brandGold
                    : widget.isSelected
                        ? brandGold.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: _isFocused || widget.isSelected
                      ? brandGold
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: brandGold.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 22,
                              color: isHighlighted
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                              fontWeight: isHighlighted
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isSelected) ...[
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: brandGold,
                            size: 28,
                          ),
                        ],
                      ],
                    ),
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
