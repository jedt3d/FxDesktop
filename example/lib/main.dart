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
  final ScrollController scrollController = ScrollController();
  final FxUndoController undoController = FxUndoController();
  String? selectedRowId = 'order-1';
  ({String rowId, String columnId})? selectedCell;
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
        backgroundColor: const Color(0xfff6f7f9),
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
                          Text(
                            'FxDesktop Component Harness',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'One component per row, optimized for desktop visual checks.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
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
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextField(
                                    label: 'Order No',
                                    hintText: 'Required order number',
                                    errorText: 'Order number is required.',
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextField(
                                    label: 'Contract',
                                    value: 'A 589434',
                                    readOnly: true,
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
                                  ),
                                ),
                                _StateSample(
                                  label: 'Validation',
                                  child: FxTextField(
                                    label: 'Order No',
                                    hintText: 'Required order number',
                                    errorText: 'Order number is required.',
                                  ),
                                ),
                                _StateSample(
                                  label: 'Read only',
                                  child: FxTextField(
                                    label: 'Contract',
                                    value: 'A 589434',
                                    readOnly: true,
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
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxTextField(
                                    label: 'Customer',
                                    hintText: 'Disabled field',
                                    enabled: false,
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
                                    minLines: 3,
                                    maxLines: 3,
                                  ),
                                ),
                                _StateSample(
                                  label: 'Disabled',
                                  child: FxTextArea(
                                    label: 'Notes',
                                    hintText: 'Disabled text area',
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
                            child: FxListBox(
                              height: 180,
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
                                  width: 130,
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
                                FxListBoxRow(
                                  id: 'order-3',
                                  cells: {
                                    'number': '1003',
                                    'customer': 'Cindy Crawford',
                                    'status': 'Draft',
                                  },
                                  enabled: false,
                                ),
                              ],
                            ),
                          ),
                          _ComponentRow(
                            name: 'FxGrid',
                            child: FxGrid(
                              height: 180,
                              selectedCell: selectedCell,
                              onCellSelected: (rowId, columnId) {
                                setState(() {
                                  selectedCell = (
                                    rowId: rowId,
                                    columnId: columnId,
                                  );
                                });
                              },
                              columns: const [
                                FxGridColumn(
                                  id: 'field',
                                  caption: 'Field',
                                  width: 140,
                                ),
                                FxGridColumn(
                                  id: 'desktop',
                                  caption: 'Xojo Desktop',
                                  width: 230,
                                ),
                                FxGridColumn(
                                  id: 'web',
                                  caption: 'Xojo Web',
                                  width: 190,
                                ),
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
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final child in children)
          SizedBox(width: sampleWidth, child: child),
      ],
    );
  }
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
