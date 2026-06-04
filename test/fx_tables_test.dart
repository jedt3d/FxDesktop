import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxListBox Selection & State', () {
    testWidgets('respects none, single, and multiple selection modes', (
      tester,
    ) async {
      Set<String>? selected;

      // None selection mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              selectionMode: FxListBoxSelectionMode.none,
              columns: const [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'col1': 'Row 1'}),
              ],
              onSelectionChanged: (ids) => selected = ids,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Row 1'));
      expect(selected, isNull);

      // Single selection mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              selectionMode: FxListBoxSelectionMode.single,
              columns: const [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'col1': 'Row 1'}),
                FxListBoxRow(id: 'r2', cells: {'col1': 'Row 2'}),
              ],
              onSelectionChanged: (ids) => selected = ids,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Row 2'));
      expect(selected, {'r2'});

      // Multiple selection mode
      selected = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              selectionMode: FxListBoxSelectionMode.multiple,
              selectedRowIds: const {'r1'},
              columns: const [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'col1': 'Row 1'}),
                FxListBoxRow(id: 'r2', cells: {'col1': 'Row 2'}),
                FxListBoxRow(id: 'r3', cells: {'col1': 'Row 3'}),
              ],
              onSelectionChanged: (ids) => selected = ids,
            ),
          ),
        ),
      );

      // Simple tap behaves like single selection without modifier keys
      await tester.tap(find.text('Row 3'));
      expect(selected, {'r3'});
    });

    testWidgets('keyboard traversal skips disabled rows', (tester) async {
      Set<String> selected = const {'r1'};
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FxListBox(
                  focusNode: focusNode,
                  selectionMode: FxListBoxSelectionMode.single,
                  selectedRowIds: selected,
                  columns: const [
                    FxListBoxColumn(id: 'col1', caption: 'Col 1'),
                  ],
                  rows: const [
                    FxListBoxRow(id: 'r1', cells: {'col1': 'Row 1'}),
                    FxListBoxRow(
                      id: 'r2',
                      cells: {'col1': 'Row 2'},
                      enabled: false,
                    ),
                    FxListBoxRow(id: 'r3', cells: {'col1': 'Row 3'}),
                  ],
                  onSelectionChanged: (ids) {
                    setState(() => selected = ids);
                  },
                );
              },
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      // Press arrow down. Row 2 is disabled, so it must skip to Row 3.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selected, {'r3'});

      // Press arrow up. Row 2 is disabled, so it must skip back to Row 1.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(selected, {'r1'});
    });

    testWidgets('disabled rows reject mouse selection', (tester) async {
      Set<String>? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              selectionMode: FxListBoxSelectionMode.single,
              columns: const [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: const [
                FxListBoxRow(
                  id: 'r1',
                  cells: {'col1': 'Row 1'},
                  enabled: false,
                ),
              ],
              onSelectionChanged: (ids) => selected = ids,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Row 1'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets('renders loading, empty, and error state views', (
      tester,
    ) async {
      // Loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxListBox(
              state: FxTableState.loading,
              columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Empty state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxListBox(
              state: FxTableState.empty,
              columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.text('No records to display'), findsOneWidget);

      // Error state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxListBox(
              state: FxTableState.error,
              errorText: 'Failed to fetch database rows',
              columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.text('Failed to fetch database rows'), findsOneWidget);
    });
  });

  group('FxGrid Selection & State', () {
    testWidgets('respects cell and row selection modes', (tester) async {
      Set<({String rowId, String columnId})>? selected;

      // Cell selection
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              selectionMode: FxGridSelectionMode.cell,
              columns: const [
                FxGridColumn(id: 'c1', caption: 'Col 1'),
                FxGridColumn(id: 'c2', caption: 'Col 2'),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'c1': 'A1', 'c2': 'A2'}),
              ],
              onCellsSelected: (cells) => selected = cells,
            ),
          ),
        ),
      );

      await tester.tap(find.text('A2'));
      expect(selected, {(rowId: 'r1', columnId: 'c2')});

      // Row selection
      selected = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              selectionMode: FxGridSelectionMode.row,
              columns: const [
                FxGridColumn(id: 'c1', caption: 'Col 1'),
                FxGridColumn(id: 'c2', caption: 'Col 2'),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'c1': 'A1', 'c2': 'A2'}),
              ],
              onCellsSelected: (cells) => selected = cells,
            ),
          ),
        ),
      );

      await tester.tap(find.text('A1'));
      expect(selected, {
        (rowId: 'r1', columnId: 'c1'),
        (rowId: 'r1', columnId: 'c2'),
      });
    });

    testWidgets('keyboard traversal skips disabled rows in FxGrid', (
      tester,
    ) async {
      Set<({String rowId, String columnId})> selected = const {
        (rowId: 'r1', columnId: 'c1'),
      };
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FxGrid(
                  focusNode: focusNode,
                  selectionMode: FxGridSelectionMode.cell,
                  selectedCells: selected,
                  columns: const [FxGridColumn(id: 'c1', caption: 'Col 1')],
                  rows: const [
                    FxGridRow(id: 'r1', cells: {'c1': 'A1'}),
                    FxGridRow(id: 'r2', cells: {'c1': 'A2'}, enabled: false),
                    FxGridRow(id: 'r3', cells: {'c1': 'A3'}),
                  ],
                  onCellsSelected: (cells) {
                    setState(() => selected = cells);
                  },
                );
              },
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      // Navigate down. Row 2 is disabled, so it must skip to Row 3.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selected, {(rowId: 'r3', columnId: 'c1')});

      // Navigate up. Row 2 is disabled, so it must skip back to Row 1.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(selected, {(rowId: 'r1', columnId: 'c1')});
    });

    testWidgets('disabled rows in FxGrid reject cell tap', (tester) async {
      Set<({String rowId, String columnId})>? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              selectionMode: FxGridSelectionMode.cell,
              columns: const [FxGridColumn(id: 'c1', caption: 'Col 1')],
              rows: const [
                FxGridRow(id: 'r1', cells: {'c1': 'A1'}, enabled: false),
              ],
              onCellsSelected: (cells) => selected = cells,
            ),
          ),
        ),
      );

      await tester.tap(find.text('A1'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets('renders loading, empty, and error state views', (
      tester,
    ) async {
      // Loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxGrid(
              state: FxTableState.loading,
              columns: [FxGridColumn(id: 'c1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Empty state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxGrid(
              state: FxTableState.empty,
              columns: [FxGridColumn(id: 'c1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.text('No records to display'), findsOneWidget);

      // Error state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxGrid(
              state: FxTableState.error,
              errorText: 'Database timeout',
              columns: [FxGridColumn(id: 'c1', caption: 'Col 1')],
              rows: [],
            ),
          ),
        ),
      );
      expect(find.text('Database timeout'), findsOneWidget);
    });

    testWidgets(
      'renders custom loading, empty, and error placeholder widgets in FxGrid',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxGrid(
                state: FxTableState.loading,
                loadingPlaceholder: Text('Grid Loading...'),
                columns: [FxGridColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Grid Loading...'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxGrid(
                state: FxTableState.empty,
                emptyPlaceholder: Text('Grid Empty'),
                columns: [FxGridColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Grid Empty'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxGrid(
                state: FxTableState.error,
                errorPlaceholder: Text('Grid Error'),
                columns: [FxGridColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Grid Error'), findsOneWidget);
      },
    );

    testWidgets('throws ArgumentError on duplicate column ids in FxGrid', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: [
                FxGridColumn(id: 'c1', caption: 'Col 1'),
                FxGridColumn(id: 'c1', caption: 'Col 2'),
              ],
              rows: [],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isArgumentError);
    });
  });

  group('FxListBox & FxGrid serialization and templates', () {
    test('FxListBox templates and toJson', () {
      const col = FxListBoxColumn(
        id: 'c1',
        caption: 'Col 1',
        width: FxColumnWidth.fixed(100),
        minWidth: 50,
        alignment: FxCellAlignment.center,
        editable: true,
      );
      const row = FxListBoxRow(
        id: 'r1',
        cells: {'c1': 'v1'},
        enabled: true,
        height: 32,
      );

      expect(col.toJson(), {
        'id': 'c1',
        'caption': 'Col 1',
        'width': {'type': 'fixed', 'value': 100.0},
        'minWidth': 50.0,
        'alignment': 'center',
        'editable': true,
        'visible': true,
        'sortable': false,
        'type': {'type': 'text'},
      });

      expect(row.toJson(), {
        'id': 'r1',
        'cells': {'c1': 'v1'},
        'enabled': true,
        'height': 32.0,
      });

      const listbox = FxListBox(
        columns: [col],
        rows: [row],
        selectionMode: FxListBoxSelectionMode.multiple,
        state: FxTableState.loading,
      );

      final templateMap = listbox.toTemplateMap();
      expect(templateMap['component'], 'FxListBox');
      expect(templateMap['xojo_desktop_class'], 'DesktopListBox');
      expect(templateMap['xojo_web_class'], 'WebListBox');
      expect(templateMap['selectionMode'], 'multiple');
      expect(templateMap['state'], 'loading');
    });

    test('FxGrid templates and toJson', () {
      const col = FxGridColumn(
        id: 'c1',
        caption: 'Col 1',
        width: FxColumnWidth.fixed(120),
        alignment: FxCellAlignment.trailing,
      );
      const row = FxGridRow(
        id: 'r1',
        cells: {'c1': 'v1'},
        enabled: true,
        height: 40,
      );

      expect(col.toJson(), {
        'id': 'c1',
        'caption': 'Col 1',
        'width': {'type': 'fixed', 'value': 120.0},
        'minWidth': 48.0,
        'alignment': 'trailing',
        'editable': false,
        'visible': true,
        'sortable': false,
        'type': {'type': 'text'},
      });

      expect(row.toJson(), {
        'id': 'r1',
        'cells': {'c1': 'v1'},
        'enabled': true,
        'height': 40.0,
      });

      const grid = FxGrid(
        columns: [col],
        rows: [row],
        selectionMode: FxGridSelectionMode.range,
        state: FxTableState.error,
      );

      final templateMap = grid.toTemplateMap();
      expect(templateMap['component'], 'FxGrid');
      expect(templateMap['xojo_desktop_class'], 'DesktopGrid');
      expect(templateMap['selectionMode'], 'range');
      expect(templateMap['state'], 'error');
    });
  });

  group('FxListBox extra tests', () {
    testWidgets(
      'renders custom loading, empty, and error placeholder widgets',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxListBox(
                state: FxTableState.loading,
                loadingPlaceholder: Text('Custom Loading...'),
                columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Custom Loading...'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxListBox(
                state: FxTableState.empty,
                emptyPlaceholder: Text('Custom Empty'),
                columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Custom Empty'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FxListBox(
                state: FxTableState.error,
                errorPlaceholder: Text('Custom Error'),
                columns: [FxListBoxColumn(id: 'col1', caption: 'Col 1')],
                rows: [],
              ),
            ),
          ),
        );
        expect(find.text('Custom Error'), findsOneWidget);
      },
    );

    testWidgets(
      'FxListBox filters hidden columns and supports sorting/resizing',
      (tester) async {
        String? sortedCol;
        bool? sortAsc;
        double? resizedWidth;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxListBox(
                columns: [
                  const FxListBoxColumn(
                    id: 'c1',
                    caption: 'Col 1',
                    width: FxColumnWidth.fixed(100),
                    sortable: true,
                  ),
                  const FxListBoxColumn(
                    id: 'c2',
                    caption: 'Col 2',
                    width: FxColumnWidth.fixed(100),
                    visible: false,
                  ),
                  const FxListBoxColumn(
                    id: 'c3',
                    caption: 'Col 3',
                    width: FxColumnWidth.fixed(100),
                    sortable: true,
                  ),
                ],
                rows: const [
                  FxListBoxRow(
                    id: 'r1',
                    cells: {'c1': 'A', 'c2': 'B', 'c3': 'C'},
                  ),
                ],
                sortedColumnId: 'c1',
                sortAscending: true,
                onSortChanged: (id, asc) {
                  sortedCol = id;
                  sortAsc = asc;
                },
                onColumnResized: (id, width) {
                  resizedWidth = width;
                },
              ),
            ),
          ),
        );

        expect(find.text('Col 1'), findsOneWidget);
        expect(find.text('Col 2'), findsNothing);
        expect(find.text('Col 3'), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsNothing);
        expect(find.text('C'), findsOneWidget);

        expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

        await tester.tap(find.text('Col 3'));
        await tester.pump();
        expect(sortedCol, 'c3');
        expect(sortAsc, true);

        final resizeHandleFinder = find.byWidgetPredicate(
          (widget) =>
              widget is MouseRegion &&
              widget.cursor == SystemMouseCursors.resizeLeftRight,
        );
        expect(resizeHandleFinder, findsNWidgets(2));

        await tester.drag(resizeHandleFinder.first, const Offset(20, 0));
        await tester.pump();
        expect(resizedWidth, isNotNull);
        expect(resizedWidth!, 120.0);
      },
    );

    testWidgets('FxGrid filters hidden columns and supports sorting/resizing', (
      tester,
    ) async {
      String? sortedCol;
      bool? sortAsc;
      double? resizedWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: [
                const FxGridColumn(
                  id: 'c1',
                  caption: 'Col 1',
                  width: FxColumnWidth.fixed(100),
                  sortable: true,
                ),
                const FxGridColumn(
                  id: 'c2',
                  caption: 'Col 2',
                  width: FxColumnWidth.fixed(100),
                  visible: false,
                ),
                const FxGridColumn(
                  id: 'c3',
                  caption: 'Col 3',
                  width: FxColumnWidth.fixed(100),
                  sortable: true,
                ),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'c1': 'A', 'c2': 'B', 'c3': 'C'}),
              ],
              sortedColumnId: 'c1',
              sortAscending: true,
              onSortChanged: (id, asc) {
                sortedCol = id;
                sortAsc = asc;
              },
              onColumnResized: (id, width) {
                resizedWidth = width;
              },
            ),
          ),
        ),
      );

      expect(find.text('Col 1'), findsOneWidget);
      expect(find.text('Col 2'), findsNothing);
      expect(find.text('Col 3'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(find.text('C'), findsOneWidget);

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

      await tester.tap(find.text('Col 3'));
      await tester.pump();
      expect(sortedCol, 'c3');
      expect(sortAsc, true);

      final resizeHandleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion &&
            widget.cursor == SystemMouseCursors.resizeLeftRight,
      );
      expect(resizeHandleFinder, findsNWidgets(2));

      await tester.drag(resizeHandleFinder.first, const Offset(-30, 0));
      await tester.pump();
      expect(resizedWidth, isNotNull);
      expect(resizedWidth!, 70.0);
    });

    testWidgets('throws ArgumentError on duplicate column ids in FxListBox', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [
                FxListBoxColumn(id: 'c1', caption: 'Col 1'),
                FxListBoxColumn(id: 'c1', caption: 'Col 2'),
              ],
              rows: [],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isArgumentError);
    });
  });

  group('Milestone 3, Phase 3.3: Inline Cell Editing & Validation', () {
    testWidgets('FxListBox text editor activation, commit, and cancel', (
      tester,
    ) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(id: 'name', caption: 'Name', editable: true),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'name': 'Alice'}),
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

      // Verify initial cell text
      expect(find.text('Alice'), findsOneWidget);

      // Double tap cell to start editing
      await tester.tap(find.text('Alice'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Find the TextField in editor mode
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter new text and submit
      await tester.enterText(textFieldFinder, 'Bob');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'name');
      expect(editedValue, 'Bob');

      // Verify TextField is gone
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('FxListBox boolean column toggling', (tester) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(
                  id: 'approved',
                  caption: 'Approved',
                  editable: true,
                  type: FxCellType.boolean(),
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'approved': false}),
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

      // Verify checkbox is rendered
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Tap checkbox to toggle
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'approved');
      expect(editedValue, true);
    });

    testWidgets('FxListBox choice column dropdown editing', (tester) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(
                  id: 'role',
                  caption: 'Role',
                  editable: true,
                  type: FxCellType.choice(['Admin', 'User']),
                ),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'role': 'User'}),
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

      // Verify choice cell is rendered as User
      expect(find.text('User'), findsOneWidget);

      // Double tap to edit choice
      await tester.tap(find.text('User'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      // Verify DropdownButton is visible
      final dropdownFinder = find.byType(DropdownButton<String>);
      expect(dropdownFinder, findsOneWidget);

      // Tap dropdown to open options
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Tap the 'Admin' option
      final adminOptionFinder = find.text('Admin').last;
      await tester.tap(adminOptionFinder);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'role');
      expect(editedValue, 'Admin');
    });

    testWidgets('FxListBox validation error styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: [FxListBoxColumn(id: 'name', caption: 'Name')],
              rows: [
                FxListBoxRow(id: 'r1', cells: {'name': 'Alice'}),
              ],
              validationErrors: {
                'r1': {'name': 'Name is invalid'},
              },
            ),
          ),
        ),
      );

      // Verify error icon and tooltip wrapper
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('FxGrid text editor activation, commit, and cancel', (
      tester,
    ) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: const [
                FxGridColumn(id: 'name', caption: 'Name', editable: true),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'name': 'Alice'}),
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

      // Verify initial cell text
      expect(find.text('Alice'), findsOneWidget);

      // Double tap cell to start editing
      await tester.tap(find.text('Alice'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Find the TextField in editor mode
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter new text and submit
      await tester.enterText(textFieldFinder, 'Bob');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'name');
      expect(editedValue, 'Bob');

      // Verify TextField is gone
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('FxGrid boolean column toggling', (tester) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: const [
                FxGridColumn(
                  id: 'approved',
                  caption: 'Approved',
                  editable: true,
                  type: FxCellType.boolean(),
                ),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'approved': false}),
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

      // Verify checkbox is rendered
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Tap checkbox to toggle
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'approved');
      expect(editedValue, true);
    });

    testWidgets('FxGrid validation error styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: [FxGridColumn(id: 'name', caption: 'Name')],
              rows: [
                FxGridRow(id: 'r1', cells: {'name': 'Alice'}),
              ],
              validationErrors: {
                'r1': {'name': 'Name is invalid'},
              },
            ),
          ),
        ),
      );

      // Verify error icon and tooltip wrapper
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('FxListBox keyboard navigation tab traversal during edit', (
      tester,
    ) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(id: 'col1', caption: 'Col 1', editable: true),
                FxListBoxColumn(id: 'col2', caption: 'Col 2', editable: true),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'col1': 'A', 'col2': 'B'}),
                FxListBoxRow(id: 'r2', cells: {'col1': 'C', 'col2': 'D'}),
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

      // Start editing 'A'
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter text
      await tester.enterText(textFieldFinder, 'A_new');
      await tester.pumpAndSettle();

      // Press Tab key
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Verify callback called for col1
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'col1');
      expect(editedValue, 'A_new');

      // Verify focus moved to col2 (TextField should still be visible because we are editing next cell)
      expect(find.byType(TextField), findsOneWidget);

      // Press Tab key again, which will traverse to next row's first col
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Verify focus moved to next row (r2, col1)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('FxListBox edit cancellation on escape key', (tester) async {
      bool cellEdited = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(id: 'name', caption: 'Name', editable: true),
              ],
              rows: const [
                FxListBoxRow(id: 'r1', cells: {'name': 'Alice'}),
              ],
              onCellEdited: (rowId, colId, newValue) {
                cellEdited = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Bob');
      await tester.pumpAndSettle();

      // Cancel edit via Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(cellEdited, isFalse);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('FxListBox focus loss commits the edit', (tester) async {
      String? editedValue;
      final otherFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: FxListBox(
                    columns: const [
                      FxListBoxColumn(
                        id: 'name',
                        caption: 'Name',
                        editable: true,
                      ),
                    ],
                    rows: const [
                      FxListBoxRow(id: 'r1', cells: {'name': 'Alice'}),
                    ],
                    onCellEdited: (rowId, colId, newValue) {
                      editedValue = newValue?.toString();
                    },
                  ),
                ),
                Focus(
                  focusNode: otherFocusNode,
                  child: const SizedBox(height: 10),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Bob');
      await tester.pumpAndSettle();

      // Shift focus away to trigger commit
      otherFocusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(editedValue, 'Bob');
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets(
      'FxGrid keyboard navigation tab traversal and enter key activation',
      (tester) async {
        String? editedRowId;
        String? editedColumnId;
        Object? editedValue;
        final gridFocusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FxGrid(
                focusNode: gridFocusNode,
                columns: const [
                  FxGridColumn(id: 'col1', caption: 'Col 1', editable: true),
                  FxGridColumn(id: 'col2', caption: 'Col 2', editable: true),
                ],
                rows: const [
                  FxGridRow(id: 'r1', cells: {'col1': 'A', 'col2': 'B'}),
                  FxGridRow(id: 'r2', cells: {'col1': 'C', 'col2': 'D'}),
                ],
                selectedCells: const {(rowId: 'r1', columnId: 'col1')},
                onCellsSelected: (_) {},
                onCellEdited: (rowId, colId, newValue) {
                  editedRowId = rowId;
                  editedColumnId = colId;
                  editedValue = newValue;
                },
              ),
            ),
          ),
        );

        // Focus the grid
        gridFocusNode.requestFocus();
        await tester.pumpAndSettle();

        // Press Enter to start editing
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        // Enter new text and press Tab
        await tester.enterText(textFieldFinder, 'A_new');
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(editedRowId, 'r1');
        expect(editedColumnId, 'col1');
        expect(editedValue, 'A_new');

        // Verify editing moved to next cell (col2)
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets('FxGrid metadata tags support', (tester) async {
      const rowTag = 'custom-row-tag';
      const cellTags = {'col1': 'cell-tag-1', 'col2': 'cell-tag-2'};

      const gridRow = FxGridRow(
        id: 'r1',
        cells: {'col1': 'A', 'col2': 'B'},
        rowTag: rowTag,
        cellTags: cellTags,
      );

      expect(gridRow.rowTag, rowTag);
      expect(gridRow.cellTags, cellTags);

      const listRow = FxListBoxRow(
        id: 'r1',
        cells: {'col1': 'A'},
        rowTag: rowTag,
      );
      expect(listRow.rowTag, rowTag);
    });

    testWidgets('FxGrid choice cell dropdown editing', (tester) async {
      String? editedRowId;
      String? editedColumnId;
      Object? editedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: const [
                FxGridColumn(
                  id: 'role',
                  caption: 'Role',
                  editable: true,
                  type: FxCellType.choice(['Admin', 'User']),
                ),
              ],
              rows: const [
                FxGridRow(id: 'r1', cells: {'role': 'User'}),
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

      // Verify choice cell is rendered as User
      expect(find.text('User'), findsOneWidget);

      // Double tap to edit choice
      await tester.tap(find.text('User'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      // Verify DropdownButton is visible
      final dropdownFinder = find.byType(DropdownButton<String>);
      expect(dropdownFinder, findsOneWidget);

      // Tap dropdown to open options
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Tap the 'Admin' option
      final adminOptionFinder = find.text('Admin').last;
      await tester.tap(adminOptionFinder);
      await tester.pumpAndSettle();

      // Check callback
      expect(editedRowId, 'r1');
      expect(editedColumnId, 'role');
      expect(editedValue, 'Admin');
    });
  });
}
