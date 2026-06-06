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
      title: 'FxListBox Interactive Spec Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff6f7f9),
        cardColor: Colors.white,
        extensions: const [FxTheme()],
      ),
      home: const DemoGalleryPage(),
    );
  }
}

class DemoGalleryPage extends StatefulWidget {
  const DemoGalleryPage({super.key});

  @override
  State<DemoGalleryPage> createState() => _DemoGalleryPageState();
}

class _DemoGalleryPageState extends State<DemoGalleryPage> {
  int _currentPageIndex = 0;
  static const int _totalPages = 9;

  // Event Log Console
  final List<String> _logs = ['Welcome to the FxListBox Demo Console.'];
  final ScrollController _logScrollController = ScrollController();

  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Global undo controller for the demo
  final FxUndoController _undoController = FxUndoController();

  // Page 1: Selection Mode States
  FxListBoxSelectionMode _selectionMode = FxListBoxSelectionMode.single;
  Set<String> _selectedRowIdsPage1 = {'emp-1'};

  // Page 2: Sizing Policy States
  bool _resizableColumns = true;
  double _col2Width = 180;

  // Page 3: Sorting States
  String? _sortedColId = 'id';
  bool _sortAscending = true;
  final List<Map<String, Object?>> _sortableData = [
    {'id': 'E103', 'name': 'Bob Smith', 'dept': 'Engineering', 'salary': 95000},
    {'id': 'E101', 'name': 'Alice Johnson', 'dept': 'Design', 'salary': 105000},
    {'id': 'E104', 'name': 'Diana Prince', 'dept': 'Product', 'salary': 120000},
    {
      'id': 'E102',
      'name': 'Charlie Brown',
      'dept': 'Marketing',
      'salary': 85000,
    },
  ];

  // Page 4: Cell Editing States
  final List<Map<String, Object?>> _editableData = [
    {'id': 'emp-1', 'name': 'John Doe', 'active': true, 'role': 'Developer'},
    {'id': 'emp-2', 'name': 'Jane Miller', 'active': false, 'role': 'Designer'},
    {'id': 'emp-3', 'name': 'Sam Wilson', 'active': true, 'role': 'Manager'},
  ];

  // Page 5: Validation Errors States
  final Map<String, Map<String, String>> _validationErrors = {
    'emp-2': {'email': 'Invalid email format'},
  };
  final List<Map<String, Object?>> _validationData = [
    {
      'id': 'emp-1',
      'name': 'Alice Vance',
      'email': 'alice@fx.com',
      'age': '29',
    },
    {
      'id': 'emp-2',
      'name': 'Bob Vance',
      'email': 'bob-vance-invalid',
      'age': '45',
    },
    {
      'id': 'emp-3',
      'name': 'Charlie Vance',
      'email': 'charlie@fx.com',
      'age': 'abc',
    },
  ];

  // Page 6: Table States
  FxTableState _tableState = FxTableState.ready;
  final String _customErrorText =
      'Failed to connect to database. Please retry.';

  // Page 7: Large-Data Virtualization
  int _largeRowCount = 10000;
  Set<String> _selectedRowIdsPage7 = <String>{};

  // Page 8: Advanced Formatting & Excel-Style Features
  bool _page8LineWrap = false;
  final List<Map<String, Object?>> _advancedData = [
    {
      'id': 'P01',
      'name': 'John Doe',
      'sugar': '95',
      'status': 'true',
      'score': 12500,
      'progress': '75%',
      'notes': '<b>Urgent:</b> Sugar *optimal* ~check again~. Responding well.',
    },
    {
      'id': 'P02',
      'name': 'Jane Smith',
      'sugar': '145',
      'status': 'false',
      'score': 9800,
      'progress': '30%',
      'notes': '<b>Urgent:</b> Sugar *abnormal*. Regulation needed.',
    },
    {
      'id': 'P03',
      'name': 'Sam Wilson',
      'sugar': '62',
      'status': 'true',
      'score': 15620,
      'progress': '100%',
      'notes': 'Hypoglycemia warning. Glucose intake required ~immediately~.',
    },
    {
      'id': 'P04',
      'name': 'Diana Prince',
      'sugar': '88',
      'status': 'true',
      'score': 22400,
      'progress': '55%',
      'notes': 'Stable condition. Active physical exercises **maintained regularly**.',
    },
  ];
  final Map<String, double> _page8ColumnWidths = {};

  // Page 9: Range Slider & Grid Selection Crosshairs
  RangeValues _sliderRange = const RangeValues(20, 80);
  RangeValues? _sliderDragStartRange;
  Set<({String rowId, String columnId})> _selectedGridCellsPage9 = {
    (rowId: 'row-1', columnId: 'col-2')
  };
  final List<Map<String, Object?>> _gridDataPage9 = [
    {'id': 'row-1', 'col-1': 'Cell A1', 'col-2': 'Cell B1', 'col-3': 'Cell C1'},
    {'id': 'row-2', 'col-1': 'Cell A2', 'col-2': 'Cell B2', 'col-3': 'Cell C2'},
    {'id': 'row-3', 'col-1': 'Cell A3', 'col-2': 'Cell B3', 'col-3': 'Cell C3'},
  ];

  @override
  void initState() {
    super.initState();
    // Setup initial validation warning for age
    _validationErrors['emp-3'] = {'age': 'Age must be a numeric integer'};
  }

  void _nextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _log('Navigated to page ${_currentPageIndex + 1}');
    }
  }

  void _prevPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _log('Navigated to page ${_currentPageIndex + 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FxUndoScope(
        controller: _undoController,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Premium Application Header
              _buildHeader(theme),

              // Divider
              Container(height: 1, color: const Color(0xffd9dde5)),
              // 2. Horizontal Main Layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Pane: Guide / Information Card (PagePanel-controlled content)
                    _buildLeftGuidePane(theme),

                    // Vertical Divider
                    Container(width: 1, color: const Color(0xffd9dde5)),

                    // Right Pane: Active Interactive Sandbox Demo
                    Expanded(
                      child: Container(
                        color: const Color(0xfff6f7f9),
                        padding: const EdgeInsets.all(16),
                        child: FxPagePanel(
                          selectedIndex: _currentPageIndex,
                          children: [
                            _buildPage1SelectionModes(),
                            _buildPage2SizingAndResizing(),
                            _buildPage3Sorting(),
                            _buildPage4Editing(),
                            _buildPage5Validation(),
                            _buildPage6TableStates(),
                            _buildPage7Virtualization(),
                            _buildPage8AdvancedFeatures(),
                            _buildPage9RangeSliderAndCrosshairs(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Callback Logs Console & Undo Panel
              _buildBottomConsolePanel(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffd9dde5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_rows,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'FxListBox Interactive Spec Gallery',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'v0.3.2 Ready',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Page Panel Navigation Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxButton(
                label: 'Previous',
                onPressed: _currentPageIndex > 0 ? _prevPage : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Page ${_currentPageIndex + 1} / $_totalPages',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569), // Slate 600
                ),
              ),
              const SizedBox(width: 12),
              FxButton(
                label: 'Next',
                onPressed: _currentPageIndex < _totalPages - 1
                    ? _nextPage
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LEFT INFO / GUIDE PANE ---
  Widget _buildLeftGuidePane(ThemeData theme) {
    // Info details per page
    final titles = [
      'Row Selection Modes',
      'Column Sizing & Resizing',
      'Column Sorting',
      'Inline Cell Editing',
      'Cell-Level Validation',
      'Table States & Placeholders',
      'Large-Data Virtualization',
      'Excel-Style Advanced Features',
      'Range Slider & Crosshair Highlight',
    ];

    final descriptions = [
      'FxListBox supports three distinct row-selection behaviors matching DesktopListBox:\n\n'
          '• single: Allows choosing exactly one row at a time. Left-clicking or Arrow keys selects a single record.\n'
          '• multiple: Multi-row selection. Shift+Click or Shift+Arrow keys selects a continuous range. Ctrl/Cmd+Click toggles specific rows.\n'
          '• none: Disable all selection mechanics. Rows are read-only views.',

      'Demonstrates the flexible column layout manager:\n\n'
          '• fixed: Set column width to an absolute pixel dimension.\n'
          '• fraction: Set column width to a specific ratio of total listbox width.\n'
          '• remaining: Auto-stretches to fill any remaining viewport space.\n\n'
          'Interactive resizing can be enabled. Drag borders in the header to resize.',

      'Standard desktop column sorting indicators and behaviors:\n\n'
          '• Columns can opt in to be sortable.\n'
          '• Clicking headers triggers onSortChanged callback.\n'
          '• Shows an ascending or descending sort arrow on the active header.\n'
          '• Sorting remains driven by external state models.',

      'FxListBox cells can be edited inline, allowing data entry in list box fields:\n\n'
          '• Text cells: double-click to open text field editor. Press Enter to save, Esc to cancel.\n'
          '• Boolean cells: click checkbox directly to commit a toggle action.\n'
          '• Choice cells: double-click to open a dropdown selection list.',

      'Integrates cell validation errors directly into the grid:\n\n'
          '• Provide cell errors using validationErrors keyed by rowId and colId.\n'
          '• Cells with errors display a red validation indicator.\n'
          '• Hovering displays the validation error description.\n'
          '• Safe inputs allow editing invalid values without crashing.',

      'Provides built-in states and beautiful placeholders for full asynchronous workflow lifecycle states:\n\n'
          '• ready: Normal data rows active.\n'
          '• loading: Spinner loading overlay.\n'
          '• empty: State visual for zero-result tables.\n'
          '• error: Red error card displaying custom messages.',

      'Tests performance under massive dataset volumes:\n\n'
          '• Loads 10,000 rows x 50 columns seamlessly.\n'
          '• Uses two-dimensional virtualization layout to only mount visible viewport cells.\n'
          '• Keeps memory usage constant and runs scroll operations with high frame-rates.',

      'Demonstrates Excel-style advanced formatting and layout behaviors:\n\n'
          '• Auto-Fit Width: double-click the header\'s right border to automatically resize the column to fit its longest content.\n'
          '• Dynamic Row Heights: when Line Wrapping is enabled, row heights adjust automatically to display multi-line wrapped text.\n'
          '• Implicit Right Alignment: columns with numeric values automatically align trailing (right) for both headers and cells.\n'
          '• Implicit Checkboxes: case-insensitive "true"/"false" strings automatically render as interactive checkboxes.\n'
          '• Progress Bar Overlay: cells with percentage strings (e.g., "75%") draw a visual bottom-border progress chart.\n'
          '• Conditional Formatting: blood sugar values highlight red when abnormal (< 70 or > 100).',

      'Showcases advanced control features and cell crosshair highlight visualization:\n\n'
          '• Range Slider: select a minimum and maximum bounds range in a single component.\n'
          '• Selection Crosshair: selecting a cell highlights the correlated row (top/bottom) and column (left/right) with 50% darker border lines.\n'
          '• Row Reordering: drag the grab handles on the left side of rows to rearrange them manually. Row indices update instantly.',
    ];

    final guidanceSteps = [
      [
        'Toggle Selection Mode below the table.',
        'Click rows to select them.',
        'Use keyboard ArrowUp / ArrowDown keys.',
        'In multiple mode, hold Shift while pressing Arrow keys to select range.',
        'Notice the Selection Callback Log printed below.',
      ],
      [
        'Hover over header column split borders.',
        'Click and drag to resize Bob, Charlie, or Diana column widths.',
        'Verify that the remaining column auto-stretches.',
        'Observe Column Resized Callback Logs.',
      ],
      [
        'Click the Salary, Name, or ID column header.',
        'Click the same header twice to toggle sort direction (Asc / Desc).',
        'Observe row reordering and column sort indicators.',
        'Verify only Sortable columns react to clicks.',
      ],
      [
        'Double-click Samuel or John Doe role cell.',
        'Change role to Developer/Designer and press Enter.',
        'Click Active checkbox directly in the row to toggle status.',
        'Verify that changing inputs triggers commit logs.',
        'Try pressing Undo/Redo in the console to revert edits.',
      ],
      [
        'Locate the cells marked with red borders.',
        'Double-click the invalid Email field of Bob Vance.',
        'Type a valid email (with @) and press Enter to clear the error.',
        'Double-click Sam Vance Age, type a valid number (e.g. 35) to fix.',
        'Verify validation error indicators clear on valid commit.',
      ],
      [
        'Switch Table State in the control panel below the table.',
        'Notice how custom placeholders adjust to listbox size.',
        'Toggle Grid Lines on/off to compare border rendering.',
      ],
      [
        'Click Load 10k Rows to generate a large dataset.',
        'Scroll vertically and horizontally using scrollbars.',
        'Select a cell and press ArrowKeys (Up/Down/Right/Left) to stress traverse.',
        'Notice frame-rate performance stability.',
      ],
      [
        'Double-click the resize border of "Doctor Notes" or "Patient" header to auto-fit to content.',
        'Toggle Line Wrapping to see row heights adapt automatically.',
        'Observe implicit right alignment for "Score" and "Blood Sugar".',
        'Notice case-insensitive "true"/"false" render as interactive checkboxes.',
        'Look at the bottom progress bar chart on the "Progress" column cells.',
        'Notice abnormal Blood Sugar cells are conditionally highlighted in red.',
      ],
      [
        'Locate the Range Slider at the top. Drag either thumb to select min/max values.',
        'Locate the Grid below. Click cells or use keyboard arrows to move cell selection.',
        'Observe how the selected cell\'s row and column borders are redrawn 50% darker.',
        'Navigate to Page 8 to try Drag-and-Drop Row Reordering using the left grab handles.',
        'Notice that the notes on Page 8 support styled text (bold, italic, underline).',
      ],
    ];

    final currentGuidance = guidanceSteps[_currentPageIndex];

    return SizedBox(
      width: 330,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title
            Text(
              titles[_currentPageIndex],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Description Scroll Panel
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text Description Area
                    Text(
                      descriptions[_currentPageIndex],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334155), // Slate 700
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Guidance Checklist Title
                    Text(
                      'WHAT TO TRY / GUIDANCE:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B), // Slate 500
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Guidance checklist bullets
                    ...currentGuidance.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✓ ',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF475569), // Slate 600
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BOTTOM CALLBACK LOG CONSOLE & UNDO PANEL ---
  Widget _buildBottomConsolePanel(ThemeData theme) {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffd9dde5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Console Logs Output
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF8FAFC), // Slate 50
              child: ListView.builder(
                controller: _logScrollController,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Color(
                          0xFF047857,
                        ), // Emerald 700 (high contrast in light mode)
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Undo/Redo & Utility Panel
          Container(
            width: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Slate 100
              border: Border(left: BorderSide(color: Color(0xffd9dde5))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'UNDO HISTORY',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF475569), // Slate 600
                  ),
                ),
                const SizedBox(height: 6),
                FxButton(
                  label: 'Undo Action',
                  onPressed: _undoController.canUndo
                      ? () {
                          setState(() {
                            _undoController.undo();
                          });
                          _log('Undo operation performed.');
                        }
                      : null,
                ),
                const SizedBox(height: 6),
                FxButton(
                  label: 'Redo Action',
                  onPressed: _undoController.canRedo
                      ? () {
                          setState(() {
                            _undoController.redo();
                          });
                          _log('Redo operation performed.');
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAGE INTERACTIVE BUILDERS
  // ==========================================

  // --- PAGE 1: SELECTION MODES ---
  Widget _buildPage1SelectionModes() {
    final columns = const [
      FxListBoxColumn(id: 'id', caption: 'ID', width: FxColumnWidth.fixed(60)),
      FxListBoxColumn(
        id: 'name',
        caption: 'Name',
        width: FxColumnWidth.fixed(140),
      ),
      FxListBoxColumn(
        id: 'role',
        caption: 'Role',
        width: FxColumnWidth.fixed(120),
      ),
      FxListBoxColumn(
        id: 'status',
        caption: 'Status',
        width: FxColumnWidth.remaining(),
      ),
    ];

    final rows = const [
      FxListBoxRow(
        id: 'emp-1',
        cells: {
          'id': 'E01',
          'name': 'John Doe',
          'role': 'Developer',
          'status': 'Active',
        },
      ),
      FxListBoxRow(
        id: 'emp-2',
        cells: {
          'id': 'E02',
          'name': 'Jane Miller',
          'role': 'Designer',
          'status': 'Away',
        },
      ),
      FxListBoxRow(
        id: 'emp-3',
        cells: {
          'id': 'E03',
          'name': 'Sam Wilson',
          'role': 'Manager',
          'status': 'Active',
        },
      ),
      FxListBoxRow(
        id: 'emp-4',
        cells: {
          'id': 'E04',
          'name': 'Diana Prince',
          'role': 'VP Product',
          'status': 'Busy',
        },
        enabled: false,
      ), // Disabled row
      FxListBoxRow(
        id: 'emp-5',
        cells: {
          'id': 'E05',
          'name': 'Bruce Wayne',
          'role': 'CEO',
          'status': 'Active',
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Row Selection Mode Sandbox',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            selectedRowIds: _selectedRowIdsPage1,
            selectionMode: _selectionMode,
            onSelectionChanged: (selectedIds) {
              setState(() {
                _selectedRowIdsPage1 = selectedIds;
              });
              _log('Selection Changed: $selectedIds');
            },
          ),
        ),
        const SizedBox(height: 12),
        // Controls
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selection Mode: '),
                const SizedBox(width: 8),
                FxSegmentedButton<FxListBoxSelectionMode>(
                  options: const [
                    FxSegmentedOption(
                      value: FxListBoxSelectionMode.none,
                      label: 'None',
                    ),
                    FxSegmentedOption(
                      value: FxListBoxSelectionMode.single,
                      label: 'Single',
                    ),
                    FxSegmentedOption(
                      value: FxListBoxSelectionMode.multiple,
                      label: 'Multiple',
                    ),
                  ],
                  value: _selectionMode,
                  onChanged: (mode) {
                    setState(() {
                      _selectionMode = mode;
                      _selectedRowIdsPage1 = <String>{};
                    });
                    _log('Selection Mode updated to: ${mode.name}');
                  },
                ),
              ],
            ),
            Text(
              'Selected: ${_selectedRowIdsPage1.isEmpty ? "None" : _selectedRowIdsPage1.join(", ")}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // --- PAGE 2: SIZING AND RESIZING ---
  Widget _buildPage2SizingAndResizing() {
    final columns = [
      const FxListBoxColumn(
        id: 'id',
        caption: 'ID (Fixed: 60)',
        width: FxColumnWidth.fixed(60),
        sortable: false,
      ),
      FxListBoxColumn(
        id: 'name',
        caption: 'Name (Resizable)',
        width: FxColumnWidth.fixed(_col2Width),
        sortable: false,
      ),
      const FxListBoxColumn(
        id: 'bio',
        caption: 'Biography (Fractional: 0.35)',
        width: FxColumnWidth.fraction(0.35),
        sortable: false,
      ),
      const FxListBoxColumn(
        id: 'joined',
        caption: 'Joined (Flexible)',
        width: FxColumnWidth.remaining(),
        sortable: false,
      ),
    ];

    final rows = const [
      FxListBoxRow(
        id: 'emp-1',
        cells: {
          'id': 'E01',
          'name': 'Alice Johnson',
          'bio': 'Alice is a senior developer with 8 years of experience.',
          'joined': '2018-05-12',
        },
      ),
      FxListBoxRow(
        id: 'emp-2',
        cells: {
          'id': 'E02',
          'name': 'Bob Smith',
          'bio':
              'Bob manages the design systems and typography specifications.',
          'joined': '2020-03-01',
        },
      ),
      FxListBoxRow(
        id: 'emp-3',
        cells: {
          'id': 'E03',
          'name': 'Charlie Brown',
          'bio': 'Charlie handles DevOps automation pipelines.',
          'joined': '2021-09-15',
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Column Sizing Strategies & Resizing',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            onColumnResized: _resizableColumns
                ? (columnId, newWidth) {
                    setState(() {
                      if (columnId == 'name') {
                        _col2Width = newWidth;
                      }
                    });
                    _log('Column resized: $columnId -> $newWidth px');
                  }
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Column resizing: '),
                const SizedBox(width: 8),
                Switch(
                  value: _resizableColumns,
                  activeThumbColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    setState(() {
                      _resizableColumns = val;
                    });
                    _log('Resizable columns toggled: $val');
                  },
                ),
              ],
            ),
            Text(
              'Widths: ID: 60 | Name: ${_col2Width.round()} | Bio: 35% | Joined: Remaining',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  // --- PAGE 3: SORTING ---
  Widget _buildPage3Sorting() {
    final columns = [
      const FxListBoxColumn(
        id: 'id',
        caption: 'ID (Sortable)',
        width: FxColumnWidth.fixed(70),
        sortable: true,
      ),
      const FxListBoxColumn(
        id: 'name',
        caption: 'Name (Sortable)',
        width: FxColumnWidth.fixed(150),
        sortable: true,
      ),
      const FxListBoxColumn(
        id: 'dept',
        caption: 'Department',
        width: FxColumnWidth.fixed(120),
        sortable: false,
      ),
      const FxListBoxColumn(
        id: 'salary',
        caption: 'Salary (Sortable)',
        width: FxColumnWidth.remaining(),
        sortable: true,
      ),
    ];

    final rows = _sortableData.map((data) {
      return FxListBoxRow(
        id: data['id'] as String,
        cells: {
          'id': data['id'],
          'name': data['name'],
          'dept': data['dept'],
          'salary':
              '\$${(data['salary'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}',
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Column Sorting Playground',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            sortedColumnId: _sortedColId,
            sortAscending: _sortAscending,
            onSortChanged: (columnId, ascending) {
              setState(() {
                _sortedColId = columnId;
                _sortAscending = ascending;

                _sortableData.sort((a, b) {
                  final valA = a[columnId];
                  final valB = b[columnId];
                  int cmp = 0;
                  if (valA is num && valB is num) {
                    cmp = valA.compareTo(valB);
                  } else {
                    cmp = valA.toString().compareTo(valB.toString());
                  }
                  return ascending ? cmp : -cmp;
                });
              });
              _log('Sorted column: $columnId, Ascending: $ascending');
            },
          ),
        ),
      ],
    );
  }

  // --- PAGE 4: EDITING ---
  Widget _buildPage4Editing() {
    final columns = const [
      FxListBoxColumn(id: 'id', caption: 'ID', width: FxColumnWidth.fixed(60)),
      FxListBoxColumn(
        id: 'name',
        caption: 'Name (Editable)',
        width: FxColumnWidth.fixed(140),
        editable: true,
      ),
      FxListBoxColumn(
        id: 'active',
        caption: 'Active (Boolean)',
        width: FxColumnWidth.fixed(110),
        editable: true,
        type: FxCellType.boolean(),
      ),
      FxListBoxColumn(
        id: 'role',
        caption: 'Role (Choice)',
        width: FxColumnWidth.remaining(),
        editable: true,
        type: FxCellType.choice([
          'Developer',
          'Designer',
          'Manager',
          'Product Manager',
        ]),
      ),
    ];

    final rows = _editableData.map((data) {
      return FxListBoxRow(
        id: data['id'] as String,
        cells: {
          'id': data['id'],
          'name': data['name'],
          'active': data['active'],
          'role': data['role'],
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Cell Editing Sandbox (Supports Undo/Redo)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            onCellEdited: (rowId, columnId, newValue) {
              // Record undo action
              final rowIndex = _editableData.indexWhere(
                (r) => r['id'] == rowId,
              );
              if (rowIndex != -1) {
                final oldValue = _editableData[rowIndex][columnId];
                _undoController.commitValue<Object?>(
                  'Edit $columnId',
                  oldValue: oldValue,
                  newValue: newValue,
                  apply: (val) {
                    setState(() {
                      _editableData[rowIndex][columnId] = val;
                    });
                  },
                );
                _log('Cell Edited: Row: $rowId, Col: $columnId -> $newValue');
              }
            },
          ),
        ),
      ],
    );
  }

  // --- PAGE 5: VALIDATION ---
  Widget _buildPage5Validation() {
    final columns = const [
      FxListBoxColumn(id: 'id', caption: 'ID', width: FxColumnWidth.fixed(50)),
      FxListBoxColumn(
        id: 'name',
        caption: 'Name',
        width: FxColumnWidth.fixed(120),
      ),
      FxListBoxColumn(
        id: 'email',
        caption: 'Email (Editable)',
        width: FxColumnWidth.fixed(180),
        editable: true,
      ),
      FxListBoxColumn(
        id: 'age',
        caption: 'Age (Editable)',
        width: FxColumnWidth.remaining(),
        editable: true,
      ),
    ];

    final rows = _validationData.map((data) {
      return FxListBoxRow(
        id: data['id'] as String,
        cells: {
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'age': data['age'],
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Live Cell Validation Error Markers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            validationErrors: _validationErrors,
            onCellEdited: (rowId, columnId, newValue) {
              setState(() {
                final rowIndex = _validationData.indexWhere(
                  (r) => r['id'] == rowId,
                );
                if (rowIndex != -1) {
                  _validationData[rowIndex][columnId] =
                      newValue?.toString() ?? '';

                  // Evaluate validation rules
                  final rowErrors = Map<String, String>.from(
                    _validationErrors[rowId] ?? {},
                  );

                  if (columnId == 'email') {
                    final emailStr = newValue?.toString() ?? '';
                    if (!emailStr.contains('@')) {
                      rowErrors['email'] = 'Email must contain @ character';
                    } else {
                      rowErrors.remove('email');
                    }
                  } else if (columnId == 'age') {
                    final ageStr = newValue?.toString() ?? '';
                    final val = int.tryParse(ageStr);
                    if (val == null) {
                      rowErrors['age'] = 'Age must be a numeric integer';
                    } else if (val < 18 || val > 120) {
                      rowErrors['age'] = 'Age must be between 18 and 120';
                    } else {
                      rowErrors.remove('age');
                    }
                  }

                  if (rowErrors.isEmpty) {
                    _validationErrors.remove(rowId);
                  } else {
                    _validationErrors[rowId] = rowErrors;
                  }
                }
              });
              _log('Validation check run for edit: Row $rowId Col $columnId');
            },
          ),
        ),
      ],
    );
  }

  // --- PAGE 6: TABLE STATES ---
  Widget _buildPage6TableStates() {
    final columns = const [
      FxListBoxColumn(id: 'id', caption: 'ID', width: FxColumnWidth.fixed(60)),
      FxListBoxColumn(
        id: 'name',
        caption: 'Name',
        width: FxColumnWidth.fixed(140),
      ),
      FxListBoxColumn(
        id: 'role',
        caption: 'Role',
        width: FxColumnWidth.remaining(),
      ),
    ];

    final rows = const [
      FxListBoxRow(
        id: 'emp-1',
        cells: {'id': 'E01', 'name': 'John Doe', 'role': 'Developer'},
      ),
      FxListBoxRow(
        id: 'emp-2',
        cells: {'id': 'E02', 'name': 'Jane Miller', 'role': 'Designer'},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Table Workflow States & Placeholders',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            state: _tableState,
            errorText: _customErrorText,
          ),
        ),
        const SizedBox(height: 12),
        // Controls
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Table State: '),
                const SizedBox(width: 8),
                FxSegmentedButton<FxTableState>(
                  options: const [
                    FxSegmentedOption(
                      value: FxTableState.ready,
                      label: 'Ready',
                    ),
                    FxSegmentedOption(
                      value: FxTableState.loading,
                      label: 'Loading',
                    ),
                    FxSegmentedOption(
                      value: FxTableState.empty,
                      label: 'Empty',
                    ),
                    FxSegmentedOption(
                      value: FxTableState.error,
                      label: 'Error',
                    ),
                  ],
                  value: _tableState,
                  onChanged: (state) {
                    setState(() {
                      _tableState = state;
                    });
                    _log('Table state changed to: ${state.name}');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- PAGE 7: VIRTUALIZATION ---
  Widget _buildPage7Virtualization() {
    // Columns: 50 columns
    final List<FxListBoxColumn> columns = [
      const FxListBoxColumn(
        id: 'id',
        caption: 'Row ID',
        width: FxColumnWidth.fixed(90),
      ),
      for (int i = 1; i <= 49; i++)
        FxListBoxColumn(
          id: 'col-$i',
          caption: 'Column $i',
          width: const FxColumnWidth.fixed(110),
        ),
    ];

    // Build deterministic rows dynamically based on count
    final List<FxListBoxRow> rows = [
      for (int i = 0; i < _largeRowCount; i++)
        FxListBoxRow(
          id: 'row-$i',
          cells: {
            'id': 'ID #$i',
            for (int j = 1; j <= 49; j++) 'col-$j': 'Cell $i,$j',
          },
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Virtualized Grid Performance: $_largeRowCount Rows x 50 Columns',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            selectedRowIds: _selectedRowIdsPage7,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedRowIdsPage7 = selected;
              });
              _log('Virtualized selection count: ${selected.length}');
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Dataset Scale: '),
                const SizedBox(width: 8),
                FxSegmentedButton<int>(
                  options: const [
                    FxSegmentedOption(value: 1000, label: '1k Rows'),
                    FxSegmentedOption(value: 5000, label: '5k Rows'),
                    FxSegmentedOption(value: 10000, label: '10k Rows'),
                  ],
                  value: _largeRowCount,
                  onChanged: (count) {
                    setState(() {
                      _largeRowCount = count;
                      _selectedRowIdsPage7 = <String>{};
                    });
                    _log('Virtualized dataset scale set to $count rows');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- PAGE 8: ADVANCED FEATURES ---
  Widget _buildPage8AdvancedFeatures() {
    final columns = [
      FxListBoxColumn(
        id: 'id',
        caption: 'ID',
        width: FxColumnWidth.fixed(_page8ColumnWidths['id'] ?? 50),
      ),
      FxListBoxColumn(
        id: 'name',
        caption: 'Patient',
        width: FxColumnWidth.fixed(_page8ColumnWidths['name'] ?? 100),
      ),
      FxListBoxColumn(
        id: 'sugar',
        caption: 'Blood Sugar',
        width: FxColumnWidth.fixed(_page8ColumnWidths['sugar'] ?? 90),
      ),
      FxListBoxColumn(
        id: 'status',
        caption: 'Insured',
        width: FxColumnWidth.fixed(_page8ColumnWidths['status'] ?? 70),
        editable: true,
      ),
      FxListBoxColumn(
        id: 'score',
        caption: 'Score',
        width: FxColumnWidth.fixed(_page8ColumnWidths['score'] ?? 80),
      ),
      FxListBoxColumn(
        id: 'progress',
        caption: 'Progress',
        width: FxColumnWidth.fixed(_page8ColumnWidths['progress'] ?? 90),
      ),
      FxListBoxColumn(
        id: 'notes',
        caption: 'Doctor Notes',
        width: _page8ColumnWidths['notes'] != null
            ? FxColumnWidth.fixed(_page8ColumnWidths['notes']!)
            : const FxColumnWidth.remaining(),
        lineWrap: _page8LineWrap,
        supportStyledText: true,
      ),
    ];

    final rows = _advancedData.map((data) {
      return FxListBoxRow(
        id: data['id'] as String,
        cells: {
          'id': data['id'],
          'name': data['name'],
          'sugar': data['sugar'],
          'status': data['status'],
          'score': data['score'],
          'progress': data['progress'],
          'notes': data['notes'],
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Excel-Style Formatting & Advanced Features',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxListBox(
            columns: columns,
            rows: rows,
            rowHeight: 28,
            allowRowReordering: true,
            onRowReordered: (oldIndex, newIndex) {
              _undoController.commit(
                FxUndoAction(
                  label: 'Reorder Patient Rows',
                  apply: () {
                    setState(() {
                      final item = _advancedData.removeAt(oldIndex);
                      _advancedData.insert(newIndex, item);
                    });
                    _log('Page 8 Reordered rows: $oldIndex -> $newIndex');
                  },
                  revert: () {
                    setState(() {
                      final item = _advancedData.removeAt(newIndex);
                      _advancedData.insert(oldIndex, item);
                    });
                    _log('Page 8 Revert reordered rows: $newIndex -> $oldIndex');
                  },
                ),
              );
            },
            onColumnResized: (columnId, newWidth) {
              setState(() {
                _page8ColumnWidths[columnId] = newWidth;
              });
              _log('Page 8 Column resized: $columnId -> ${newWidth.round()}px');
            },
            cellBackgroundColorBuilder: (rowId, columnId, value) {
              if (columnId == 'sugar') {
                final val = double.tryParse(value?.toString() ?? '');
                if (val != null && (val > 100 || val < 70)) {
                  return const Color(0xfffee2e2); // soft red highlight
                }
              }
              return null;
            },
            onCellEdited: (rowId, columnId, newValue) {
              setState(() {
                final rowIndex = _advancedData.indexWhere((r) => r['id'] == rowId);
                if (rowIndex != -1) {
                  _advancedData[rowIndex][columnId] = newValue;
                }
              });
              _log('Page 8 Edited Cell: Row: $rowId, Col: $columnId -> $newValue');
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Line Wrapping: '),
                const SizedBox(width: 8),
                Switch(
                  value: _page8LineWrap,
                  activeThumbColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    _undoController.commitValue<bool>(
                      'Toggle line wrapping',
                      oldValue: _page8LineWrap,
                      newValue: val,
                      apply: (newVal) {
                        setState(() {
                          _page8LineWrap = newVal;
                        });
                        _log('Page 8 Line wrap set to: $newVal');
                      },
                    );
                  },
                ),
                const SizedBox(width: 16),
                FxButton(
                  label: 'Reset Column Widths',
                  onPressed: () {
                    setState(() {
                      _page8ColumnWidths.clear();
                    });
                    _log('Page 8 Column widths reset to default.');
                  },
                ),
              ],
            ),
            const Text(
              'Try: Double-click resize borders, toggle Line Wrap, edit Insured checkboxes.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage9RangeSliderAndCrosshairs() {
    final columns = [
      const FxGridColumn(
        id: 'col-1',
        caption: 'Column A',
        width: FxColumnWidth.fixed(100),
      ),
      const FxGridColumn(
        id: 'col-2',
        caption: 'Column B',
        width: FxColumnWidth.fixed(100),
      ),
      const FxGridColumn(
        id: 'col-3',
        caption: 'Column C',
        width: FxColumnWidth.fixed(100),
      ),
    ];

    final rows = _gridDataPage9.map((data) {
      return FxGridRow(
        id: data['id'] as String,
        cells: {
          'col-1': data['col-1'],
          'col-2': data['col-2'],
          'col-3': data['col-3'],
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Range Slider & Grid Selection Crosshairs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // FxSlider.range demo
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xffd9dde5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Range Slider (FxSlider.range)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                FxSlider.range(
                  rangeValue: _sliderRange,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  valueLabel: '${_sliderRange.start.round()} - ${_sliderRange.end.round()}',
                  onRangeChanged: (val) {
                    setState(() {
                      _sliderRange = val;
                    });
                    _log('Range Slider changed: ${val.start.round()} - ${val.end.round()}');
                  },
                  onChangeStartRange: (val) {
                    _sliderDragStartRange = val;
                  },
                  onChangeEndRange: (val) {
                    final startVal = _sliderDragStartRange ?? const RangeValues(20, 80);
                    _undoController.commitValue<RangeValues>(
                      'Range Slider',
                      oldValue: startVal,
                      newValue: val,
                      apply: (newRange) {
                        setState(() {
                          _sliderRange = newRange;
                        });
                        _log('Undo/Redo Range Slider: ${newRange.start.round()} - ${newRange.end.round()}');
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Grid selection crosshair demo
        const Text(
          'Grid Selection Crosshair Highlight (Darkened by 50%)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FxGrid(
            columns: columns,
            rows: rows,
            selectedCells: _selectedGridCellsPage9,
            onCellsSelected: (cells) {
              setState(() {
                _selectedGridCellsPage9 = cells;
              });
              if (cells.isNotEmpty) {
                final cell = cells.last;
                _log('Selected Grid Cell: Row: ${cell.rowId}, Col: ${cell.columnId}');
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Try: Click or use arrow keys to navigate the grid cells. The selected cell\'s row and column borders are redrawn 50% darker.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
