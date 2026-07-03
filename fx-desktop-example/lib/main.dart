import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  runApp(const FxDesktopExampleApp());
}

const _demoLocaleOptions = [
  _DemoLocaleOption(label: 'English', locale: Locale('en')),
  _DemoLocaleOption(label: 'Thai', locale: Locale('th')),
  _DemoLocaleOption(label: 'Japanese', locale: Locale('ja')),
  _DemoLocaleOption(label: 'Nepali', locale: Locale('ne')),
];

class FxDesktopExampleApp extends StatefulWidget {
  const FxDesktopExampleApp({super.key});

  @override
  State<FxDesktopExampleApp> createState() => _FxDesktopExampleAppState();
}

class _FxDesktopExampleAppState extends State<FxDesktopExampleApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;
  FxDensityProfile _profile = FxDensityProfile.desktop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FxDesktop Example',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: FxDesktopLocalizations.supportedLocales,
      localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
      theme: FxThemeData.light(profile: _profile),
      darkTheme: FxThemeData.dark(profile: _profile),
      themeMode: _themeMode,
      home: ExampleHomePage(
        locale: _locale,
        onLocaleChanged: (locale) {
          setState(() => _locale = locale);
        },
        themeMode: _themeMode,
        onThemeModeChanged: (mode) {
          setState(() => _themeMode = mode);
        },
        profile: _profile,
        onProfileChanged: (profile) {
          setState(() => _profile = profile);
        },
      ),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.profile,
    required this.onProfileChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final FxDensityProfile profile;
  final ValueChanged<FxDensityProfile> onProfileChanged;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final ScrollController scrollController = ScrollController();
  final FxUndoController undoController = FxUndoController();
  Set<String> selectedRowIds = const {'order-1'};
  Set<({String rowId, String columnId})> selectedCells = const {};
  FxGridCellRange? selectedRange;
  List<FxListBoxRow> listBoxRows = [
    const FxListBoxRow(
      id: 'order-1',
      cells: {
        'number': '1001',
        'customer': 'Omega SA',
        'status': 'Open',
        'approved': true,
      },
    ),
    const FxListBoxRow(
      id: 'order-2',
      cells: {
        'number': '1002',
        'customer': 'Gepard',
        'status': 'Confirmed',
        'approved': false,
      },
    ),
    const FxListBoxRow(
      id: 'order-3',
      cells: {
        'number': '1003',
        'customer': 'Cindy Crawford',
        'status': 'Draft',
        'approved': false,
      },
      enabled: false,
    ),
  ];
  List<FxGridRow> gridRows = [
    const FxGridRow(
      id: 'layout',
      cells: {
        'field': 'Layout',
        'desktop': 'DesktopFlexLayoutManager',
        'web': 'WebFlexLayoutManager',
        'enabled': true,
      },
    ),
    const FxGridRow(
      id: 'table',
      cells: {
        'field': 'Table',
        'desktop': 'DesktopListBox',
        'web': 'WebListBox',
        'enabled': false,
      },
    ),
  ];
  String? sortedListBoxColumnId;
  bool sortedListBoxAscending = true;
  String? sortedGridColumnId;
  bool sortedGridAscending = true;
  Map<String, Map<String, String>> listBoxValidationErrors = {
    'order-2': {'customer': 'Must be at least 3 characters'},
  };
  Map<String, Map<String, String>> gridValidationErrors = {};

  bool active = true;
  bool inactive = false;
  bool? optional;
  String? popupStatus = 'Open';
  String comboValue = 'Bangkok';
  String? radioChoice = 'standard';
  String? radioGroupChoice = 'email';
  double priority = 40;
  DateTime? dueDate = DateTime(2026, 6, 4);
  DateTime? reminderTime = DateTime(2026, 6, 4, 9, 30);
  DateTime? appointment = DateTime(2026, 6, 4, 14, 15);
  int selectedTabIndex = 0;
  int selectedPageIndex = 0;
  int selectedCardIndex = 0;
  bool orderExpanded = true;
  bool auditExpanded = false;
  Color? accentColor = const Color(0xff2563eb);
  Color? optionalColor;
  bool undoApproved = false;
  String? undoStatus = 'Draft';
  String undoCustomer = 'Cindy Crawford';
  double undoPriority = 30;
  double undoPriorityDragStart = 30;
  int undoTabIndex = 0;
  bool _showLayoutBounds = false;

  @override
  void dispose() {
    undoController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _commitUndoValue<T>({
    required String label,
    required T oldValue,
    required T newValue,
    required void Function(T nextValue) apply,
  }) {
    undoController.commitValue<T>(
      label,
      oldValue: oldValue,
      newValue: newValue,
      apply: (nextValue) => setState(() => apply(nextValue)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FxUndoScope(
      controller: undoController,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 52, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'FxDesktop Component Harness',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'One component per row, optimized for desktop visual checks.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              _DemoSettingsBar(
                                locale: widget.locale,
                                onLocaleChanged: widget.onLocaleChanged,
                                themeMode: widget.themeMode,
                                onThemeModeChanged: widget.onThemeModeChanged,
                                profile: widget.profile,
                                onProfileChanged: widget.onProfileChanged,
                                showLayoutBounds: _showLayoutBounds,
                                onShowLayoutBoundsChanged: (value) {
                                  setState(() {
                                    _showLayoutBounds = value;
                                    debugPaintSizeEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          _ComponentRow(
                            name: 'FxRibbonToolbar',
                            child: SizedBox(
                              height: FxRibbonDensity.regular.expandedHeight,
                              child: FxRibbonToolbar(
                                definition: FxRibbonSamples.explorer(),
                                locale: widget.locale,
                                interactionMode: FxRibbonInteractionMode.mouse,
                              ),
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextField Phase 2.5 Constraints & Masks',
                            child: _StateSamples(
                              sampleWidth: 320,
                              children: const [
                                _StateSample(
                                  label: 'Required + count',
                                  child: FxTextField(
                                    label: 'Customer',
                                    value: 'Omega SA',
                                    requiredInput: true,
                                    reserveSupportingTextSpace: true,
                                    helpText: 'Required single-line input.',
                                    constraints: FxTextInputConstraints(
                                      minLength: 3,
                                      maxLength: 24,
                                      showCharacterCount: true,
                                    ),
                                  ),
                                ),
                                _StateSample(
                                  label: 'Numeric',
                                  child: FxTextField(
                                    label: 'Order No',
                                    value: '589434',
                                    hintText: 'Digits only',
                                    constraints: FxTextInputConstraints(
                                      kind: FxTextInputConstraintKind.numeric,
                                      maxLength: 8,
                                      showCharacterCount: true,
                                    ),
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Alphanumeric',
                                  child: FxTextField(
                                    label: 'Campaign Code',
                                    value: 'KW2507',
                                    hintText: 'Letters and digits only',
                                    constraints: FxTextInputConstraints(
                                      kind: FxTextInputConstraintKind
                                          .alphanumeric,
                                      maxLength: 12,
                                    ),
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Forbidden chars',
                                  child: FxTextField(
                                    label: 'Slug',
                                    value: 'omega-sa',
                                    helpText: 'Spaces and slashes are removed.',
                                    reserveSupportingTextSpace: true,
                                    constraints: FxTextInputConstraints(
                                      forbiddenCharacters: [' ', '/'],
                                    ),
                                  ),
                                ),
                                _StateSample(
                                  label: 'Phone mask',
                                  child: FxTextField(
                                    label: 'Phone',
                                    value: '9-1234-5678',
                                    hintText: '#-####-####',
                                    format: FxTextInputFormat.pattern(
                                      '#-####-####',
                                    ),
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Fixed decimal',
                                  child: FxTextField(
                                    label: 'Budget',
                                    value: '1,234.50',
                                    helpText: 'Groups on commit/blur.',
                                    format: FxTextInputFormat.number(
                                      decimalDigits: 2,
                                    ),
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextArea Phase 2.5 Constraints',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Required + count',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    value:
                                        'Confirm campaign, venue, and delivery window.',
                                    requiredInput: true,
                                    helpText:
                                        'Character counter can be visible.',
                                    reserveSupportingTextSpace: true,
                                    constraints: FxTextInputConstraints(
                                      minLength: 10,
                                      maxLength: 120,
                                      showCharacterCount: true,
                                    ),
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Forbidden pattern',
                                  child: FxTextArea(
                                    label: 'Internal Comment',
                                    value:
                                        'Visible notes stay concise and reviewable.',
                                    helpText:
                                        'Rejects configured forbidden patterns.',
                                    reserveSupportingTextSpace: true,
                                    constraints: FxTextInputConstraints(
                                      forbiddenPattern: r'password|secret',
                                    ),
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Tab metadata',
                                  child: FxTextArea(
                                    label: 'Plain Text',
                                    value:
                                        'Pasted tab characters can be preserved when needed.',
                                    helpText:
                                        'Keyboard Tab still follows focus traversal.',
                                    reserveSupportingTextSpace: true,
                                    constraints: FxTextInputConstraints(
                                      allowTab: true,
                                      maxLength: 160,
                                    ),
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'Decorated Input Alignment',
                            child: _StateSamples(
                              sampleWidth: 320,
                              children: [
                                const _StateSample(
                                  label: 'Text field',
                                  child: FxTextField(
                                    label: 'Reference',
                                    value: 'A-589434',
                                    helpText: 'Has supporting text.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Date/time',
                                  child: FxDateTimePicker(
                                    label: 'Due Date',
                                    value: dueDate,
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => dueDate = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Popup menu',
                                  child: FxPopupMenu(
                                    label: 'Status',
                                    selectedValue: popupStatus,
                                    options: const [
                                      'Open',
                                      'Pending',
                                      'Closed',
                                    ],
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => popupStatus = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Combo box',
                                  child: FxComboBox(
                                    label: 'City',
                                    value: comboValue,
                                    options: const [
                                      'Bangkok',
                                      'Boston',
                                      'Berlin',
                                      'Zurich',
                                    ],
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => comboValue = value);
                                    },
                                    onOptionSelected: (value) {
                                      setState(() => comboValue = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextField Phase 2.4 Depth',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Helper',
                                  child: FxTextField(
                                    label: 'Customer',
                                    hintText: 'Company or person name',
                                    helpText:
                                        'Comparable to DesktopTextField/WebTextField.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextField(
                                    label: 'Order No',
                                    hintText: 'Required order number',
                                    errorText: 'Order number is required.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextField(
                                    label: 'Contract',
                                    value: 'A 589434',
                                    readOnly: true,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Password / icons',
                                  child: FxTextField(
                                    label: 'Password',
                                    value: 'temporary',
                                    obscureText: true,
                                    prefixIcon: Icons.lock,
                                    suffixIcon: Icons.visibility,
                                    helpText: 'Obscured single-line input.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextArea Phase 2.4 Depth',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Helper',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Enter multiple lines',
                                    helpText: 'Visible to the operations team.',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Enter notes',
                                    errorText: 'Notes are required.',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextArea(
                                    label: 'Audit',
                                    value:
                                        'Created by order workflow.\nReviewed by operations.',
                                    readOnly: true,
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Multiline scroll',
                                  child: FxTextArea(
                                    label: 'History',
                                    value:
                                        'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxUndoController / FxUndoScope',
                            child: _StateSamples(
                              sampleWidth: 360,
                              children: [
                                _StateSample(
                                  label: 'Committed value changes',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FxCheckBox(
                                        label: 'Approved',
                                        value: undoApproved,
                                        onChanged: (value) {
                                          _commitUndoValue<bool>(
                                            label: 'Change approval',
                                            oldValue: undoApproved,
                                            newValue: value ?? false,
                                            apply: (nextValue) =>
                                                undoApproved = nextValue,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FxPopupMenu(
                                        label: 'Status',
                                        options: const [
                                          'Draft',
                                          'Pending',
                                          'Approved',
                                        ],
                                        selectedValue: undoStatus,
                                        onChanged: (value) {
                                          _commitUndoValue<String?>(
                                            label: 'Change status',
                                            oldValue: undoStatus,
                                            newValue: value,
                                            apply: (nextValue) =>
                                                undoStatus = nextValue,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Approved: $undoApproved, Status: $undoStatus',
                                      ),
                                    ],
                                  ),
                                ),
                                _StateSample(
                                  label: 'Text commit and slider drag end',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FxTextField(
                                        label: 'Customer',
                                        value: undoCustomer,
                                        helpText: 'Commits on Enter or blur.',
                                        onCommit: (value) {
                                          _commitUndoValue<String>(
                                            label: 'Change customer',
                                            oldValue: undoCustomer,
                                            newValue: value,
                                            apply: (nextValue) =>
                                                undoCustomer = nextValue,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FxSlider(
                                        value: undoPriority,
                                        min: 0,
                                        max: 100,
                                        divisions: 10,
                                        valueLabel: '${undoPriority.round()}%',
                                        onChangeStart: (value) =>
                                            undoPriorityDragStart = value,
                                        onChanged: (value) {
                                          setState(() => undoPriority = value);
                                        },
                                        onChangeEnd: (value) {
                                          _commitUndoValue<double>(
                                            label: 'Change priority',
                                            oldValue: undoPriorityDragStart,
                                            newValue: value,
                                            apply: (nextValue) =>
                                                undoPriority = nextValue,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                _StateSample(
                                  label: 'Indexed navigation state',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FxTabPanel(
                                        tabs: const [
                                          'Summary',
                                          'Pricing',
                                          'Audit',
                                        ],
                                        selectedIndex: undoTabIndex,
                                        onChanged: (index) {
                                          _commitUndoValue<int>(
                                            label: 'Change undo sample tab',
                                            oldValue: undoTabIndex,
                                            newValue: index,
                                            apply: (nextValue) =>
                                                undoTabIndex = nextValue,
                                          );
                                        },
                                        children: const [
                                          _NavigationContentPanel(
                                            title: 'Summary',
                                            body: 'Undo sample summary.',
                                            accentColor: Color(0xff2563eb),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Pricing',
                                            body: 'Undo sample pricing.',
                                            accentColor: Color(0xff16a34a),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Audit',
                                            body: 'Undo sample audit log.',
                                            accentColor: Color(0xffb45309),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _UndoCommandBar(
                                        controller: undoController,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxButton',
                            child: _StateSamples(
                              children: [
                                _StateSample(
                                  label: 'Primary enabled',
                                  child: FxButton(
                                    label: 'Primary',
                                    icon: Icons.play_arrow,
                                    prominence: FxButtonProminence.primary,
                                    onPressed: () {},
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Primary disabled',
                                  child: FxButton(
                                    label: 'Primary',
                                    icon: Icons.play_arrow,
                                    prominence: FxButtonProminence.primary,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Normal',
                                  child: FxButton(
                                    label: 'Normal',
                                    onPressed: () {},
                                  ),
                                ),
                                _StateSample(
                                  label: 'Quiet',
                                  child: FxButton(
                                    label: 'Quiet',
                                    prominence: FxButtonProminence.quiet,
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextField',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Helper',
                                  child: FxTextField(
                                    label: 'Customer',
                                    hintText: 'Company or person name',
                                    helpText:
                                        'Comparable to DesktopTextField/WebTextField.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextField(
                                    label: 'Order No',
                                    hintText: 'Required order number',
                                    errorText: 'Order number is required.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextField(
                                    label: 'Contract',
                                    value: 'A 589434',
                                    readOnly: true,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Password / icons',
                                  child: FxTextField(
                                    label: 'Password',
                                    value: 'temporary',
                                    obscureText: true,
                                    prefixIcon: Icons.lock,
                                    suffixIcon: Icons.visibility,
                                    helpText: 'Obscured single-line input.',
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxTextField(
                                    label: 'Customer',
                                    hintText: 'Disabled field',
                                    enabled: false,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxTextArea',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Helper',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Enter multiple lines',
                                    helpText: 'Visible to the operations team.',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Enter notes',
                                    errorText: 'Notes are required.',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextArea(
                                    label: 'Audit',
                                    value:
                                        'Created by order workflow.\nReviewed by operations.',
                                    readOnly: true,
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Multiline scroll',
                                  child: FxTextArea(
                                    label: 'History',
                                    value:
                                        'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 3,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Disabled text area',
                                    reserveSupportingTextSpace: true,
                                    minLines: 3,
                                    maxLines: 4,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxLabel',
                            child: _StateSamples(
                              sampleWidth: 340,
                              children: const [
                                _StateSample(
                                  label: 'Enabled',
                                  child: FxLabel(
                                    text:
                                        'Order summary label with wrapping enabled.',
                                  ),
                                ),
                                _StateSample(
                                  label: 'Centered',
                                  child: FxLabel(
                                    text: 'Centered label',
                                    alignment: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxLabel(
                                    text: 'Disabled label',
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxPopupMenu',
                            child: _StateSamples(
                              sampleWidth: 320,
                              children: [
                                _StateSample(
                                  label: 'Selected fixed choice',
                                  child: FxPopupMenu(
                                    label: 'Status',
                                    options: const [
                                      'Open',
                                      'Pending',
                                      'Closed',
                                    ],
                                    selectedValue: popupStatus,
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => popupStatus = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Empty options',
                                  child: FxPopupMenu(
                                    label: 'Status',
                                    options: [],
                                    reserveSupportingTextSpace: true,
                                    emptyText: 'No statuses',
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxPopupMenu(
                                    label: 'Status',
                                    options: ['Open', 'Pending', 'Closed'],
                                    selectedValue: 'Pending',
                                    enabled: false,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxComboBox',
                            child: _StateSamples(
                              sampleWidth: 360,
                              children: [
                                _StateSample(
                                  label: 'Editable with autocomplete',
                                  child: FxComboBox(
                                    label: 'City',
                                    value: comboValue,
                                    options: const [
                                      'Bangkok',
                                      'Boston',
                                      'Berlin',
                                      'Zurich',
                                    ],
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => comboValue = value);
                                    },
                                    onOptionSelected: (value) {
                                      setState(() => comboValue = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxComboBox(
                                    label: 'City',
                                    value: 'Zurich',
                                    options: ['Bangkok', 'Boston', 'Berlin'],
                                    enabled: false,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxCheckBox',
                            child: _StateSamples(
                              sampleWidth: 220,
                              children: [
                                _StateSample(
                                  label: 'Checked',
                                  child: FxCheckBox(
                                    label: 'Active',
                                    value: active,
                                    onChanged: (value) {
                                      setState(() => active = value ?? false);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Unchecked',
                                  child: FxCheckBox(
                                    label: 'Inactive',
                                    value: inactive,
                                    onChanged: (value) {
                                      setState(() => inactive = value ?? false);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Indeterminate',
                                  child: FxCheckBox(
                                    label: 'Optional',
                                    value: optional,
                                    tristate: true,
                                    onChanged: (value) {
                                      setState(() => optional = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxCheckBox(
                                    label: 'Disabled',
                                    value: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxRadioButton',
                            child: _StateSamples(
                              sampleWidth: 240,
                              children: [
                                _StateSample(
                                  label: 'Selected',
                                  child: FxRadioButton<String>(
                                    label: 'Standard',
                                    value: 'standard',
                                    groupValue: radioChoice,
                                    onChanged: (value) {
                                      setState(() => radioChoice = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Unselected',
                                  child: FxRadioButton<String>(
                                    label: 'Express',
                                    value: 'express',
                                    groupValue: radioChoice,
                                    onChanged: (value) {
                                      setState(() => radioChoice = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxRadioButton<String>(
                                    label: 'Disabled',
                                    value: 'disabled',
                                    selected: false,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxRadioGroup',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: [
                                _StateSample(
                                  label: 'Vertical group',
                                  child: FxRadioGroup<String>(
                                    value: radioGroupChoice,
                                    options: const [
                                      FxRadioOption(
                                        value: 'email',
                                        label: 'Email',
                                      ),
                                      FxRadioOption(
                                        value: 'phone',
                                        label: 'Phone',
                                      ),
                                      FxRadioOption(
                                        value: 'letter',
                                        label: 'Letter',
                                        enabled: false,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => radioGroupChoice = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Horizontal group',
                                  child: FxRadioGroup<String>(
                                    value: radioGroupChoice,
                                    orientation: FxChoiceOrientation.horizontal,
                                    options: const [
                                      FxRadioOption(
                                        value: 'email',
                                        label: 'Email',
                                      ),
                                      FxRadioOption(
                                        value: 'phone',
                                        label: 'Phone',
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => radioGroupChoice = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled group',
                                  child: FxRadioGroup<String>(
                                    value: 'email',
                                    enabled: false,
                                    options: [
                                      FxRadioOption(
                                        value: 'email',
                                        label: 'Email',
                                      ),
                                      FxRadioOption(
                                        value: 'phone',
                                        label: 'Phone',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxDateTimePicker',
                            child: _StateSamples(
                              sampleWidth: 340,
                              children: [
                                _StateSample(
                                  label: 'Date',
                                  child: FxDateTimePicker(
                                    label: 'Due Date',
                                    value: dueDate,
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => dueDate = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Time',
                                  child: FxDateTimePicker(
                                    label: 'Reminder',
                                    mode: FxDateTimePickerMode.time,
                                    value: reminderTime,
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => reminderTime = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'Date and time',
                                  child: FxDateTimePicker(
                                    label: 'Appointment',
                                    mode: FxDateTimePickerMode.dateTime,
                                    value: appointment,
                                    reserveSupportingTextSpace: true,
                                    onChanged: (value) {
                                      setState(() => appointment = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxDateTimePicker(
                                    label: 'Disabled Date',
                                    value: null,
                                    enabled: false,
                                    reserveSupportingTextSpace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxSlider',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: [
                                _StateSample(
                                  label: 'Range with divisions',
                                  child: FxSlider(
                                    value: priority,
                                    min: 0,
                                    max: 100,
                                    divisions: 10,
                                    valueLabel: '${priority.round()}%',
                                    onChanged: (value) {
                                      setState(() => priority = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxSlider(
                                    value: 25,
                                    min: 0,
                                    max: 100,
                                    divisions: 4,
                                    valueLabel: '25%',
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name:
                                'FxTabPanel / FxPagePanel / FxSegmentedButton + FxCardContainer',
                            child: _StateSamples(
                              sampleWidth: 340,
                              children: [
                                _StateSample(
                                  label: 'Visible tabs',
                                  child: FxTabPanel(
                                    tabs: const [
                                      'Overview',
                                      'Pricing',
                                      'History',
                                    ],
                                    selectedIndex: selectedTabIndex,
                                    onChanged: (index) {
                                      setState(() => selectedTabIndex = index);
                                    },
                                    children: const [
                                      _NavigationContentPanel(
                                        title: 'Overview',
                                        body: 'Three open orders need review.',
                                        accentColor: Color(0xff2563eb),
                                      ),
                                      _NavigationContentPanel(
                                        title: 'Pricing',
                                        body: 'Discount cap is set to 12%.',
                                        accentColor: Color(0xff16a34a),
                                      ),
                                      _NavigationContentPanel(
                                        title: 'History',
                                        body:
                                            'Last edited by Cindy on Tuesday.',
                                        accentColor: Color(0xffb45309),
                                      ),
                                    ],
                                  ),
                                ),
                                _StateSample(
                                  label: 'Headless indexed pages',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FxSegmentedButton<int>(
                                        value: selectedPageIndex,
                                        options: const [
                                          FxSegmentedOption(
                                            value: 0,
                                            label: 'Form',
                                          ),
                                          FxSegmentedOption(
                                            value: 1,
                                            label: 'Rows',
                                          ),
                                          FxSegmentedOption(
                                            value: 2,
                                            label: 'Notes',
                                          ),
                                        ],
                                        onChanged: (index) {
                                          setState(
                                            () => selectedPageIndex = index,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FxPagePanel(
                                        selectedIndex: selectedPageIndex,
                                        children: const [
                                          _NavigationContentPanel(
                                            title: 'Form Page',
                                            body:
                                                'Customer fields are shown here.',
                                            accentColor: Color(0xff7c3aed),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Table Page',
                                            body:
                                                'Line item rows replace the form.',
                                            accentColor: Color(0xff0f766e),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Notes Page',
                                            body:
                                                'Internal comments use this page.',
                                            accentColor: Color(0xffbe123c),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                _StateSample(
                                  label: 'Segmented cards',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FxSegmentedButton<int>(
                                        value: selectedCardIndex,
                                        options: const [
                                          FxSegmentedOption(
                                            value: 0,
                                            label: 'Summary',
                                          ),
                                          FxSegmentedOption(
                                            value: 1,
                                            label: 'Files',
                                          ),
                                          FxSegmentedOption(
                                            value: 2,
                                            label: 'Tasks',
                                          ),
                                        ],
                                        onChanged: (index) {
                                          setState(
                                            () => selectedCardIndex = index,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FxCardContainer(
                                        selectedIndex: selectedCardIndex,
                                        children: const [
                                          _NavigationContentPanel(
                                            title: 'Summary Card',
                                            body:
                                                'Current campaign is confirmed.',
                                            accentColor: Color(0xff0891b2),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Files Card',
                                            body: 'Four proofs are attached.',
                                            accentColor: Color(0xff4f46e5),
                                          ),
                                          _NavigationContentPanel(
                                            title: 'Tasks Card',
                                            body: 'Two approvals remain open.',
                                            accentColor: Color(0xffca8a04),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxDisclosureTriangle',
                            child: _StateSamples(
                              sampleWidth: 340,
                              children: [
                                _StateSample(
                                  label: 'Expanded',
                                  child: FxDisclosureTriangle(
                                    expanded: orderExpanded,
                                    title: 'Order details',
                                    onChanged: (value) {
                                      setState(() => orderExpanded = value);
                                    },
                                    child: const _NavigationContentPanel(
                                      title: 'Visible Details',
                                      body:
                                          'Billing and delivery fields are open.',
                                      accentColor: Color(0xff2563eb),
                                    ),
                                  ),
                                ),
                                _StateSample(
                                  label: 'Collapsed',
                                  child: FxDisclosureTriangle(
                                    expanded: auditExpanded,
                                    title: 'Audit trail',
                                    onChanged: (value) {
                                      setState(() => auditExpanded = value);
                                    },
                                    child: const _NavigationContentPanel(
                                      title: 'Audit Entries',
                                      body:
                                          'Three changes are ready to inspect.',
                                      accentColor: Color(0xff16a34a),
                                    ),
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxDisclosureTriangle(
                                    expanded: false,
                                    title: 'Disabled section',
                                    enabled: false,
                                    child: _NavigationContentPanel(
                                      title: 'Disabled Content',
                                      body: 'This content stays hidden.',
                                      accentColor: Color(0xff6b7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxColorPicker',
                            child: _StateSamples(
                              sampleWidth: 300,
                              children: [
                                _StateSample(
                                  label: 'HSV / hex picker',
                                  child: FxColorPicker(
                                    label: 'Accent',
                                    value: accentColor,
                                    onChanged: (value) {
                                      setState(() => accentColor = value);
                                    },
                                  ),
                                ),
                                _StateSample(
                                  label: 'No color',
                                  child: FxColorPicker(
                                    label: 'Optional',
                                    value: optionalColor,
                                    onChanged: (value) {
                                      setState(() => optionalColor = value);
                                    },
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled',
                                  child: FxColorPicker(
                                    label: 'Disabled',
                                    value: Color(0xff64748b),
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxProgressBar / FxProgressWheel',
                            child: _StateSamples(
                              sampleWidth: 300,
                              children: const [
                                _StateSample(
                                  label: 'Minimum',
                                  child: FxProgressBar(value: 0),
                                ),
                                _StateSample(
                                  label: 'Partial',
                                  child: FxProgressBar(value: 62),
                                ),
                                _StateSample(
                                  label: 'Complete',
                                  child: FxProgressBar(value: 100),
                                ),
                                _StateSample(
                                  label: 'Disabled progress',
                                  child: FxProgressBar(
                                    value: 40,
                                    enabled: false,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Loading wheel',
                                  child: FxProgressWheel(size: 28),
                                ),
                                _StateSample(
                                  label: 'Disabled wheel',
                                  child: FxProgressWheel(
                                    enabled: false,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxSeparator',
                            child: _StateSamples(
                              sampleWidth: 360,
                              children: const [
                                _StateSample(
                                  label: 'Horizontal rule',
                                  child: _SeparatorHorizontalSample(),
                                ),
                                _StateSample(
                                  label: 'Vertical rule',
                                  child: _SeparatorVerticalSample(),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxStyledLabel',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: const [
                                _StateSample(
                                  label: 'Rich label',
                                  child: FxStyledLabel(
                                    text: 'Status: priority order is overdue',
                                    spans: [
                                      FxStyledTextSpan(text: 'Status: '),
                                      FxStyledTextSpan(
                                        text: 'priority order',
                                        style: TextStyle(
                                          color: Color(0xffbe123c),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      FxStyledTextSpan(text: ' is overdue'),
                                    ],
                                  ),
                                ),
                                _StateSample(
                                  label: 'Wrapped help text',
                                  child: FxStyledLabel(
                                    text:
                                        'Use styled labels for compact help text with emphasized terms.',
                                    spans: [
                                      FxStyledTextSpan(
                                        text:
                                            'Use styled labels for compact help text with ',
                                      ),
                                      FxStyledTextSpan(
                                        text: 'emphasized terms.',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xff0f766e),
                                        ),
                                      ),
                                    ],
                                    softWrap: true,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxStyledLabel(
                                    text: 'Disabled styled label',
                                    enabled: false,
                                    spans: [
                                      FxStyledTextSpan(text: 'Disabled '),
                                      FxStyledTextSpan(
                                        text: 'styled label',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxGroupBox',
                            child: _StateSamples(
                              sampleWidth: 420,
                              children: [
                                _StateSample(
                                  label: 'Enabled child controls',
                                  child: FxGroupBox(
                                    title: 'Order Options',
                                    child: Row(
                                      children: [
                                        FxButton(
                                          label: 'Confirm',
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 8),
                                        FxButton(
                                          label: 'Cancel',
                                          prominence: FxButtonProminence.quiet,
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const _StateSample(
                                  label: 'Disabled child controls',
                                  child: FxGroupBox(
                                    title: 'Disabled Options',
                                    child: Row(
                                      children: [
                                        FxButton(label: 'Confirm'),
                                        SizedBox(width: 8),
                                        FxButton(
                                          label: 'Cancel',
                                          prominence: FxButtonProminence.quiet,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxFlexLayout',
                            child: SizedBox(
                              height: 74,
                              child: FxFlexLayout(
                                align: FxAlignItems.center,
                                gap: 10,
                                padding: const EdgeInsets.all(10),
                                children: [
                                  const FxFlexItem(
                                    width: 150,
                                    height: 44,
                                    child: _DemoBox('Fixed width'),
                                  ),
                                  const FxFlexItem(
                                    grow: 1,
                                    height: 44,
                                    child: _DemoBox('Grow = 1'),
                                  ),
                                  const FxFlexItem(
                                    width: 130,
                                    height: 44,
                                    child: _DemoBox('Fixed'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxGridLayout',
                            child: SizedBox(
                              height: 120,
                              child: FxGridLayout(
                                columns: const [
                                  FxTrackSize.fixed(160),
                                  FxTrackSize.flex(1),
                                ],
                                rows: const [
                                  FxTrackSize.fixed(44),
                                  FxTrackSize.fixed(58),
                                ],
                                rowGap: 8,
                                columnGap: 8,
                                areas: '''
label field
label action
''',
                                children: [
                                  const FxGridArea(
                                    'label',
                                  ).containing(_DemoBox('Named area')),
                                  const FxGridArea('field').containing(
                                    FxTextField(label: 'Grid field'),
                                  ),
                                  FxGridArea('action').containing(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: FxButton(
                                        label: 'Grid Action',
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxListBox',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FxListBox(
                                  height: 180,
                                  selectedRowIds: selectedRowIds,
                                  onSelectionChanged: (rowIds) {
                                    setState(() => selectedRowIds = rowIds);
                                  },
                                  sortedColumnId: sortedListBoxColumnId,
                                  sortAscending: sortedListBoxAscending,
                                  onSortChanged: (columnId, ascending) {
                                    setState(() {
                                      sortedListBoxColumnId = columnId;
                                      sortedListBoxAscending = ascending;
                                      listBoxRows.sort((a, b) {
                                        final valA =
                                            a.cells[columnId]?.toString() ?? '';
                                        final valB =
                                            b.cells[columnId]?.toString() ?? '';
                                        final cmp = valA.compareTo(valB);
                                        return ascending ? cmp : -cmp;
                                      });
                                    });
                                  },
                                  validationErrors: listBoxValidationErrors,
                                  onCellEdited: (rowId, columnId, newValue) {
                                    setState(() {
                                      final rowIndex = listBoxRows.indexWhere(
                                        (r) => r.id == rowId,
                                      );
                                      if (rowIndex != -1) {
                                        final oldRow = listBoxRows[rowIndex];
                                        final nextCells =
                                            Map<String, Object?>.from(
                                              oldRow.cells,
                                            );
                                        nextCells[columnId] = newValue;
                                        listBoxRows[rowIndex] = FxListBoxRow(
                                          id: oldRow.id,
                                          cells: nextCells,
                                          enabled: oldRow.enabled,
                                          height: oldRow.height,
                                          rowTag: oldRow.rowTag,
                                        );

                                        // Dynamic validation
                                        final errors =
                                            Map<
                                              String,
                                              Map<String, String>
                                            >.from(listBoxValidationErrors);
                                        if (columnId == 'customer') {
                                          final strVal =
                                              newValue?.toString() ?? '';
                                          if (strVal.isEmpty) {
                                            errors.putIfAbsent(
                                                  rowId,
                                                  () => {},
                                                )[columnId] =
                                                'Customer name cannot be empty';
                                          } else if (strVal.length < 3) {
                                            errors.putIfAbsent(
                                                  rowId,
                                                  () => {},
                                                )[columnId] =
                                                'Must be at least 3 characters';
                                          } else {
                                            errors[rowId]?.remove(columnId);
                                          }
                                        }
                                        listBoxValidationErrors = errors;
                                      }
                                    });
                                  },
                                  columns: const [
                                    FxListBoxColumn(
                                      id: 'number',
                                      caption: 'Order',
                                      width: FxColumnWidth.fixed(110),
                                      sortable: true,
                                      editable: true,
                                    ),
                                    FxListBoxColumn(
                                      id: 'customer',
                                      caption: 'Customer',
                                      width: FxColumnWidth.fixed(180),
                                      sortable: true,
                                      editable: true,
                                    ),
                                    FxListBoxColumn(
                                      id: 'status',
                                      caption: 'Status',
                                      width: FxColumnWidth.fixed(130),
                                      sortable: true,
                                      editable: true,
                                      type: FxCellType.choice([
                                        'Draft',
                                        'Open',
                                        'Confirmed',
                                        'Closed',
                                      ]),
                                    ),
                                    FxListBoxColumn(
                                      id: 'approved',
                                      caption: 'Approved',
                                      width: FxColumnWidth.fixed(100),
                                      sortable: true,
                                      editable: true,
                                      type: FxCellType.boolean(),
                                    ),
                                  ],
                                  rows: listBoxRows,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tip: Use double-click or Enter to edit cells. Use Ctrl+C/Cmd+C to copy selected rows, and Ctrl+V/Cmd+V to paste TSV data. Edits are tracked in the Undo history.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxGrid',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FxGrid(
                                  height: 180,
                                  selectedCells: selectedCells,
                                  selectedRange: selectedRange,
                                  selectionMode: FxGridSelectionMode.range,
                                  onCellsSelected: (cells) {
                                    setState(() {
                                      selectedCells = cells;
                                    });
                                  },
                                  onRangeSelected: (range) {
                                    setState(() {
                                      selectedRange = range;
                                    });
                                  },
                                  sortedColumnId: sortedGridColumnId,
                                  sortAscending: sortedGridAscending,
                                  onSortChanged: (columnId, ascending) {
                                    setState(() {
                                      sortedGridColumnId = columnId;
                                      sortedGridAscending = ascending;
                                      gridRows.sort((a, b) {
                                        final valA =
                                            a.cells[columnId]?.toString() ?? '';
                                        final valB =
                                            b.cells[columnId]?.toString() ?? '';
                                        final cmp = valA.compareTo(valB);
                                        return ascending ? cmp : -cmp;
                                      });
                                    });
                                  },
                                  validationErrors: gridValidationErrors,
                                  onCellEdited: (rowId, columnId, newValue) {
                                    setState(() {
                                      final rowIndex = gridRows.indexWhere(
                                        (r) => r.id == rowId,
                                      );
                                      if (rowIndex != -1) {
                                        final oldRow = gridRows[rowIndex];
                                        final nextCells =
                                            Map<String, Object?>.from(
                                              oldRow.cells,
                                            );
                                        nextCells[columnId] = newValue;
                                        gridRows[rowIndex] = FxGridRow(
                                          id: oldRow.id,
                                          cells: nextCells,
                                          enabled: oldRow.enabled,
                                          height: oldRow.height,
                                          rowTag: oldRow.rowTag,
                                          cellTags: oldRow.cellTags,
                                        );

                                        // Dynamic validation
                                        final errors =
                                            Map<
                                              String,
                                              Map<String, String>
                                            >.from(gridValidationErrors);
                                        if (columnId == 'desktop' ||
                                            columnId == 'web') {
                                          final strVal =
                                              newValue?.toString() ?? '';
                                          if (strVal.isEmpty) {
                                            errors.putIfAbsent(
                                                  rowId,
                                                  () => {},
                                                )[columnId] =
                                                'Value cannot be empty';
                                          } else {
                                            errors[rowId]?.remove(columnId);
                                          }
                                        }
                                        gridValidationErrors = errors;
                                      }
                                    });
                                  },
                                  columns: const [
                                    FxGridColumn(
                                      id: 'field',
                                      caption: 'Field',
                                      width: FxColumnWidth.fixed(140),
                                      sortable: true,
                                    ),
                                    FxGridColumn(
                                      id: 'desktop',
                                      caption: 'Xojo Desktop',
                                      width: FxColumnWidth.fixed(230),
                                      sortable: true,
                                      editable: true,
                                    ),
                                    FxGridColumn(
                                      id: 'web',
                                      caption: 'Xojo Web',
                                      width: FxColumnWidth.fixed(190),
                                      sortable: true,
                                      editable: true,
                                    ),
                                    FxGridColumn(
                                      id: 'enabled',
                                      caption: 'Enabled',
                                      width: FxColumnWidth.fixed(100),
                                      sortable: true,
                                      editable: true,
                                      type: FxCellType.boolean(),
                                    ),
                                  ],
                                  rows: gridRows,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tip: Click and drag to select a range of cells. Use Ctrl+C/Cmd+C to copy selected cells, and Ctrl+V/Cmd+V to paste TSV data. Edits are tracked in the Undo history.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StateSamples extends StatelessWidget {
  const _StateSamples({required this.children, this.sampleWidth});

  final List<Widget> children;
  final double? sampleWidth;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (final child in children)
          SizedBox(width: sampleWidth, child: child),
      ],
    );
  }
}

class _DemoSettingsBar extends StatelessWidget {
  const _DemoSettingsBar({
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.profile,
    required this.onProfileChanged,
    required this.showLayoutBounds,
    required this.onShowLayoutBoundsChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final FxDensityProfile profile;
  final ValueChanged<FxDensityProfile> onProfileChanged;
  final bool showLayoutBounds;
  final ValueChanged<bool> onShowLayoutBoundsChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 190,
            child: FxPopupMenu(
              label: 'Language',
              options: [for (final option in _demoLocaleOptions) option.label],
              selectedValue: _labelForLocale(locale),
              onChanged: (value) {
                final option = _optionForLabel(value);
                if (option != null) {
                  onLocaleChanged(option.locale);
                }
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dark'),
              const SizedBox(width: 8),
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (dark) => onThemeModeChanged(
                  dark ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Touch density'),
              const SizedBox(width: 8),
              Switch(
                value: profile == FxDensityProfile.comfortable,
                onChanged: (touch) => onProfileChanged(
                  touch
                      ? FxDensityProfile.comfortable
                      : FxDensityProfile.desktop,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Show Layout Bounds'),
              const SizedBox(width: 8),
              Switch(
                value: showLayoutBounds,
                onChanged: onShowLayoutBoundsChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoLocaleOption {
  const _DemoLocaleOption({required this.label, required this.locale});

  final String label;
  final Locale locale;
}

String _labelForLocale(Locale locale) {
  return _optionForLocale(locale)?.label ?? _demoLocaleOptions.first.label;
}

_DemoLocaleOption? _optionForLabel(String? label) {
  for (final option in _demoLocaleOptions) {
    if (option.label == label) {
      return option;
    }
  }
  return null;
}

_DemoLocaleOption? _optionForLocale(Locale locale) {
  for (final option in _demoLocaleOptions) {
    if (option.locale.languageCode == locale.languageCode) {
      return option;
    }
  }
  return null;
}

class _StateSample extends StatelessWidget {
  const _StateSample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xffd9dde5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _UndoCommandBar extends StatelessWidget {
  const _UndoCommandBar({required this.controller});

  final FxUndoController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FxButton(
              label: controller.undoLabel == null
                  ? 'Undo'
                  : 'Undo ${controller.undoLabel}',
              icon: Icons.undo,
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            FxButton(
              label: controller.redoLabel == null
                  ? 'Redo'
                  : 'Redo ${controller.redoLabel}',
              icon: Icons.redo,
              onPressed: controller.canRedo ? controller.redo : null,
            ),
            Text(
              'Depth: ${controller.undoDepth} undo / '
              '${controller.redoDepth} redo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _DemoBox extends StatelessWidget {
  const _DemoBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xffeef2ff),
        border: Border.all(color: const Color(0xffc7d2fe)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _NavigationContentPanel extends StatelessWidget {
  const _NavigationContentPanel({
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final String title;
  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        border: Border.all(color: accentColor.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeparatorHorizontalSample extends StatelessWidget {
  const _SeparatorHorizontalSample();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Billing'),
          SizedBox(height: 10),
          FxSeparator(),
          SizedBox(height: 10),
          Text('Delivery'),
        ],
      ),
    );
  }
}

class _SeparatorVerticalSample extends StatelessWidget {
  const _SeparatorVerticalSample();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        children: const [
          Expanded(child: Text('Left pane')),
          SizedBox(width: 12),
          FxSeparator(orientation: FxSeparatorOrientation.vertical),
          SizedBox(width: 12),
          Expanded(child: Text('Right pane')),
        ],
      ),
    );
  }
}
