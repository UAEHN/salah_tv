import 'package:flutter/material.dart';

/// Segmented-clock countdown: HH | MM | SS rendered as three pill-shaped
/// digit boxes. Designed to live inside a [FittedBox] so the whole row
/// scales together to fill the parent's width (or to scale down when
/// space is tight).
///
/// Used by the Today bento hero tile and the prayer-times screen hero
/// card — keep the visuals in lockstep by funneling both through here.
class BoxedCountdown extends StatelessWidget {
  final Duration countdown;
  final Color foreground;
  final double fontSize;

  /// Tint used for the digit box background and border. Defaults to
  /// [foreground] when omitted — pass a separate value when you want the
  /// digits one colour (e.g. black) and the surrounding boxes another
  /// (e.g. the active theme accent).
  final Color? boxTint;

  /// Drop the hours segment automatically when the duration is below
  /// one hour. Mirrors the existing `formatCountdown` behavior used in
  /// the rest of the prayer feature.
  final bool dropHoursWhenZero;

  const BoxedCountdown({
    super.key,
    required this.countdown,
    required this.foreground,
    required this.fontSize,
    this.boxTint,
    this.dropHoursWhenZero = true,
  });

  @override
  Widget build(BuildContext context) {
    final neg = countdown.isNegative;
    final abs = countdown.abs();
    final h = abs.inHours;
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final s = (abs.inSeconds % 60).toString().padLeft(2, '0');
    final showHours = !dropHoursWhenZero || h > 0;
    final hLabel = neg
        ? '-${h.toString().padLeft(2, '0')}'
        : h.toString().padLeft(2, '0');
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    final box = boxTint ?? foreground;

    final children = <Widget>[
      if (showHours) ...[
        _DigitBox(
          text: hLabel,
          textColor: foreground,
          boxColor: box,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
        _ColonSeparator(color: foreground, fontSize: fontSize),
      ],
      _DigitBox(
        text: m,
        textColor: foreground,
        boxColor: box,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
      _ColonSeparator(color: foreground, fontSize: fontSize),
      _DigitBox(
        text: s,
        textColor: foreground,
        boxColor: box,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
    ];

    // Force LTR so the clock reads HH : MM : SS left-to-right even in
    // Arabic (RTL) — matches how digital clocks are conventionally read.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color boxColor;
  final double fontSize;
  final String? fontFamily;

  const _DigitBox({
    required this.text,
    required this.textColor,
    required this.boxColor,
    required this.fontSize,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.18,
        vertical: fontSize * 0.12,
      ),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(fontSize * 0.22),
        border: Border.all(
          color: boxColor.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.6,
          height: 1.0,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _ColonSeparator extends StatelessWidget {
  final Color color;
  final double fontSize;

  const _ColonSeparator({required this.color, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.12),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: fontSize * 0.9,
          fontWeight: FontWeight.w900,
          color: color.withValues(alpha: 0.75),
          height: 1.0,
        ),
      ),
    );
  }
}
