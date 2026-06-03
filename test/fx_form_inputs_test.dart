import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxLabel', () {
    testWidgets('maps text, wrapping, alignment, style, and disabled state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              FxLabel(
                text: 'Wrapped label',
                alignment: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FxLabel(text: 'Disabled label', enabled: false, softWrap: false),
            ],
          ),
        ),
      );

      final wrapped = tester.widget<Text>(find.text('Wrapped label'));
      expect(wrapped.softWrap, isTrue);
      expect(wrapped.textAlign, TextAlign.center);
      expect(wrapped.style?.fontWeight, FontWeight.bold);

      final disabled = tester.widget<Text>(find.text('Disabled label'));
      expect(disabled.softWrap, isFalse);
      expect(
        find.ancestor(
          of: find.text('Disabled label'),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });
  });

  group('FxPopupMenu', () {
    testWidgets('renders a fixed-choice selected value and changes selection', (
      tester,
    ) async {
      String? selected = 'Alpha';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxPopupMenu(
              label: 'Status',
              options: const ['Alpha', 'Beta'],
              selectedValue: selected,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('Alpha'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();

      expect(selected, 'Beta');
    });

    testWidgets('shows an empty option state as disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxPopupMenu(options: [], emptyText: 'No statuses'),
          ),
        ),
      );

      final button = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      expect(button.onChanged, isNull);
      expect(find.text('No statuses'), findsOneWidget);
    });
  });

  group('FxComboBox', () {
    testWidgets('keeps editable text distinct from fixed-choice selection', (
      tester,
    ) async {
      final controller = TextEditingController();
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxComboBox(
              label: 'City',
              controller: controller,
              options: const ['Bangkok', 'Boston'],
              onChanged: (value) => changedText = value,
            ),
          ),
        ),
      );

      expect(find.byType(EditableText), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Custom city');
      expect(controller.text, 'Custom city');
      expect(changedText, 'Custom city');
    });

    testWidgets(
      'offers autocomplete suggestions and reports option selection',
      (tester) async {
        String? selectedOption;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxComboBox(
                options: const ['Alpha', 'Beta', 'Alpine'],
                onOptionSelected: (value) => selectedOption = value,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'alp');
        await tester.pumpAndSettle();

        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Alpine'), findsOneWidget);
        expect(find.text('Beta'), findsNothing);

        await tester.tap(find.text('Alpine'));
        await tester.pumpAndSettle();

        expect(selectedOption, 'Alpine');
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          'Alpine',
        );
      },
    );

    testWidgets('disables editing and suggestions when disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxComboBox(
              enabled: false,
              options: ['Alpha'],
              value: 'Initial',
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsNothing);
    });
  });
}
