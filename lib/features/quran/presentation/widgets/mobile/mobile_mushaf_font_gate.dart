import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/quran_assets_cubit.dart';

/// Ensures the QCF v2 page font for [pageNumber] is registered with the
/// Flutter engine before rendering [child]. While the font is loading
/// — typically a single-digit-millisecond cost for an already-on-disk
/// `.woff` — a transparent placeholder is shown so the RichText below
/// never paints with a fallback font.
///
/// Pre-fetches the two adjacent pages right after the current page is
/// painted so a swipe-left or swipe-right encounters an already-loaded
/// font and never blocks the page-flip animation.
///
/// Background: registering all 604 fonts up front froze the UI for
/// 2–6 s on TV / mid-range devices because every `FontLoader.load()`
/// rebuilds Skia's font collection on the platform thread. Doing the
/// work one page at a time (plus two neighbors) keeps each register
/// well inside one frame and makes the cost invisible to the user.
class MobileMushafFontGate extends StatefulWidget {
  final int pageNumber;
  final Widget child;

  const MobileMushafFontGate({
    super.key,
    required this.pageNumber,
    required this.child,
  });

  @override
  State<MobileMushafFontGate> createState() => _MobileMushafFontGateState();
}

class _MobileMushafFontGateState extends State<MobileMushafFontGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ensure();
  }

  @override
  void didUpdateWidget(covariant MobileMushafFontGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _ready = false;
      _ensure();
    }
  }

  Future<void> _ensure() async {
    final cubit = context.read<QuranAssetsCubit>();
    final targetPage = widget.pageNumber;
    if (cubit.isFontRegistered(targetPage)) {
      _ready = true;
      _prefetchNeighbors(cubit);
      return;
    }
    final ok = await cubit.ensureFontForPage(targetPage);
    // A swipe could have pointed `widget.pageNumber` at a different
    // page while we awaited — bail out if so; `didUpdateWidget` will
    // have fired a fresh `_ensure` for the new page.
    if (!mounted || widget.pageNumber != targetPage) return;
    if (ok) {
      setState(() => _ready = true);
      _prefetchNeighbors(cubit);
    }
  }

  void _prefetchNeighbors(QuranAssetsCubit cubit) {
    // Fire-and-forget. The repository coalesces duplicates so it is
    // safe to call for pages that another gate already requested.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = widget.pageNumber;
      if (p > 1) cubit.ensureFontForPage(p - 1);
      if (p < 604) cubit.ensureFontForPage(p + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    // Transparent placeholder of the same size as the page so the
    // PageView's metrics stay stable while the font registers.
    return const SizedBox.expand();
  }
}
