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
  String? selectedRowId = 'order-1';
  ({String rowId, String columnId})? selectedCell;
  bool active = true;
  bool inactive = false;
  bool? optional;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                label: 'Enabled',
                                child: FxTextField(
                                  label: 'Customer',
                                  hintText: 'Company or person name',
                                  helpText:
                                      'Comparable to DesktopTextField/WebTextField.',
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
                                label: 'Enabled',
                                child: FxTextArea(
                                  label: 'Notes',
                                  hintText: 'Enter multiple lines',
                                  minLines: 3,
                                  maxLines: 4,
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
                                const FxGridArea(
                                  'field',
                                ).containing(FxTextField(label: 'Grid field')),
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
