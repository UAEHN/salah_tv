import 'package:flutter/widgets.dart';

/// Call from a [Focus.onFocusChange] handler when focus is gained, to scroll
/// the focused widget fully into view inside the nearest [Scrollable].
///
/// Reserves [topPadding] above the focused widget so the (non-focusable)
/// section title sitting above stays visible — fixes the TV-remote case
/// where pressing UP onto the first row of a section left the title clipped.
void ensureFocusedVisible(BuildContext context, {double topPadding = 100.0}) {
  if (!context.mounted) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _ensureFocusedVisibleAfterLayout(context, topPadding: topPadding);
  });
}

void _ensureFocusedVisibleAfterLayout(
  BuildContext context, {
  required double topPadding,
}) {
  if (!context.mounted) return;
  final scrollable = Scrollable.maybeOf(context);
  if (scrollable == null) return;
  final widgetBox = context.findRenderObject() as RenderBox?;
  if (widgetBox == null || !widgetBox.hasSize) return;
  final scrollableBox = scrollable.context.findRenderObject() as RenderBox?;
  if (scrollableBox == null || !scrollableBox.hasSize) return;

  final position = scrollable.position;
  if (!position.hasPixels || !position.hasContentDimensions) return;

  late final double widgetTop;
  late final double widgetHeight;
  try {
    widgetTop = widgetBox
        .localToGlobal(Offset.zero, ancestor: scrollableBox)
        .dy;
    widgetHeight = widgetBox.size.height;
  } on FlutterError {
    return;
  }

  final viewportHeight = position.viewportDimension;
  final scrollOffset = position.pixels;
  const bottomPadding = 16.0;

  double target = scrollOffset;
  if (widgetTop < topPadding) {
    // Widget is at or above the top edge — scroll up so the title fits above.
    target = (scrollOffset + widgetTop - topPadding).clamp(
      0.0,
      position.maxScrollExtent,
    );
  } else if (widgetTop + widgetHeight + bottomPadding > viewportHeight) {
    // Widget bottom below viewport — scroll down to reveal it.
    target =
        (scrollOffset +
                widgetTop +
                widgetHeight +
                bottomPadding -
                viewportHeight)
            .clamp(0.0, position.maxScrollExtent);
  }

  if ((target - scrollOffset).abs() > 1.0) {
    position.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}
