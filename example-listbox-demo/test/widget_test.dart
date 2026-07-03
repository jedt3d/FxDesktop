// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

import '../lib/main.dart';

void main() {
  testWidgets('data gallery renders the DS sections', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FxListBoxDemoApp());
    await tester.pumpAndSettle();

    // The three FxDesktop DS data_gallery sections.
    expect(find.text('FxListBox'), findsOneWidget);
    expect(find.text('FxGrid'), findsOneWidget);
    expect(find.text('Lookup'), findsOneWidget);

    // Their core widgets are present.
    expect(find.byType(FxListBox), findsOneWidget);
    expect(find.byType(FxGrid), findsOneWidget);
    expect(find.byType(FxComboBox), findsOneWidget);
    expect(find.text('Export TSV'), findsOneWidget);

    // The selection-mode toggle switches without error.
    await tester.tap(find.text('Multi (⌘-click)'));
    await tester.pumpAndSettle();
  });
}
