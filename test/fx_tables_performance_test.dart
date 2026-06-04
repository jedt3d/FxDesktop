import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('Performance & Stress Tests - FxListBox', () {
    // 1. Deterministic data builders
    List<FxListBoxRow> buildMockListBoxRows(int count) {
      return List.generate(
        count,
        (i) => FxListBoxRow(
          id: 'r$i',
          cells: {
            'col1': 'Row $i Col 1',
            'col2': 'Row $i Col 2',
            'approved': i % 2 == 0,
          },
        ),
      );
    }

    testWidgets('Large-row performance smoke test (10,000 rows)', (
      tester,
    ) async {
      final rows = buildMockListBoxRows(10000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(
              columns: const [
                FxListBoxColumn(id: 'col1', caption: 'Column 1'),
                FxListBoxColumn(id: 'col2', caption: 'Column 2'),
                FxListBoxColumn(
                  id: 'approved',
                  caption: 'Approved',
                  type: FxCellType.boolean(),
                ),
              ],
              rows: rows,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll down substantially via drag gestures
      await tester.drag(find.byType(FxListBox), const Offset(0, -3000));
      await tester.pump();

      await tester.drag(find.byType(FxListBox), const Offset(0, -5000));
      await tester.pump();

      // Scroll back up
      await tester.drag(find.byType(FxListBox), const Offset(0, 8000));
      await tester.pumpAndSettle();

      expect(find.text('Row 0 Col 1'), findsOneWidget);
    });

    testWidgets('Wide-column performance smoke test (100 columns)', (
      tester,
    ) async {
      final columns = List.generate(
        100,
        (i) => FxListBoxColumn(id: 'col$i', caption: 'Col $i'),
      );
      final rows = List.generate(
        10,
        (i) => FxListBoxRow(
          id: 'r$i',
          cells: {for (int j = 0; j < 100; j++) 'col$j': 'R$i C$j'},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxListBox(columns: columns, rows: rows),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('R0 C0'), findsOneWidget);
    });
  });

  group('Performance & Stress Tests - FxGrid', () {
    List<FxGridRow> buildMockGridRows(int count, List<String> colIds) {
      return List.generate(
        count,
        (i) => FxGridRow(
          id: 'r$i',
          cells: {
            for (final c in colIds)
              c: c == 'approved' ? (i % 2 == 0) : 'R$i $c',
          },
        ),
      );
    }

    testWidgets('Large-row performance smoke test (10,000 rows)', (
      tester,
    ) async {
      final colIds = ['col1', 'col2', 'approved'];
      final rows = buildMockGridRows(10000, colIds);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(
              columns: const [
                FxGridColumn(id: 'col1', caption: 'Column 1'),
                FxGridColumn(id: 'col2', caption: 'Column 2'),
                FxGridColumn(
                  id: 'approved',
                  caption: 'Approved',
                  type: FxCellType.boolean(),
                ),
              ],
              rows: rows,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('R0 col1'), findsOneWidget);
    });

    testWidgets('Wide-column performance smoke test (100 columns)', (
      tester,
    ) async {
      final colIds = List.generate(100, (i) => 'col$i');
      final columns = colIds
          .map((id) => FxGridColumn(id: id, caption: 'Col $id'))
          .toList();
      final rows = buildMockGridRows(10, colIds);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxGrid(columns: columns, rows: rows),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('R0 col0'), findsOneWidget);
    });

    testWidgets(
      'Keyboard navigation stress test (100 sequential ArrowRight events)',
      (tester) async {
        final colIds = List.generate(110, (i) => 'col$i');
        final columns = colIds
            .map((id) => FxGridColumn(id: id, caption: 'Col $id'))
            .toList();
        final rows = buildMockGridRows(2, colIds);
        final focusNode = FocusNode();
        Set<({String rowId, String columnId})> selected = const {
          (rowId: 'r0', columnId: 'col0'),
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return FxGrid(
                    focusNode: focusNode,
                    selectionMode: FxGridSelectionMode.range,
                    selectedCells: selected,
                    columns: columns,
                    rows: rows,
                    onCellsSelected: (cells) =>
                        setState(() => selected = cells),
                  );
                },
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        // Press ArrowRight rapidly 100 times to traverse across columns
        for (int i = 0; i < 100; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump(const Duration(milliseconds: 10));
        }
        await tester.pumpAndSettle();

        // Verify no stack overflow or latency issues occurred and selection progressed
        expect(selected.last.columnId, 'col100');
      },
    );
  });
}
