import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/src/fx_navigation_containers.dart';

void main() {
  group('FxTabPanel', () {
    testWidgets('renders visible tabs and selected content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxTabPanel(
              tabs: ['Summary', 'Details', 'History'],
              selectedIndex: 1,
              children: [
                Text('Summary content'),
                Text('Details content'),
                Text('History content'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Summary content'), findsNothing);
      expect(find.text('Details content'), findsOneWidget);
      expect(find.text('History content'), findsNothing);
    });

    testWidgets('reports tapped tab index', (tester) async {
      int? changedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxTabPanel(
              tabs: const ['Summary', 'Details', 'History'],
              selectedIndex: 0,
              onChanged: (index) => changedIndex = index,
              children: const [
                Text('Summary content'),
                Text('Details content'),
                Text('History content'),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('History'));
      expect(changedIndex, 2);
    });

    test('exposes DesktopTabPanel template metadata', () {
      expect(
        const FxTabPanel(
          tabs: ['Summary', 'Details'],
          selectedIndex: 0,
          children: [Text('Summary'), Text('Details')],
        ).toTemplateMap(),
        {
          'component': 'FxTabPanel',
          'xojo_desktop_class': 'DesktopTabPanel',
          'selectedIndex': 0,
          'tabCount': 2,
        },
      );
    });
  });

  group('FxPagePanel', () {
    testWidgets('renders selected indexed page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxPagePanel(
              selectedIndex: 2,
              children: [
                Text('Summary page'),
                Text('Details page'),
                Text('History page'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Summary page'), findsNothing);
      expect(find.text('Details page'), findsNothing);
      expect(find.text('History page'), findsOneWidget);
    });

    testWidgets('preserves page state when switching selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SwitchingHarness(
              labels: const ['Notes', 'Audit'],
              builder: (selectedIndex) {
                return FxPagePanel(
                  selectedIndex: selectedIndex,
                  children: const [
                    _CounterPage(name: 'Notes'),
                    _CounterPage(name: 'Audit'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Increment Notes'));
      await tester.pump();
      expect(find.text('Notes count 1'), findsOneWidget);

      await tester.tap(find.text('Show Audit'));
      await tester.pump();
      expect(find.text('Audit count 0'), findsOneWidget);

      await tester.tap(find.text('Show Notes'));
      await tester.pump();
      expect(find.text('Notes count 1'), findsOneWidget);
    });

    test('exposes DesktopPagePanel template metadata', () {
      expect(
        const FxPagePanel(
          selectedIndex: 1,
          children: [Text('Summary'), Text('Details')],
        ).toTemplateMap(),
        {
          'component': 'FxPagePanel',
          'xojo_desktop_class': 'DesktopPagePanel',
          'selectedIndex': 1,
          'pageCount': 2,
        },
      );
    });
  });

  group('FxCardContainer', () {
    testWidgets('renders selected indexed card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FxCardContainer(
              selectedIndex: 1,
              children: [
                Text('Summary card'),
                Text('Details card'),
                Text('History card'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Summary card'), findsNothing);
      expect(find.text('Details card'), findsOneWidget);
      expect(find.text('History card'), findsNothing);
    });

    testWidgets('preserves card state when switching selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SwitchingHarness(
              labels: const ['Summary', 'Audit'],
              builder: (selectedIndex) {
                return FxCardContainer(
                  selectedIndex: selectedIndex,
                  children: const [
                    _CounterPage(name: 'Summary'),
                    _CounterPage(name: 'Audit'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Increment Summary'));
      await tester.pump();
      expect(find.text('Summary count 1'), findsOneWidget);

      await tester.tap(find.text('Show Audit'));
      await tester.pump();
      expect(find.text('Audit count 0'), findsOneWidget);

      await tester.tap(find.text('Show Summary'));
      await tester.pump();
      expect(find.text('Summary count 1'), findsOneWidget);
    });

    test('exposes card container template metadata', () {
      expect(
        const FxCardContainer(
          selectedIndex: 0,
          children: [Text('Summary'), Text('Details')],
        ).toTemplateMap(),
        {
          'component': 'FxCardContainer',
          'xojo_desktop_class': 'DesktopPagePanel',
          'selectedIndex': 0,
          'cardCount': 2,
        },
      );
    });
  });
}

class _SwitchingHarness extends StatefulWidget {
  const _SwitchingHarness({required this.labels, required this.builder});

  final List<String> labels;
  final Widget Function(int selectedIndex) builder;

  @override
  State<_SwitchingHarness> createState() => _SwitchingHarnessState();
}

class _SwitchingHarnessState extends State<_SwitchingHarness> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < widget.labels.length; index++)
              TextButton(
                onPressed: () => setState(() => _selectedIndex = index),
                child: Text('Show ${widget.labels[index]}'),
              ),
          ],
        ),
        widget.builder(_selectedIndex),
      ],
    );
  }
}

class _CounterPage extends StatefulWidget {
  const _CounterPage({required this.name});

  final String name;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${widget.name} count $_count'),
        TextButton(
          onPressed: () => setState(() => _count += 1),
          child: Text('Increment ${widget.name}'),
        ),
      ],
    );
  }
}
