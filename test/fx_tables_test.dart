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
        width: 100,
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
        'width': 100.0,
        'minWidth': 50.0,
        'alignment': 'center',
        'editable': true,
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
        width: 120,
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
        'width': 120.0,
        'alignment': 'trailing',
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
}
