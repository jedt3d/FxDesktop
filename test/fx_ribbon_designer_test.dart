import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  testWidgets('FxRibbonDesigner localizes chrome and previews ribbon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: const Scaffold(body: FxRibbonDesigner()),
      ),
    );

    expect(find.text('リボンデザイナー'), findsOneWidget);
    expect(find.text('構造'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
  });

  testWidgets('FxRibbonDesigner adds a tab and emits model changes', (
    tester,
  ) async {
    FxRibbonDefinition? changed;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonDesigner(
            onDefinitionChanged: (value) => changed = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add tab'));
    await tester.pump();

    expect(changed?.tabs.last.caption, 'New tab');
    expect(find.text('New tab'), findsWidgets);
  });

  testWidgets('FxRibbonDesigner export returns current JSON', (tester) async {
    String? exported;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonDesigner(
            onExportRequested: (value) => exported = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Export JSON'));
    await tester.pump();

    expect(exported, contains('"version": "1.0"'));
    expect(exported, contains('"tabs"'));
    expect(find.text('Ribbon JSON exported.'), findsOneWidget);
  });

  testWidgets('FxRibbonDesigner edits selection and localized captions', (
    tester,
  ) async {
    FxRibbonDefinition? changed;
    FxRibbonSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonDesigner(
            onDefinitionChanged: (value) => changed = value,
            onSelectionChanged: (value) => selection = value,
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Clipboard'));
    await tester.pump();
    expect(selection?.groupIndex, 0);

    await tester.enterText(find.byType(TextField).first, 'Clip actions');
    await tester.pump();
    expect(changed?.tabs.first.groups.first.caption, 'Clip actions');

    await tester.enterText(find.byType(TextField).at(1), 'คลิป');
    await tester.pump();
    expect(changed?.tabs.first.groups.first.localizedCaptions['th'], 'คลิป');

    await tester.tap(find.widgetWithText(ListTile, 'Paste'));
    await tester.pump();
    expect(selection?.itemIndex, 0);

    await tester.enterText(find.byType(TextField).first, 'Paste all');
    await tester.enterText(find.byType(TextField).at(1), 'clipboard.pasteAll');
    await tester.enterText(find.byType(TextField).at(2), 'Paste everything');
    await tester.enterText(find.byType(TextField).at(3), 'paste');
    await tester.pump();

    final item = changed?.findItem('clipboard.pasteAll');
    expect(item?.caption, 'Paste all');
    expect(item?.tooltipText, 'Paste everything');
    expect(item?.iconKey, 'paste');
  });

  testWidgets(
    'FxRibbonDesigner adds item, switches locale, deletes, and resets',
    (tester) async {
      FxRibbonDefinition? changed;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: Scaffold(
            body: FxRibbonDesigner(
              onDefinitionChanged: (value) => changed = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add group'));
      await tester.pump();
      expect(changed?.tabs.first.groups.last.caption, 'New group');

      await tester.tap(find.text('Add item'));
      await tester.pump();
      expect(changed?.findItem('new')?.caption, 'New');

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thai').last);
      await tester.pumpAndSettle();
      expect(find.text('หน้าหลัก'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      expect(changed?.findItem('new'), isNull);

      await tester.tap(find.byIcon(Icons.note_add_outlined).first);
      await tester.pump();
      expect(changed?.tabs.single.caption, 'Home');
    },
  );

  testWidgets(
    'FxRibbonDesigner responds to updated initial definition and locale',
    (tester) async {
      final first = FxRibbonDefinition(
        tabs: [
          FxRibbonTab(
            caption: 'One',
            localizedCaptions: const {'ja': '一'},
            groups: const [],
          ),
        ],
      );
      final second = FxRibbonDefinition(
        tabs: [
          FxRibbonTab(
            caption: 'Two',
            localizedCaptions: const {'th': 'สอง'},
            groups: const [],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: Scaffold(
            body: FxRibbonDesigner(
              initialDefinition: first,
              locale: const Locale('ja'),
            ),
          ),
        ),
      );
      expect(find.text('一'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: Scaffold(
            body: FxRibbonDesigner(
              initialDefinition: second,
              locale: const Locale('th'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('สอง'), findsWidgets);
      expect(find.text('One'), findsNothing);
    },
  );
}
