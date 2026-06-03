import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxLayoutSpec', () {
    test('serializes flex layouts deterministically', () {
      const spec = FxLayoutSpec.flex(
        id: 'root',
        direction: FxFlexDirection.row,
        justify: FxJustifyContent.spaceBetween,
        align: FxAlignItems.center,
        gap: 8,
        padding: 12,
        flexChildren: [
          FxFlexItemSpec(id: 'sidebar', basis: 240),
          FxFlexItemSpec(id: 'content', grow: 1),
        ],
      );

      final encoded = jsonEncode(spec.toJson());
      final decoded = FxLayoutSpec.fromJson(
        jsonDecode(encoded) as Map<String, Object?>,
      );

      expect(decoded.toJson(), spec.toJson());
      expect(
        FxFlexLayoutManager(
          spec: decoded,
        ).toTemplateMap()['xojo_manager_class'],
        'DesktopFlexLayoutManager',
      );
      expect(
        FxFlexLayoutManager(
          spec: decoded,
        ).toTemplateMap(target: FxXojoTarget.web)['xojo_manager_class'],
        'WebFlexLayoutManager',
      );
    });

    test('serializes grid layouts deterministically', () {
      const spec = FxLayoutSpec.grid(
        id: 'screen',
        columns: [FxTrackSize.fixed(180), FxTrackSize.flex(1)],
        rows: [FxTrackSize.auto(), FxTrackSize.flex(1)],
        areas: '''
header header
nav    content
''',
        gap: 10,
        gridChildren: [
          FxGridPlacementSpec(id: 'header', area: 'header'),
          FxGridPlacementSpec(id: 'content', rowStart: 1, columnStart: 1),
        ],
      );

      final decoded = FxLayoutSpec.fromJson(spec.toJson());

      expect(decoded.toJson(), spec.toJson());
      expect(
        FxGridLayoutManager(spec: decoded).toTemplateMap()['kind'],
        'grid',
      );
    });
  });

  group('component registry', () {
    test('maps core components to Xojo classes', () {
      final byName = {
        for (final descriptor in fxComponentRegistry)
          descriptor.name: descriptor,
      };

      expect(
        byName['FxFlexLayout']?.xojoDesktopClass,
        'DesktopFlexLayoutManager',
      );
      expect(byName['FxListBox']?.xojoDesktopClass, 'DesktopListBox');
      expect(byName['FxGrid']?.xojoDesktopClass, 'DesktopGrid');
    });
  });

  group('widgets', () {
    testWidgets('FxFlexLayout renders fixed and grow children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 80,
              child: FxFlexLayout(
                gap: 8,
                children: [
                  FxFlexItem(
                    width: 100,
                    child: SizedBox(key: ValueKey('fixed'), height: 40),
                  ),
                  FxFlexItem(
                    grow: 1,
                    child: SizedBox(key: ValueKey('grow'), height: 40),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('fixed')), findsOneWidget);
      expect(find.byKey(const ValueKey('grow')), findsOneWidget);
    });

    testWidgets('FxGridLayout renders named areas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 200,
              child: FxGridLayout(
                areas: '''
header header
nav    content
''',
                columns: const [FxTrackSize.fixed(120), FxTrackSize.flex(1)],
                rows: const [FxTrackSize.fixed(40), FxTrackSize.flex(1)],
                children: [
                  const FxGridArea('header').containing(const Text('Header')),
                  const FxGridArea('nav').containing(const Text('Nav')),
                  const FxGridArea('content').containing(const Text('Content')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Nav'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('FxListBox supports row selection', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: FxListBox(
            height: 160,
            columns: const [
              FxListBoxColumn(id: 'id', caption: 'ID', width: 80),
              FxListBoxColumn(id: 'name', caption: 'Name', width: 140),
            ],
            rows: const [
              FxListBoxRow(id: 'r1', cells: {'id': '1', 'name': 'Alpha'}),
              FxListBoxRow(id: 'r2', cells: {'id': '2', 'name': 'Beta'}),
            ],
            onSelectionChanged: (rowId) => selected = rowId,
          ),
        ),
      );

      await tester.tap(find.text('Beta'));
      expect(selected, 'r2');
    });

    testWidgets('FxGrid supports cell selection', (tester) async {
      ({String rowId, String columnId})? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: FxGrid(
            height: 160,
            columns: const [
              FxGridColumn(id: 'name', caption: 'Name', width: 140),
              FxGridColumn(id: 'status', caption: 'Status', width: 120),
            ],
            rows: const [
              FxGridRow(id: 'r1', cells: {'name': 'Alpha', 'status': 'Open'}),
            ],
            onCellSelected: (rowId, columnId) {
              selected = (rowId: rowId, columnId: columnId);
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      expect(selected, (rowId: 'r1', columnId: 'status'));
    });

    testWidgets(
      'basic controls render enabled, disabled, and tristate states',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    FxTextField(label: 'Enabled field'),
                    FxTextField(label: 'Disabled field', enabled: false),
                    FxCheckBox(label: 'Checked', value: true),
                    FxCheckBox(label: 'Unchecked', value: false),
                    FxCheckBox(
                      label: 'Indeterminate',
                      value: null,
                      tristate: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Enabled field'), findsOneWidget);
        expect(find.text('Disabled field'), findsOneWidget);
        expect(find.text('Checked'), findsOneWidget);
        expect(find.text('Unchecked'), findsOneWidget);
        expect(find.text('Indeterminate'), findsOneWidget);
      },
    );
  });
}
