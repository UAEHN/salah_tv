import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/onboarding/presentation/widgets/tv_onboarding_search_field.dart';

/// Regression guard for the TV onboarding search bar being unreachable by D-pad:
/// the wrapper Focus must NOT be a focus stop — DPad-Up from the list below must
/// land on the editable TextField, and DPad-Down must return to the list.
void main() {
  Future<void> pumpHarness(WidgetTester tester, FocusNode listNode) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TvOnboardingSearchField(
                controller: TextEditingController(),
                hint: 'search',
                onChanged: (_) {},
              ),
              // Stand-in for the first list row below the search bar.
              Focus(
                focusNode: listNode,
                autofocus: true,
                child: const SizedBox(height: 72, width: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('DPad-Up from the list lands on the editable search field', (
    tester,
  ) async {
    final listNode = FocusNode();
    addTearDown(listNode.dispose);
    await pumpHarness(tester, listNode);
    await tester.pump();

    expect(listNode.hasFocus, isTrue, reason: 'list row starts focused');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(
      editable.focusNode.hasFocus,
      isTrue,
      reason: 'Up must focus the TextField itself, not a dead wrapper',
    );
  });

  testWidgets('DPad-Down from the search field returns to the list', (
    tester,
  ) async {
    final listNode = FocusNode();
    addTearDown(listNode.dispose);
    await pumpHarness(tester, listNode);
    await tester.pump();

    // Move up into the search field first.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    // Then back down to the list.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(listNode.hasFocus, isTrue);
  });
}
