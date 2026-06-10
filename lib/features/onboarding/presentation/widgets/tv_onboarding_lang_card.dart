import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/brand_colors.dart';
import '../onboarding_cubit.dart';

/// A focusable language selection card for TV onboarding.
/// Calls [OnboardingCubit.selectLanguageAndAdvance] on select.
class TvOnboardingLangCard extends StatefulWidget {
  const TvOnboardingLangCard({
    super.key,
    required this.label,
    required this.sublabel,
    required this.locale,
    required this.isSelected,
    this.autofocus = false,
  });

  final String label;
  final String sublabel;
  final String locale;
  final bool isSelected;
  final bool autofocus;

  @override
  State<TvOnboardingLangCard> createState() => _TvOnboardingLangCardState();
}

class _TvOnboardingLangCardState extends State<TvOnboardingLangCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isFocused;

    void handleSelect() {
      context.read<OnboardingCubit>().selectLanguageAndAdvance(widget.locale);
    }

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _isFocused = v),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          handleSelect();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: handleSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 200,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isSelected
                ? brandGold.withValues(alpha: 0.15)
                : _isFocused
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: widget.isSelected
                  ? brandGold
                  : _isFocused
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: brandGold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 36,
                color: isHighlighted
                    ? brandGold
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                widget.sublabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
