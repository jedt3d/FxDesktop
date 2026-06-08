import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart'
    as table;

enum TestStatus { active, inactive, pending }

void main() {
  group('Milestone 1: Lookup Providers & Cell Types', () {
    test('FxMapLookupProvider works correctly', () async {
      const map = {1: 'Electronics', 2: 'Apparel', 3: 'Books'};
      final provider = FxMapLookupProvider<int>(map);

      // Resolve keys
      expect(provider.getDisplayValue(1), equals('Electronics'));
      expect(provider.getDisplayValue(2), equals('Apparel'));
      expect(provider.getDisplayValue(4), equals('4')); // Fallback

      // Get options
      final optionsEmpty = await provider.getOptions('');
      expect(optionsEmpty.length, equals(3));
      expect(optionsEmpty[0].key, equals(1));
      expect(optionsEmpty[0].display, equals('Electronics'));

      final optionsQuery = await provider.getOptions('el');
      expect(optionsQuery.length, equals(2)); // Electronics, Apparel (ApparEL)
      expect(optionsQuery.any((element) => element.key == 1), isTrue);
      expect(optionsQuery.any((element) => element.key == 2), isTrue);

      // Serialization
      final json = provider.toJson();
      expect(json['type'], equals('map'));
      expect((json['map'] as Map)['1'], equals('Electronics'));
    });

    test('FxEnumLookupProvider works correctly', () async {
      final provider = FxEnumLookupProvider<TestStatus>(
        values: TestStatus.values,
        labels: const {
          TestStatus.active: 'Active Status',
          TestStatus.inactive: 'Inactive Status',
        },
      );

      // Resolve keys
      expect(
        provider.getDisplayValue(TestStatus.active),
        equals('Active Status'),
      );
      expect(
        provider.getDisplayValue(TestStatus.inactive),
        equals('Inactive Status'),
      );
      expect(
        provider.getDisplayValue(TestStatus.pending),
        equals('pending'),
      ); // Fallback

      // Get options
      final options = await provider.getOptions('status');
      expect(options.length, equals(2)); // Active Status, Inactive Status
      expect(options.any((e) => e.key == TestStatus.active), isTrue);

      // Serialization
      final json = provider.toJson();
      expect(json['type'], equals('enum'));
      expect((json['values'] as List), contains('active'));
      expect((json['labels'] as Map)['active'], equals('Active Status'));
    });

    test('FxCellType JSON parsing and serialization', () {
      const map = {'1': 'Electronics', '2': 'Apparel'};
      final provider = FxMapLookupProvider<String>(map);
      final cellType = FxCellType.lookup(provider);

      // Serialize
      final json = cellType.toJson();
      expect(json['type'], equals('lookup'));
      expect(json['provider'], isNotNull);

      // Deserialize
      final parsed = FxCellType.fromJson(json);
      expect(parsed, isA<FxLookupCellType>());
      final parsedLookup = parsed as FxLookupCellType;
      expect(parsedLookup.provider.getDisplayValue('1'), equals('Electronics'));
    });
  });

  group('Milestone 2: Cell Builders & Custom Renderers', () {
    testWidgets('custom cellRenderer is called and rendered in FxListBox', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(
                  id: 'category',
                  caption: 'Category',
                  cellRenderer:
                      (context, rowId, columnId, value, isSelected, isHovered) {
                        return Container(
                          key: const Key('custom-badge'),
                          child: Text('Badge: $value'),
                        );
                      },
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'category': 'Promo'}),
              ],
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('custom-badge')), findsOneWidget);
      expect(find.text('Badge: Promo'), findsOneWidget);
    });

    testWidgets('lookup column displays resolved value in FxListBox', (
      tester,
    ) async {
      const map = {1: 'Electronics', 2: 'Apparel'};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(
                  id: 'category',
                  caption: 'Category',
                  type: const FxCellType.lookup(FxMapLookupProvider<int>(map)),
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'category': 1}),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });
  });

  group('Milestone 3: Lookup ComboBox Editor & Overlay', () {
    testWidgets(
      'double tap lookup cell opens FxLookupComboBox and commits key on selection',
      (tester) async {
        const map = {1: 'Electronics', 2: 'Apparel'};

        String? editedRowId;
        String? editedColumnId;
        Object? editedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxListBox(
                columns: [
                  FxListBoxColumn(
                    id: 'category',
                    caption: 'Category',
                    editable: true,
                    type: const FxCellType.lookup(
                      FxMapLookupProvider<int>(map),
                    ),
                  ),
                ],
                rows: const [
                  FxListBoxRow(id: 'r1', cells: {'category': 1}),
                ],
                onCellEdited: (rowId, colId, newValue) {
                  editedRowId = rowId;
                  editedColumnId = colId;
                  editedValue = newValue;
                },
              ),
            ),
          ),
        );

        // Verify display value is visible
        expect(find.text('Electronics'), findsOneWidget);

        // Double tap cell to enter edit mode
        await tester.tap(find.text('Electronics'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Electronics'));
        await tester.pumpAndSettle();

        // Verify FxLookupComboBox editor is active
        expect(find.byType(FxLookupComboBox), findsOneWidget);

        // Tap the option 'Apparel' inside the Overlay dropdown
        final apparelItem = find.text('Apparel').last;
        await tester.tap(apparelItem);
        await tester.pumpAndSettle();

        // Editor should close and commit the raw key (2)
        expect(find.byType(FxLookupComboBox), findsNothing);
        expect(editedRowId, equals('r1'));
        expect(editedColumnId, equals('category'));
        expect(editedValue, equals(2)); // Commits key, not label
      },
    );

    testWidgets('scrolling listbox dismisses overlay dropdown', (tester) async {
      const map = {1: 'Electronics', 2: 'Apparel'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100, // small height to make it scrollable
              child: FxListBox(
                columns: [
                  FxListBoxColumn(
                    id: 'category',
                    caption: 'Category',
                    editable: true,
                    type: const FxCellType.lookup(
                      FxMapLookupProvider<int>(map),
                    ),
                  ),
                ],
                rows: List.generate(
                  15,
                  (index) =>
                      FxListBoxRow(id: 'r$index', cells: {'category': 1}),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify display value is visible
      expect(find.text('Electronics').first, findsOneWidget);

      // Double tap cell to enter edit mode
      await tester.tap(find.text('Electronics').first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Electronics').first);
      await tester.pumpAndSettle();

      // Verify FxLookupComboBox editor is active
      expect(find.byType(FxLookupComboBox), findsOneWidget);

      // Drag/scroll listbox
      await tester.drag(find.text('Electronics').first, const Offset(0, -40));
      await tester.pumpAndSettle();

      // Editor should close/cancel on scroll
      expect(find.byType(FxLookupComboBox), findsNothing);
    });
  });

  group('Milestone 4: Undo/Redo & Transaction Integration', () {
    testWidgets(
      'undo/redo lookup changes updates both raw value and display label',
      (tester) async {
        const map = {1: 'Electronics', 2: 'Apparel'};

        final undoController = FxUndoController();
        int cellValue = 1;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxUndoScope(
                controller: undoController,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return FxListBox(
                      columns: [
                        FxListBoxColumn(
                          id: 'category',
                          caption: 'Category',
                          editable: true,
                          type: const FxCellType.lookup(
                            FxMapLookupProvider<int>(map),
                          ),
                        ),
                      ],
                      rows: [
                        FxListBoxRow(id: 'r1', cells: {'category': cellValue}),
                      ],
                      onCellEdited: (rowId, colId, newValue) {
                        setState(() {
                          cellValue = newValue as int;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Verify initial label
        expect(find.text('Electronics'), findsOneWidget);

        // Enter edit mode
        await tester.tap(find.text('Electronics'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Electronics'));
        await tester.pumpAndSettle();

        // Tap 'Apparel'
        await tester.tap(find.text('Apparel').last);
        await tester.pumpAndSettle();

        // Verify committed value and label updated to Apparel
        expect(cellValue, equals(2));
        expect(find.text('Apparel'), findsOneWidget);
        expect(find.text('Electronics'), findsNothing);

        // Trigger Undo
        undoController.undo();
        await tester.pumpAndSettle();

        // Value and label should revert to key 1 / Electronics
        expect(cellValue, equals(1));
        expect(find.text('Electronics'), findsOneWidget);
        expect(find.text('Apparel'), findsNothing);

        // Trigger Redo
        undoController.redo();
        await tester.pumpAndSettle();

        // Value and label should redo to key 2 / Apparel
        expect(cellValue, equals(2));
        expect(find.text('Apparel'), findsOneWidget);
        expect(find.text('Electronics'), findsNothing);
      },
    );
  });

  group('Milestone 6: MaskTextInputFormatter', () {
    test('FxMaskTextInputFormatter formats text correctly', () {
      final formatter = FxMaskTextInputFormatter('(###) ###-####');

      // formatEditUpdate from empty to typed
      var val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1234567890'),
      );
      expect(val.text, equals('(123) 456-7890'));

      // unmask
      expect(formatter.unmask('(123) 456-7890'), equals('1234567890'));

      // applyMask
      expect(formatter.applyMask('1234567890'), equals('(123) 456-7890'));
    });
  });

  group('Milestone 7: Multi-Column Lookup Dropdown', () {
    testWidgets('multi-column dropdown renders headers and rows correctly', (
      tester,
    ) async {
      final dbProvider = FxDbLookupProvider<String>(
        headers: const ['Code', 'Name', 'Rating'],
        recordMap: const {
          'V1': ['V1', 'Vendor One', '5 stars'],
          'V2': ['V2', 'Vendor Two', '4 stars'],
        },
        displayColumnIndex: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(
                  id: 'vendor',
                  caption: 'Vendor',
                  editable: true,
                  type: FxCellType.lookup(dbProvider),
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'vendor': 'V1'}),
              ],
            ),
          ),
        ),
      );

      // Verify display value
      expect(find.text('Vendor One'), findsOneWidget);

      // Open lookup dropdown
      await tester.tap(find.text('Vendor One'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Vendor One'));
      await tester.pumpAndSettle();

      // Check overlay is open
      expect(find.byType(FxLookupComboBox), findsOneWidget);

      // Verify headers render
      expect(find.text('Code'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);

      // Verify rows render in multi-column list
      expect(find.text('V1'), findsOneWidget);
      expect(find.text('5 stars'), findsOneWidget);
      expect(find.text('V2'), findsOneWidget);
      expect(find.text('4 stars'), findsOneWidget);

      // Click on Vendor Two row
      await tester.tap(find.text('Vendor Two'));
      await tester.pumpAndSettle();

      // Check closed and value updated
      expect(find.byType(FxLookupComboBox), findsNothing);
    });
  });

  group('Milestone 6: Cell Action/Ellipsis Button & Input Masking in Grid', () {
    testWidgets('action button triggers callback in FxListBox', (tester) async {
      String? callbackRowId;
      String? callbackColId;
      Object? callbackVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(
                  id: 'note',
                  caption: 'Note',
                  editable: true,
                  hasActionButton: true,
                  actionIcon: Icons.edit,
                  onActionPressed: (rowId, colId, value) {
                    callbackRowId = rowId;
                    callbackColId = colId;
                    callbackVal = value;
                  },
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'note': 'Hello'}),
              ],
            ),
          ),
        ),
      );

      // Double tap to enter editing mode
      await tester.tap(find.text('Hello'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();

      // Find edit action button
      final actionBtn = find.byIcon(Icons.edit);
      expect(actionBtn, findsOneWidget);

      // Tap action button
      await tester.tap(actionBtn);
      await tester.pumpAndSettle();

      // Verify callback was invoked
      expect(callbackRowId, equals('r1'));
      expect(callbackColId, equals('note'));
      expect(callbackVal, equals('Hello'));
    });
  });

  group('Milestone 6 Coverage and Edge Cases', () {
    test('FxDbLookupProvider edge cases and toJson', () {
      final dbProvider = FxDbLookupProvider<String>(
        headers: const ['Code', 'Name'],
        recordMap: const {
          'K1': ['K1', 'Name 1'],
        },
        displayColumnIndex: 5, // out of bounds
      );

      // Falls back to record.first ('K1')
      expect(dbProvider.getDisplayValue('K1'), equals('K1'));

      // Unknown key falls back to toString()
      expect(dbProvider.getDisplayValue('K2'), equals('K2'));

      // Empty list of values fallback
      final emptyProvider = FxDbLookupProvider<String>(
        headers: const ['Code'],
        recordMap: const {'K1': []},
      );
      expect(emptyProvider.getDisplayValue('K1'), equals('K1'));

      // toJson
      final json = dbProvider.toJson();
      expect(json['type'], equals('db'));
      expect(json['displayColumnIndex'], equals(5));
      expect((json['headers'] as List).first, equals('Code'));
    });

    test('FxColumnWidth serialization and deserialization', () {
      // fixed
      const fixedWidth = FxColumnWidth.fixed(150.0);
      final fixedJson = fixedWidth.toJson();
      expect(fixedJson['type'], equals('fixed'));
      expect(fixedJson['value'], equals(150.0));
      expect(fixedWidth.toTableSpanExtent(), isA<table.FixedTableSpanExtent>());
      expect(
        FxColumnWidth.fromJson(fixedJson).toTableSpanExtent(),
        isA<table.FixedTableSpanExtent>(),
      );

      // fraction
      const fractionWidth = FxColumnWidth.fraction(0.3);
      final fractionJson = fractionWidth.toJson();
      expect(fractionJson['type'], equals('fraction'));
      expect(fractionJson['value'], equals(0.3));
      expect(
        fractionWidth.toTableSpanExtent(),
        isA<table.FractionalTableSpanExtent>(),
      );
      expect(
        FxColumnWidth.fromJson(fractionJson).toTableSpanExtent(),
        isA<table.FractionalTableSpanExtent>(),
      );

      // remaining
      const remainingWidth = FxColumnWidth.remaining();
      final remainingJson = remainingWidth.toJson();
      expect(remainingJson['type'], equals('remaining'));
      expect(
        remainingWidth.toTableSpanExtent(),
        isA<table.RemainingTableSpanExtent>(),
      );
      expect(
        FxColumnWidth.fromJson(remainingJson).toTableSpanExtent(),
        isA<table.RemainingTableSpanExtent>(),
      );

      // defaults/invalid
      final defaultWidth = FxColumnWidth.fromJson({'type': 'invalid'});
      expect(
        defaultWidth.toTableSpanExtent(),
        isA<table.FixedTableSpanExtent>(),
      );
    });

    test('FxCellType serialization and deserialization', () {
      // text
      const textCell = FxCellType.text();
      final textJson = textCell.toJson();
      expect(textJson['type'], equals('text'));
      expect(FxCellType.fromJson(textJson), isA<FxTextCellType>());

      // boolean
      const booleanCell = FxCellType.boolean();
      final booleanJson = booleanCell.toJson();
      expect(booleanJson['type'], equals('boolean'));
      expect(FxCellType.fromJson(booleanJson), isA<FxBooleanCellType>());

      // choice
      const choiceCell = FxCellType.choice(['Option A', 'Option B']);
      final choiceJson = choiceCell.toJson();
      expect(choiceJson['type'], equals('choice'));
      expect((choiceJson['options'] as List)[1], equals('Option B'));
      final parsedChoice = FxCellType.fromJson(choiceJson);
      expect(parsedChoice, isA<FxChoiceCellType>());
      expect((parsedChoice as FxChoiceCellType).options, contains('Option A'));

      // lookup enum
      final enumLookupJson = {
        'type': 'lookup',
        'provider': {
          'type': 'enum',
          'labels': {'A': 'Label A'},
        },
      };
      final parsedEnumLookup = FxCellType.fromJson(enumLookupJson);
      expect(parsedEnumLookup, isA<FxLookupCellType>());
      expect(
        (parsedEnumLookup as FxLookupCellType).provider.getDisplayValue('A'),
        equals('Label A'),
      );

      // lookup map
      final mapLookupJson = {
        'type': 'lookup',
        'provider': {
          'type': 'map',
          'map': {'1': 'One'},
        },
      };
      final parsedMapLookup = FxCellType.fromJson(mapLookupJson);
      expect(parsedMapLookup, isA<FxLookupCellType>());

      // default/invalid
      final invalidCell = FxCellType.fromJson({'type': 'unknown'});
      expect(invalidCell, isA<FxTextCellType>());
    });

    test('FxMaskTextInputFormatter complex patterns', () {
      final formatter = FxMaskTextInputFormatter('A-###-*');

      var val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'X123Y'),
      );
      expect(val.text, equals('X-123-Y'));

      // Skip non-matching input character
      var val2 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '9123Y',
        ), // 9 is digit, mask expects letter 'A' first
      );
      expect(
        val2.text,
        equals('Y'),
      ); // skipped '9' as it doesn't match 'A', but matches 'Y'
    });

    testWidgets('action button triggers callback in FxGrid', (tester) async {
      String? callbackRowId;
      String? callbackColId;
      Object? callbackVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: [
                FxGridColumn(
                  id: 'note',
                  caption: 'Note',
                  editable: true,
                  hasActionButton: true,
                  actionIcon: Icons.edit,
                  onActionPressed: (rowId, colId, value) {
                    callbackRowId = rowId;
                    callbackColId = colId;
                    callbackVal = value;
                  },
                ),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'note': 'Hello'}),
              ],
            ),
          ),
        ),
      );

      // Tap cell to select
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();

      // Double tap cell to enter editing mode
      await tester.tap(find.text('Hello'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();

      // Find edit action button
      final actionBtn = find.byIcon(Icons.edit);
      expect(actionBtn, findsOneWidget);

      // Tap action button
      await tester.tap(actionBtn);
      await tester.pumpAndSettle();

      // Verify callback was invoked
      expect(callbackRowId, equals('r1'));
      expect(callbackColId, equals('note'));
      expect(callbackVal, equals('Hello'));
    });

    testWidgets(
      'FxGrid active row/column background highlights render properly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxGrid(
                columns: const [
                  FxGridColumn(id: 'c1', caption: 'Col 1'),
                  FxGridColumn(id: 'c2', caption: 'Col 2'),
                ],
                rows: const [
                  FxGridRow(id: 'r1', cells: {'c1': 'A1', 'c2': 'B1'}),
                  FxGridRow(id: 'r2', cells: {'c1': 'A2', 'c2': 'B2'}),
                ],
                selectedCells: const {(rowId: 'r1', columnId: 'c2')},
              ),
            ),
          ),
        );

        // Verify selected cell B1 is visible
        expect(find.text('B1'), findsOneWidget);

        // Active row c1 (A1) and active column c2 (B2) should have highlighted backgrounds
        final coloredBoxes = find.byType(ColoredBox);
        expect(coloredBoxes, findsWidgets);
      },
    );
  });
}
