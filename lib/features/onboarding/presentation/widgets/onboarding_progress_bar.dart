import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);

/// Minimal two-step indicator for the onboarding flow (language → location).
/// Just a thin track with numbered nodes that fill in as the user
/// progresses. No animation noise, no text labels — the page title already
/// tells the user where they are.
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep; // 0, 1

  const OnboardingProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          for (int i = 0; i < 2; i++) ...[
            _StepNode(index: i, currentStep: currentStep),
            if (i < 1) Expanded(child: _Connector(isFilled: currentStep > i)),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final int index;
  final int currentStep;
  const _StepNode({required this.index, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentStep;
    final isDone = index < currentStep;
    final isOn = isActive || isDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOn ? _accent : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: isOn ? _accent : Colors.white.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, color: Color(0xFF1A1208), size: 14)
          : Text(
              '${index + 1}',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF1A1208)
                    : Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isFilled;
  const _Connector({required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            widthFactor: isFilled ? 1.0 : 0.0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
