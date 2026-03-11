import 'package:flutter/material.dart';
import 'flip_digit.dart';

/// Displays a formatted time string (e.g. "05:23:41") as a flip-clock.
/// Each digit slides up independently when its value changes.
/// Colons and other separators are rendered as static text.
class FlipClock extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double digitWidth;
  final double digitHeight;
  final double gap;

  const FlipClock({
    super.key,
    required this.text,
    required this.style,
    required this.digitWidth,
    required this.digitHeight,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < chars.length; i++) ...[
            if (i > 0 && _isDigit(chars[i]) && _isDigit(chars[i - 1]))
              SizedBox(width: gap),
            if (_isDigit(chars[i]))
              FlipDigit(
                key: ValueKey('digit_$i'),
                value: chars[i],
                width: digitWidth,
                height: digitHeight,
                style: style,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Text(
                  chars[i],
                  style: style.copyWith(shadows: null, height: 1),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static bool _isDigit(String c) =>
      c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}
