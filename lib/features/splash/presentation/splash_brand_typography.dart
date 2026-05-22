import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);
const _accentSoft = Color(0xFFF0CD7A);

/// App title rendered in clean gold typography. No shimmer sweep — relies on
/// a soft warm glow shadow for premium feel without the visual noise.
class SplashTitle extends StatelessWidget {
  final String text;
  final double height;
  const SplashTitle({super.key, required this.text, required this.height});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: height * 0.13,
        fontWeight: FontWeight.w700,
        letterSpacing: 4,
        color: _accentSoft,
        shadows: [
          Shadow(color: _accent.withValues(alpha: 0.35), blurRadius: 24),
        ],
      ),
    );
  }
}

/// Quranic verse with one highlighted word — soft white body, calm gold
/// emphasis. No glow shadow on the highlight (the previous version felt
/// hot and over-decorated).
class SplashVerse extends StatelessWidget {
  final String start;
  final String highlight;
  final String end;
  final double height;

  const SplashVerse({
    super.key,
    required this.start,
    required this.highlight,
    required this.end,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: height * 0.026,
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.7,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(text: start),
            TextSpan(
              text: highlight,
              style: const TextStyle(
                color: _accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: end),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
