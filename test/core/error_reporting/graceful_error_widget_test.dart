import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/widgets/graceful_error_widget.dart';

void main() {
  testWidgets('paints a calm fallback frame without throwing', (tester) async {
    await tester.pumpWidget(
      GracefulErrorWidget(
        details: FlutterErrorDetails(exception: Exception('boom')),
      ),
    );
    expect(find.text('لحظة من فضلك…'), findsOneWidget);
  });

  testWidgets('replaces a widget that throws during build', (tester) async {
    final previous = ErrorWidget.builder;
    ErrorWidget.builder = (d) => GracefulErrorWidget(details: d);

    await tester.pumpWidget(
      Builder(builder: (_) => throw Exception('render boom')),
    );
    expect(tester.takeException(), isA<Exception>());
    // The user sees the fallback, not a blank/grey box.
    expect(find.text('لحظة من فضلك…'), findsOneWidget);

    ErrorWidget.builder = previous; // restore within the test body
  });
}
