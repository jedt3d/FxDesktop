import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxUndoController', () {
    test('commits, undoes, redoes, and reports labels', () {
      final controller = FxUndoController();
      var value = 'draft';

      final committed = controller.commitValue<String>(
        'Change status',
        oldValue: value,
        newValue: 'approved',
        apply: (nextValue) => value = nextValue,
      );

      expect(committed, isTrue);
      expect(value, 'approved');
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
      expect(controller.undoLabel, 'Change status');

      controller.undo();
      expect(value, 'draft');
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isTrue);
      expect(controller.redoLabel, 'Change status');

      controller.redo();
      expect(value, 'approved');
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
    });

    test('ignores unchanged values and clears redo after new commit', () {
      final controller = FxUndoController();
      var value = 1;

      expect(
        controller.commitValue<int>(
          'No change',
          oldValue: value,
          newValue: value,
          apply: (nextValue) => value = nextValue,
        ),
        isFalse,
      );
      expect(controller.undoDepth, 0);

      controller.commitValue<int>(
        'Set two',
        oldValue: value,
        newValue: 2,
        apply: (nextValue) => value = nextValue,
      );
      controller.undo();
      expect(controller.canRedo, isTrue);

      controller.commitValue<int>(
        'Set three',
        oldValue: value,
        newValue: 3,
        apply: (nextValue) => value = nextValue,
      );
      expect(value, 3);
      expect(controller.canRedo, isFalse);
      expect(controller.undoLabel, 'Set three');
    });

    test('commits a batch as one undo step', () {
      final controller = FxUndoController();
      var firstName = 'Cindy';
      var lastName = 'Crawford';

      final committed = controller.commitBatch('Update customer', [
        FxUndoAction(
          label: 'Change first name',
          apply: () => firstName = 'Omega',
          revert: () => firstName = 'Cindy',
        ),
        FxUndoAction(
          label: 'Change last name',
          apply: () => lastName = 'SA',
          revert: () => lastName = 'Crawford',
        ),
      ]);

      expect(committed, isTrue);
      expect(firstName, 'Omega');
      expect(lastName, 'SA');
      expect(controller.undoDepth, 1);

      controller.undo();
      expect(firstName, 'Cindy');
      expect(lastName, 'Crawford');
    });

    testWidgets('FxUndoScope exposes a subtree controller', (tester) async {
      final controller = FxUndoController();
      FxUndoController? scopedController;

      await tester.pumpWidget(
        FxUndoScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              scopedController = FxUndoScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(scopedController, same(controller));
    });
  });

  group('component undo integration', () {
    testWidgets('undoes checkbox state changes', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _UndoCheckBoxHarness()));

      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.text('Value: false'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Value: true'), findsOneWidget);
    });

    testWidgets('undoes popup menu selections', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _UndoPopupMenuHarness()));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Closed').last);
      await tester.pumpAndSettle();
      expect(find.text('Status: Closed'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Status: Open'), findsOneWidget);
    });

    testWidgets('undoes radio group selections', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _UndoRadioHarness()));

      await tester.tap(find.text('Phone'));
      await tester.pump();
      expect(find.text('Contact: phone'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Contact: email'), findsOneWidget);
    });

    testWidgets('text field undo records only committed text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _UndoTextFieldHarness()));

      await tester.enterText(find.byType(TextField), 'Omega SA');
      await tester.pump();
      expect(find.text('Commits: 0'), findsOneWidget);

      tester.widget<TextField>(find.byType(TextField)).onSubmitted?.call('');
      await tester.pump();
      expect(find.text('Commits: 1'), findsOneWidget);
      expect(find.text('Customer: Omega SA'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Customer: Cindy Crawford'), findsOneWidget);
    });

    testWidgets('slider undo records drag end as one committed change', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: _UndoSliderHarness()));

      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChangeStart?.call(40);
      slider.onChanged?.call(80);
      slider.onChangeEnd?.call(80);
      await tester.pump();

      expect(find.text('Priority: 80'), findsOneWidget);
      expect(find.text('Undo Change priority'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Priority: 40'), findsOneWidget);
    });

    testWidgets('undoes tab, page, and card index changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: _UndoNavigationHarness()),
      );

      await tester.tap(find.text('History'));
      await tester.pump();
      expect(find.text('Tab: 2'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Tab: 0'), findsOneWidget);

      await tester.tap(find.text('Page Two'));
      await tester.pump();
      expect(find.text('Page: 1'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Page: 0'), findsOneWidget);

      await tester.tap(find.text('Card Two'));
      await tester.pump();
      expect(find.text('Card: 1'), findsOneWidget);

      await _tapUndo(tester);
      await tester.pump();
      expect(find.text('Card: 0'), findsOneWidget);
    });

    testWidgets('color picker calls onCommit only for changed colors', (
      tester,
    ) async {
      Color? committedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FxColorPicker(
              label: 'Accent',
              value: const Color(0xff111111),
              onChanged: (_) {},
              onCommit: (value) => committedColor = value,
              picker: (_, _) async => const Color(0xff22cc88),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(committedColor, const Color(0xff22cc88));
    });
  });
}

Future<void> _tapUndo(WidgetTester tester) async {
  await tester.tap(find.textContaining('Undo').last);
}

class _UndoButton extends StatelessWidget {
  const _UndoButton(this.controller);

  final FxUndoController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return TextButton(
          onPressed: controller.canUndo ? controller.undo : null,
          child: Text(
            controller.undoLabel == null
                ? 'Undo'
                : 'Undo ${controller.undoLabel}',
          ),
        );
      },
    );
  }
}

class _UndoCheckBoxHarness extends StatefulWidget {
  const _UndoCheckBoxHarness();

  @override
  State<_UndoCheckBoxHarness> createState() => _UndoCheckBoxHarnessState();
}

class _UndoCheckBoxHarnessState extends State<_UndoCheckBoxHarness> {
  final _undo = FxUndoController();
  var _active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FxCheckBox(
            label: 'Active',
            value: _active,
            onChanged: (value) {
              _undo.commitValue<bool>(
                'Change active',
                oldValue: _active,
                newValue: value ?? false,
                apply: (nextValue) => setState(() => _active = nextValue),
              );
            },
          ),
          Text('Value: $_active'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}

class _UndoPopupMenuHarness extends StatefulWidget {
  const _UndoPopupMenuHarness();

  @override
  State<_UndoPopupMenuHarness> createState() => _UndoPopupMenuHarnessState();
}

class _UndoPopupMenuHarnessState extends State<_UndoPopupMenuHarness> {
  final _undo = FxUndoController();
  String? _status = 'Open';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FxPopupMenu(
            label: 'Status',
            selectedValue: _status,
            options: const ['Open', 'Closed'],
            onChanged: (value) {
              _undo.commitValue<String?>(
                'Change status',
                oldValue: _status,
                newValue: value,
                apply: (nextValue) => setState(() => _status = nextValue),
              );
            },
          ),
          Text('Status: $_status'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}

class _UndoRadioHarness extends StatefulWidget {
  const _UndoRadioHarness();

  @override
  State<_UndoRadioHarness> createState() => _UndoRadioHarnessState();
}

class _UndoRadioHarnessState extends State<_UndoRadioHarness> {
  final _undo = FxUndoController();
  var _contact = 'email';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FxRadioGroup<String>(
            value: _contact,
            options: const [
              FxRadioOption(value: 'email', label: 'Email'),
              FxRadioOption(value: 'phone', label: 'Phone'),
            ],
            onChanged: (value) {
              _undo.commitValue<String>(
                'Change contact',
                oldValue: _contact,
                newValue: value,
                apply: (nextValue) => setState(() => _contact = nextValue),
              );
            },
          ),
          Text('Contact: $_contact'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}

class _UndoTextFieldHarness extends StatefulWidget {
  const _UndoTextFieldHarness();

  @override
  State<_UndoTextFieldHarness> createState() => _UndoTextFieldHarnessState();
}

class _UndoTextFieldHarnessState extends State<_UndoTextFieldHarness> {
  final _undo = FxUndoController();
  var _customer = 'Cindy Crawford';
  var _commits = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FxTextField(
            label: 'Customer',
            value: _customer,
            onChanged: (_) {},
            onCommit: (value) {
              _undo.commitValue<String>(
                'Change customer',
                oldValue: _customer,
                newValue: value,
                apply: (nextValue) => setState(() => _customer = nextValue),
              );
              setState(() => _commits += 1);
            },
          ),
          Text('Customer: $_customer'),
          Text('Commits: $_commits'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}

class _UndoSliderHarness extends StatefulWidget {
  const _UndoSliderHarness();

  @override
  State<_UndoSliderHarness> createState() => _UndoSliderHarnessState();
}

class _UndoSliderHarnessState extends State<_UndoSliderHarness> {
  final _undo = FxUndoController();
  var _priority = 40.0;
  var _dragStart = 40.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: 320,
            child: FxSlider(
              value: _priority,
              min: 0,
              max: 100,
              onChangeStart: (value) => _dragStart = value,
              onChanged: (value) => setState(() => _priority = value),
              onChangeEnd: (value) {
                _undo.commitValue<double>(
                  'Change priority',
                  oldValue: _dragStart,
                  newValue: value,
                  apply: (nextValue) => setState(() => _priority = nextValue),
                );
              },
            ),
          ),
          Text('Priority: ${_priority.round()}'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}

class _UndoNavigationHarness extends StatefulWidget {
  const _UndoNavigationHarness();

  @override
  State<_UndoNavigationHarness> createState() => _UndoNavigationHarnessState();
}

class _UndoNavigationHarnessState extends State<_UndoNavigationHarness> {
  final _undo = FxUndoController();
  var _tab = 0;
  var _page = 0;
  var _card = 0;

  void _changeIndex(
    String label,
    int oldValue,
    int newValue,
    void Function(int nextValue) apply,
  ) {
    _undo.commitValue<int>(
      label,
      oldValue: oldValue,
      newValue: newValue,
      apply: (nextValue) => setState(() => apply(nextValue)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FxTabPanel(
            tabs: const ['Summary', 'Details', 'History'],
            selectedIndex: _tab,
            onChanged: (index) => _changeIndex(
              'Change tab',
              _tab,
              index,
              (nextValue) => _tab = nextValue,
            ),
            children: const [
              Text('Summary tab'),
              Text('Details tab'),
              Text('History tab'),
            ],
          ),
          Text('Tab: $_tab'),
          FxSegmentedButton<int>(
            value: _page,
            options: const [
              FxSegmentedOption(value: 0, label: 'Page One'),
              FxSegmentedOption(value: 1, label: 'Page Two'),
            ],
            onChanged: (index) => _changeIndex(
              'Change page',
              _page,
              index,
              (nextValue) => _page = nextValue,
            ),
          ),
          FxPagePanel(
            selectedIndex: _page,
            children: const [Text('First page'), Text('Second page')],
          ),
          Text('Page: $_page'),
          FxSegmentedButton<int>(
            value: _card,
            options: const [
              FxSegmentedOption(value: 0, label: 'Card One'),
              FxSegmentedOption(value: 1, label: 'Card Two'),
            ],
            onChanged: (index) => _changeIndex(
              'Change card',
              _card,
              index,
              (nextValue) => _card = nextValue,
            ),
          ),
          FxCardContainer(
            selectedIndex: _card,
            children: const [Text('First card'), Text('Second card')],
          ),
          Text('Card: $_card'),
          _UndoButton(_undo),
        ],
      ),
    );
  }
}
