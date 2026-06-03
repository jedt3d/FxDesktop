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

  group('FxTextField', () {
    testWidgets(
      'renders helper text, validation error, and prefix/suffix icons',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxTextField(
                label: 'Password',
                hintText: 'Enter password',
                helpText: 'Use at least 12 characters.',
                errorText: 'Password is required.',
                prefixIcon: Icons.lock,
                suffixIcon: Icons.visibility,
                obscureText: true,
              ),
            ),
          ),
        );

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.obscureText, isTrue);
        expect(field.decoration?.helperText, 'Use at least 12 characters.');
        expect(field.decoration?.errorText, 'Password is required.');
        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );

    testWidgets('supports value, controller, and change callbacks', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Initial');
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTextField(
              label: 'Customer',
              controller: controller,
              onChanged: (value) => changedText = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Omega SA');
      expect(controller.text, 'Omega SA');
      expect(changedText, 'Omega SA');
    });

    testWidgets('reports committed text on submit', (tester) async {
      String? committedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTextField(
              label: 'Customer',
              value: 'Initial',
              onCommit: (value) => committedText = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Omega SA');
      expect(committedText, isNull);

      tester.widget<TextField>(find.byType(TextField)).onSubmitted?.call('');
      expect(committedText, 'Omega SA');
    });

    testWidgets('distinguishes disabled and read-only behavior', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FxTextField(label: 'Disabled', enabled: false),
                FxTextField(
                  label: 'Read only',
                  value: 'Locked',
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
      );

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.elementAt(0).enabled, isFalse);
      expect(fields.elementAt(1).enabled, isTrue);
      expect(fields.elementAt(1).readOnly, isTrue);
    });

    test('exports template metadata', () {
      expect(
        const FxTextField(
          label: 'Password',
          hintText: 'Enter password',
          helpText: 'Use at least 12 characters.',
          errorText: 'Password is required.',
          enabled: false,
          readOnly: true,
          obscureText: true,
          prefixIcon: Icons.lock,
          suffixIcon: Icons.visibility,
        ).toTemplateMap(),
        {
          'component': 'FxTextField',
          'xojo_desktop_class': 'DesktopTextField',
          'label': 'Password',
          'hintText': 'Enter password',
          'helpText': 'Use at least 12 characters.',
          'errorText': 'Password is required.',
          'enabled': false,
          'readOnly': true,
          'obscureText': true,
          'hasPrefixIcon': true,
          'hasSuffixIcon': true,
        },
      );
    });
  });

  group('FxTextArea', () {
    testWidgets('renders helper text, validation error, and line constraints', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxTextArea(
              label: 'Notes',
              hintText: 'Enter notes',
              helpText: 'Visible to the operations team.',
              errorText: 'Notes are required.',
              minLines: 4,
              maxLines: 5,
            ),
          ),
        ),
      );

      final area = tester.widget<TextField>(find.byType(TextField));
      expect(area.minLines, 4);
      expect(area.maxLines, 5);
      expect(area.decoration?.helperText, 'Visible to the operations team.');
      expect(area.decoration?.errorText, 'Notes are required.');
    });

    testWidgets('supports read-only and deterministic scroll controller', (
      tester,
    ) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTextArea(
              label: 'Audit',
              value: 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5',
              minLines: 2,
              maxLines: 2,
              readOnly: true,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      final area = tester.widget<TextField>(find.byType(TextField));
      expect(area.readOnly, isTrue);
      expect(area.scrollController, scrollController);
      scrollController.dispose();
    });

    testWidgets('supports text entry callbacks', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTextArea(
              label: 'Notes',
              onChanged: (value) => changedText = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Line item note');
      expect(changedText, 'Line item note');
    });

    testWidgets('reports committed multiline text on editing completion', (
      tester,
    ) async {
      String? committedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTextArea(
              label: 'Notes',
              value: 'Initial',
              onCommit: (value) => committedText = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2');
      expect(committedText, isNull);

      tester
          .widget<TextField>(find.byType(TextField))
          .onEditingComplete
          ?.call();
      expect(committedText, 'Line 1\nLine 2');
    });

    test('exports template metadata', () {
      final scrollController = ScrollController();
      expect(
        FxTextArea(
          label: 'Notes',
          hintText: 'Enter notes',
          helpText: 'Visible to operations.',
          errorText: 'Notes required.',
          enabled: false,
          readOnly: true,
          minLines: 4,
          maxLines: 8,
          scrollController: scrollController,
        ).toTemplateMap(),
        {
          'component': 'FxTextArea',
          'xojo_desktop_class': 'DesktopTextArea',
          'label': 'Notes',
          'hintText': 'Enter notes',
          'helpText': 'Visible to operations.',
          'errorText': 'Notes required.',
          'enabled': false,
          'readOnly': true,
          'minLines': 4,
          'maxLines': 8,
          'hasScrollController': true,
        },
      );
      scrollController.dispose();
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
        String? committedOption;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxComboBox(
                options: const ['Alpha', 'Beta', 'Alpine'],
                onOptionSelected: (value) => selectedOption = value,
                onCommit: (value) => committedOption = value,
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
        expect(committedOption, 'Alpine');
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
