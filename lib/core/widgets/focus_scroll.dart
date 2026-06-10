import 'package:flutter/widgets.dart';

/// Call from a [Focus.onFocusChange] handler when focus is gained, to scroll
/// the focused widget fully into view inside the nearest [Scrollable].
///
/// Reserves [topPadding] above the focused widget so the (non-focusable)
/// section title sitting above stays visible — fixes the TV-remote case
/// where pressing UP onto the first row of a section left the title clipped.
void ensureFocusedVisible(BuildContext context, {double topPadding = 100.0}) {
  if (!context.mounted) return;
  final scrollable = Scrollable.maybeOf(context);
  if (scrollable == null) return;
  final widgetBox = context.findRenderObject() as RenderBox?;
  if (widgetBox == null || !widgetBox.hasSize) return;
  final scrollableBox = scrollable.context.findRenderObject() as RenderBox?;
  if (scrollableBox == null) return;

  final position = scrollable.position;
  final widgetTop = widgetBox
      .localToGlobal(Offset.zero, ancestor: scrollableBox)
      .dy;
  final widgetHeight = widgetBox.size.height;
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
