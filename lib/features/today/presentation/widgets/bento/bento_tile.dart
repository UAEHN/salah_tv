import 'package:flutter/material.dart';

/// Shared container for every tile in the bento grid.
///
/// Adaptive contrast: when the sky band behind the screen is dark
/// (pre-fajr / isha / night) the tiles flip to a deep solid surface so the
/// foreground text — which is rendered against this surface, not against the
/// sky gradient — keeps a strong contrast. During the lighter bands (dawn →
/// sunset) the tiles stay frosty white.
///
/// `BentoSurface.of(context)` exposes the resolved foreground/surface colors
/// to descendants without forcing every tile to take props.
///
/// The default rendering path uses the inherited `surface.tileColor`. A tile
/// can opt into a custom [gradient] / [borderColor] (e.g. the Hero countdown
/// tile that wants palette-tinted styling) without leaking that styling
/// math into widget code — the gradient itself is computed by helpers on
/// [BentoSurface] (CLAUDE.md §3 — no logic in widgets).
class BentoTile extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  /// Optional fill — overrides [BentoSurface.tileColor] when set.
  final Gradient? gradient;

  /// Optional border colour — overrides [BentoSurface.tileBorder] when set.
  final Color? borderColor;

  /// Optional border thickness (defaults to 1; the Hero tile uses 2.5).
  final double borderWidth;

  /// Optional drop shadow (e.g. accent shadow under the Hero tile).
  final List<BoxShadow>? boxShadow;

  const BentoTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final surface = BentoSurface.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? surface.tileColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? surface.tileBorder,
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Resolved palette for the bento layer — provided by an `InheritedWidget`
/// at the screen root so every tile knows whether to render on a "dark sky"
/// or "light sky" without propping the flag down through constructors.
class BentoSurface extends InheritedWidget {
  /// True when the sky background sits in the dark bands (pre-fajr, isha,
  /// night) OR when the user has explicitly opted into dark mode.
  final bool isDarkSky;

  const BentoSurface({
    super.key,
    required this.isDarkSky,
    required super.child,
  });

  static BentoSurface of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<BentoSurface>();
    return widget ?? const BentoSurface(isDarkSky: false, child: SizedBox());
  }

  /// Tile background — a solid charcoal on dark sky, a frosty white on
  /// light sky. Solid colors keep a high contrast against the painted text
  /// regardless of what gradient sits behind the tile.
  Color get tileColor => isDarkSky
      ? const Color(0xFF1A1B2E).withValues(alpha: 0.92)
      : Colors.white.withValues(alpha: 0.86);

  /// Hairline border — subtle on both modes so the tile reads as a card
  /// without feeling boxed in.
  Color get tileBorder => isDarkSky
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.04);

  /// Primary foreground (titles, big numbers).
  Color get foreground => isDarkSky ? Colors.white : const Color(0xFF1A1A24);

  /// Muted foreground (captions, eyebrow labels).
  Color get foregroundMuted => isDarkSky
      ? Colors.white.withValues(alpha: 0.62)
      : const Color(0xFF5C6370);

  /// Hero countdown colour. The Hero now sits on a saturated palette
  /// gradient in **both** modes (full accent in light mode, semi-accent
  /// in dark) so the text always reads white against it. Other tiles
  /// keep using `foreground` for their text.
  Color get countdownColor => Colors.white;

  /// Palette-saturated gradient for the Hero (countdown) tile.
  ///
  /// • **Light**: full primary → primaryContainer. The card becomes a
  ///   solid coloured statement against the soft beige background —
  ///   text, dot, progress bar all render in white over it.
  /// • **Dark**: luminous accent at top-left fading into the secondary
  ///   tint at bottom-right; matches the look already approved on the
  ///   night canvas.
  Gradient accentTileGradient(Color primary, Color primaryContainer) {
    // 3-stop diagonal — a slightly brighter "near" stop pulls the eye to
    // the top-leading corner and gives the surface a sense of light/depth
    // instead of reading as a flat 2-colour ramp.
    final lift = Color.lerp(primary, Colors.white, 0.18) ?? primary;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.55, 1.0],
      colors: isDarkSky
          ? [
              primary.withValues(alpha: 0.46),
              primary.withValues(alpha: 0.32),
              primaryContainer.withValues(alpha: 0.18),
            ]
          : [lift, primary, primaryContainer],
    );
  }

  /// Border colour for the saturated Hero tile. Light mode uses a thin
  /// white inner-stroke for a "rim light" finish; dark mode keeps the
  /// accent border so the tile reads against the night sky.
  Color accentTileBorder(Color primary) => isDarkSky
      ? primary.withValues(alpha: 0.45)
      : Colors.white.withValues(alpha: 0.22);

  /// Width of the accent border.
  double get accentTileBorderWidth => 1.0;

  /// Strong palette-tinted shadow projected under the Hero tile so it
  /// lifts off the background. Light mode pushes alpha up so the halo
  /// registers against the warm beige gradient.
  BoxShadow accentTileShadow(Color primary) => BoxShadow(
    color: primary.withValues(alpha: isDarkSky ? 0.22 : 0.36),
    blurRadius: isDarkSky ? 26 : 32,
    offset: const Offset(0, 14),
    spreadRadius: -6,
  );

  @override
  bool updateShouldNotify(BentoSurface oldWidget) =>
      oldWidget.isDarkSky != isDarkSky;
}
