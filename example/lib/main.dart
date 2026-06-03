import 'package:flutter/material.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  runApp(const FxDesktopExampleApp());
}

class FxDesktopExampleApp extends StatelessWidget {
  const FxDesktopExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FxDesktop Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        useMaterial3: true,
        extensions: const [FxTheme()],
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String? selectedRowId = 'order-1';
  ({String rowId, String columnId})? selectedCell;
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: FxFlexLayout(
            direction: FxFlexDirection.column,
            gap: 14,
            children: [
              FxFlexItem(
                child: FxFlexLayout(
                  align: FxAlignItems.center,
                  justify: FxJustifyContent.spaceBetween,
                  children: [
                    const FxFlexItem(
                      child: Text(
                        'FxDesktop Gallery',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FxFlexItem(
                      child: FxButton(
                        label: 'Primary Action',
                        icon: Icons.play_arrow,
                        prominence: FxButtonProminence.primary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              FxFlexItem(
                child: FxGridLayout(
                  columns: const [FxTrackSize.fixed(320), FxTrackSize.flex(1)],
                  rows: const [FxTrackSize.auto(), FxTrackSize.fixed(260)],
                  rowGap: 14,
                  columnGap: 14,
                  areas: '''
form table
grid grid
''',
                  children: [
                    FxGridArea('form').containing(
                      FxGroupBox(
                        title: 'Comparable Controls',
                        child: FxFlexLayout(
                          direction: FxFlexDirection.column,
                          gap: 10,
                          children: [
                            const FxFlexItem(
                              child: FxTextField(
                                label: 'Customer',
                                hintText: 'Company or person name',
                              ),
                            ),
                            FxFlexItem(
                              child: FxCheckBox(
                                label: 'Active',
                                value: active,
                                onChanged: (value) {
                                  setState(() => active = value ?? false);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FxGridArea('table').containing(
                      FxListBox(
                        selectedRowId: selectedRowId,
                        onSelectionChanged: (rowId) {
                          setState(() => selectedRowId = rowId);
                        },
                        columns: const [
                          FxListBoxColumn(
                            id: 'number',
                            caption: 'Order',
                            width: 110,
                          ),
                          FxListBoxColumn(
                            id: 'customer',
                            caption: 'Customer',
                            width: 180,
                          ),
                          FxListBoxColumn(
                            id: 'status',
                            caption: 'Status',
                            width: 120,
                          ),
                        ],
                        rows: const [
                          FxListBoxRow(
                            id: 'order-1',
                            cells: {
                              'number': '1001',
                              'customer': 'Omega SA',
                              'status': 'Open',
                            },
                          ),
                          FxListBoxRow(
                            id: 'order-2',
                            cells: {
                              'number': '1002',
                              'customer': 'Gepard',
                              'status': 'Confirmed',
                            },
                          ),
                        ],
                      ),
                    ),
                    FxGridArea('grid').containing(
                      FxGrid(
                        selectedCell: selectedCell,
                        onCellSelected: (rowId, columnId) {
                          setState(() {
                            selectedCell = (rowId: rowId, columnId: columnId);
                          });
                        },
                        columns: const [
                          FxGridColumn(id: 'field', caption: 'Field'),
                          FxGridColumn(id: 'desktop', caption: 'Xojo Desktop'),
                          FxGridColumn(id: 'web', caption: 'Xojo Web'),
                        ],
                        rows: const [
                          FxGridRow(
                            id: 'layout',
                            cells: {
                              'field': 'Layout',
                              'desktop': 'DesktopFlexLayoutManager',
                              'web': 'WebFlexLayoutManager',
                            },
                          ),
                          FxGridRow(
                            id: 'table',
                            cells: {
                              'field': 'Table',
                              'desktop': 'DesktopListBox',
                              'web': 'WebListBox',
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
