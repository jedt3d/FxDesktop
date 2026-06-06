import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listbox_demo/main.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  testWidgets('FxListBox Demo app navigation smoke test', (
    WidgetTester tester,
  ) async {
    // Set a desktop-sized window
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build the app
    await tester.pumpWidget(const FxListBoxDemoApp());

    // Verify app title and start on Page 1 / 8
    expect(find.text('FxListBox Interactive Spec Gallery'), findsOneWidget);
    expect(find.text('Page 1 / 8'), findsOneWidget);

    // Verify Previous button is disabled (or does nothing/null callback)
    final prevButtonFinder = find.widgetWithText(FxButton, 'Previous');
    expect(prevButtonFinder, findsOneWidget);
    final prevButtonWidget = tester.widget<FxButton>(prevButtonFinder);
    expect(prevButtonWidget.onPressed, isNull);

    // Verify Next button is enabled and click it
    final nextButtonFinder = find.widgetWithText(FxButton, 'Next');
    expect(nextButtonFinder, findsOneWidget);
    final nextButtonWidget = tester.widget<FxButton>(nextButtonFinder);
    expect(nextButtonWidget.onPressed, isNotNull);

    // Tap Next
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    // Verify we navigated to Page 2 / 8
    expect(find.text('Page 2 / 8'), findsOneWidget);

    // Verify Previous button is now enabled
    final prevButtonWidget2 = tester.widget<FxButton>(prevButtonFinder);
    expect(prevButtonWidget2.onPressed, isNotNull);

    // Tap Previous to return to Page 1
    await tester.tap(prevButtonFinder);
    await tester.pumpAndSettle();

    // Verify we are back on Page 1 / 8
    expect(find.text('Page 1 / 8'), findsOneWidget);
  });
}
