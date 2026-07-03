import 'package:flutter/material.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  runApp(const FxListBoxDemoApp());
}

class FxListBoxDemoApp extends StatelessWidget {
  const FxListBoxDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FxDesktop — ListBox & Grid',
      debugShowCheckedModeBanner: false,
      theme: FxThemeData.light(),
      darkTheme: FxThemeData.dark(),
      home: const DataGalleryPage(),
    );
  }
}

/// Recreation of the FxDesktop DS `data_gallery` kit: record selection +
/// sorting (FxListBox), inline cell editing (FxGrid), and an autocomplete
/// lookup — three focused sections in a centered column.
class DataGalleryPage extends StatefulWidget {
  const DataGalleryPage({super.key});

  @override
  State<DataGalleryPage> createState() => _DataGalleryPageState();
}

class _DataGalleryPageState extends State<DataGalleryPage> {
  Set<String> _selected = {'o1'};
  FxListBoxSelectionMode _mode = FxListBoxSelectionMode.single;
  String? _sortColumn;
  bool _sortAscending = true;
  String _city = '';

  List<FxListBoxRow> _orders = const [
    FxListBoxRow(
      id: 'o1',
      cells: {
        'number': '1001',
        'customer': 'Omega SA',
        'city': 'Bangkok',
        'status': 'Open',
        'total': '12,400',
        'approved': true,
      },
    ),
    FxListBoxRow(
      id: 'o2',
      cells: {
        'number': '1002',
        'customer': 'Gepard GmbH',
        'city': 'Berlin',
        'status': 'Confirmed',
        'total': '8,900',
        'approved': false,
      },
    ),
    FxListBoxRow(
      id: 'o3',
      enabled: false,
      cells: {
        'number': '1003',
        'customer': 'Initech',
        'city': 'Boston',
        'status': 'Draft',
        'total': '3,150',
        'approved': false,
      },
    ),
    FxListBoxRow(
      id: 'o4',
      cells: {
        'number': '1004',
        'customer': 'Wayne Ent.',
        'city': 'Zurich',
        'status': 'Open',
        'total': '24,720',
        'approved': true,
      },
    ),
    FxListBoxRow(
      id: 'o5',
      cells: {
        'number': '1005',
        'customer': 'Soylent Co',
        'city': 'Boston',
        'status': 'Shipped',
        'total': '5,600',
        'approved': true,
      },
    ),
    FxListBoxRow(
      id: 'o6',
      cells: {
        'number': '1006',
        'customer': 'Hooli',
        'city': 'Bangkok',
        'status': 'Confirmed',
        'total': '18,050',
        'approved': false,
      },
    ),
    FxListBoxRow(
      id: 'o7',
      cells: {
        'number': '1007',
        'customer': 'Stark Ind.',
        'city': 'Berlin',
        'status': 'Open',
        'total': '42,000',
        'approved': true,
      },
    ),
  ];

  List<FxGridRow> _lines = const [
    FxGridRow(
      id: 'l1',
      cells: {
        'sku': 'FX-100',
        'item': 'Flex layout license',
        'qty': '3',
        'price': '1,200',
        'taxable': true,
      },
    ),
    FxGridRow(
      id: 'l2',
      cells: {
        'sku': 'FX-220',
        'item': 'ListBox add-on',
        'qty': '1',
        'price': '3,400',
        'taxable': true,
      },
    ),
    FxGridRow(
      id: 'l3',
      cells: {
        'sku': 'FX-500',
        'item': 'Ribbon designer',
        'qty': '2',
        'price': '2,600',
        'taxable': false,
      },
    ),
    FxGridRow(
      id: 'l4',
      cells: {
        'sku': 'FX-900',
        'item': 'Support, annual',
        'qty': '1',
        'price': '8,900',
        'taxable': false,
      },
    ),
  ];
  Set<({String rowId, String columnId})> _gridCells = const {};

  static const _orderColumns = [
    FxListBoxColumn(
      id: 'number',
      caption: 'Order',
      width: FxColumnWidth.fixed(80),
      sortable: true,
    ),
    FxListBoxColumn(
      id: 'customer',
      caption: 'Customer',
      width: FxColumnWidth.fixed(180),
      sortable: true,
    ),
    FxListBoxColumn(
      id: 'city',
      caption: 'City',
      width: FxColumnWidth.fixed(120),
      sortable: true,
    ),
    FxListBoxColumn(
      id: 'status',
      caption: 'Status',
      width: FxColumnWidth.fixed(120),
      sortable: true,
      type: FxCellType.choice(['Draft', 'Open', 'Confirmed', 'Shipped']),
    ),
    FxListBoxColumn(
      id: 'total',
      caption: 'Total',
      width: FxColumnWidth.fixed(100),
      alignment: FxCellAlignment.trailing,
      sortable: true,
    ),
    FxListBoxColumn(
      id: 'approved',
      caption: '✓',
      width: FxColumnWidth.fixed(64),
      alignment: FxCellAlignment.center,
      type: FxCellType.boolean(),
    ),
  ];

  static const _lineColumns = [
    FxGridColumn(id: 'sku', caption: 'SKU', width: FxColumnWidth.fixed(96)),
    FxGridColumn(
      id: 'item',
      caption: 'Item',
      width: FxColumnWidth.fixed(220),
      editable: true,
    ),
    FxGridColumn(
      id: 'qty',
      caption: 'Qty',
      width: FxColumnWidth.fixed(74),
      alignment: FxCellAlignment.trailing,
      editable: true,
    ),
    FxGridColumn(
      id: 'price',
      caption: 'Unit ฿',
      width: FxColumnWidth.fixed(96),
      alignment: FxCellAlignment.trailing,
      editable: true,
    ),
    FxGridColumn(
      id: 'taxable',
      caption: 'Tax',
      width: FxColumnWidth.fixed(70),
      alignment: FxCellAlignment.center,
      editable: true,
      type: FxCellType.boolean(),
    ),
  ];

  void _sortOrders(String columnId, bool ascending) {
    setState(() {
      _sortColumn = columnId;
      _sortAscending = ascending;
      _orders = [..._orders]
        ..sort((a, b) {
          final va = a.cells[columnId]?.toString() ?? '';
          final vb = b.cells[columnId]?.toString() ?? '';
          final cmp = va.compareTo(vb);
          return ascending ? cmp : -cmp;
        });
    });
  }

  void _editLine(String rowId, String columnId, Object? value) {
    setState(() {
      _lines = [
        for (final row in _lines)
          if (row.id == rowId)
            FxGridRow(
              id: row.id,
              cells: {...row.cells, columnId: value},
              enabled: row.enabled,
            )
          else
            row,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                      context,
                      Icons.table_rows_outlined,
                      'FxListBox',
                      'record selection · click a header to sort · arrow keys to traverse',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          FxSegmentedButton<FxListBoxSelectionMode>(
                            value: _mode,
                            options: const [
                              FxSegmentedOption(
                                value: FxListBoxSelectionMode.single,
                                label: 'Single',
                              ),
                              FxSegmentedOption(
                                value: FxListBoxSelectionMode.multiple,
                                label: 'Multi (⌘-click)',
                              ),
                            ],
                            onChanged: (value) => setState(() => _mode = value),
                          ),
                          const Spacer(),
                          FxButton(
                            label: 'Export TSV',
                            icon: Icons.download_outlined,
                            prominence: FxButtonProminence.quiet,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    FxListBox(
                      height: 210,
                      columns: _orderColumns,
                      rows: _orders,
                      selectionMode: _mode,
                      selectedRowIds: _selected,
                      onSelectionChanged: (ids) =>
                          setState(() => _selected = ids),
                      sortedColumnId: _sortColumn,
                      sortAscending: _sortAscending,
                      onSortChanged: _sortOrders,
                    ),
                    const SizedBox(height: 22),
                    _sectionHeader(
                      context,
                      Icons.grid_on_outlined,
                      'FxGrid',
                      'cell editing · double-click a text/number cell · click a checkbox to toggle',
                    ),
                    FxGrid(
                      height: 168,
                      columns: _lineColumns,
                      rows: _lines,
                      selectionMode: FxGridSelectionMode.cell,
                      selectedCells: _gridCells,
                      onCellsSelected: (cells) =>
                          setState(() => _gridCells = cells),
                      onCellEdited: _editLine,
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionHeader(
                            context,
                            Icons.manage_search_outlined,
                            'Lookup',
                            'autocomplete combo',
                          ),
                          FxComboBox(
                            label: 'Filter by city',
                            value: _city,
                            options: const [
                              'Bangkok',
                              'Berlin',
                              'Boston',
                              'Zurich',
                            ],
                            onChanged: (value) => setState(() => _city = value),
                            onOptionSelected: (value) =>
                                setState(() => _city = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sub,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
