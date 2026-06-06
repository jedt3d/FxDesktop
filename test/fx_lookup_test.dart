import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

enum TestStatus {
  active,
  inactive,
  pending,
}

void main() {
  group('Milestone 1: Lookup Providers & Cell Types', () {
    test('FxMapLookupProvider works correctly', () async {
      const map = {
        1: 'Electronics',
        2: 'Apparel',
        3: 'Books',
      };
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
      expect(provider.getDisplayValue(TestStatus.active), equals('Active Status'));
      expect(provider.getDisplayValue(TestStatus.inactive), equals('Inactive Status'));
      expect(provider.getDisplayValue(TestStatus.pending), equals('pending')); // Fallback

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
      const map = {
        '1': 'Electronics',
        '2': 'Apparel',
      };
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
    testWidgets('custom cellRenderer is called and rendered in FxListBox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(
                  id: 'category',
                  caption: 'Category',
                  cellRenderer: (context, rowId, columnId, value, isSelected, isHovered) {
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

    testWidgets('lookup column displays resolved value in FxListBox', (tester) async {
      const map = {
        1: 'Electronics',
        2: 'Apparel',
      };
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
    testWidgets('double tap lookup cell opens FxLookupComboBox and commits key on selection', (tester) async {
      const map = {
        1: 'Electronics',
        2: 'Apparel',
      };
      
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
                  type: const FxCellType.lookup(FxMapLookupProvider<int>(map)),
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
    });

    testWidgets('scrolling listbox dismisses overlay dropdown', (tester) async {
      const map = {
        1: 'Electronics',
        2: 'Apparel',
      };

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
                    type: const FxCellType.lookup(FxMapLookupProvider<int>(map)),
                  ),
                ],
                rows: List.generate(
                  15,
                  (index) => FxListBoxRow(id: 'r$index', cells: {'category': 1}),
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
    testWidgets('undo/redo lookup changes updates both raw value and display label', (tester) async {
      const map = {
        1: 'Electronics',
        2: 'Apparel',
      };

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
                        type: const FxCellType.lookup(FxMapLookupProvider<int>(map)),
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
    });
  });
}
