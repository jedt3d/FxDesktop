import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  testWidgets('FxRibbonToolbar renders localized captions and stable events', (
    tester,
  ) async {
    final events = <FxRibbonEvent>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        locale: const Locale('th'),
        home: Scaffold(
          body: FxRibbonToolbar(
            definition: FxRibbonSamples.explorer(),
            onEvent: events.add,
          ),
        ),
      ),
    );

    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('คัดลอก'), findsOneWidget);

    await tester.tap(find.text('คัดลอก'));
    await tester.pump();

    expect(
      events.whereType<FxRibbonItemPressedEvent>().single.itemTag,
      'clipboard.copy',
    );
  });

  testWidgets('FxRibbonToolbar toggles command state internally', (
    tester,
  ) async {
    FxRibbonDefinition? changed;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonToolbar(
            definition: FxRibbonSamples.explorer(),
            activeTabIndex: 1,
            onDefinitionChanged: (definition) => changed = definition,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Preview pane'));
    await tester.pump();

    expect(changed?.findItem('view.preview')?.isToggleActive, isTrue);
  });

  testWidgets('FxRibbonToolbar collapse button emits collapse event', (
    tester,
  ) async {
    final events = <FxRibbonEvent>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonToolbar(
            definition: FxRibbonSamples.explorer(),
            onEvent: events.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Collapse ribbon'));
    await tester.pump();

    expect(
      events.whereType<FxRibbonCollapseChangedEvent>().single.collapsed,
      isTrue,
    );
  });

  testWidgets(
    'FxRibbonToolbar handles empty definitions and out-of-range tabs',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: Scaffold(
            body: FxRibbonToolbar(
              definition: FxRibbonDefinition(tabs: []),
              activeTabIndex: 99,
            ),
          ),
        ),
      );

      expect(find.text('No ribbon tabs'), findsOneWidget);
    },
  );

  testWidgets('FxRibbonToolbar emits dropdown and split menu actions', (
    tester,
  ) async {
    final events = <FxRibbonEvent>[];
    final definition = FxRibbonDefinition(
      tabs: [
        FxRibbonTab(
          caption: 'Home',
          groups: [
            FxRibbonGroup(
              caption: 'Menus',
              items: [
                FxRibbonItem.dropdown(
                  caption: 'Open',
                  tag: 'file.open',
                  menuItems: const [
                    FxRibbonMenuItem(
                      caption: 'Recent',
                      tag: 'file.open.recent',
                    ),
                  ],
                ),
                FxRibbonItem.splitButton(
                  caption: 'Delete',
                  tag: 'edit.delete',
                  menuItems: const [
                    FxRibbonMenuItem(
                      caption: 'Delete permanently',
                      tag: 'edit.delete.permanent',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        home: Scaffold(
          body: FxRibbonToolbar(definition: definition, onEvent: events.add),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(
      events.whereType<FxRibbonMenuActionEvent>().last.menuItemTag,
      'file.open.recent',
    );

    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(
      events.whereType<FxRibbonItemPressedEvent>().last.itemTag,
      'edit.delete',
    );

    await tester.tap(find.byIcon(Icons.arrow_drop_down).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(
      events.whereType<FxRibbonMenuActionEvent>().last.menuItemTag,
      'edit.delete.permanent',
    );
  });

  testWidgets(
    'FxRibbonToolbar supports touch mode sizing and contextual tabs',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: Scaffold(
            body: FxRibbonToolbar(
              definition: FxRibbonSamples.explorer(),
              interactionMode: FxRibbonInteractionMode.touch,
              visibleContextGroups: const {'Picture Tools'},
              activeTabIndex: 2,
            ),
          ),
        ),
      );

      expect(find.text('Format'), findsOneWidget);
      expect(tester.getSize(find.byType(FxRibbonToolbar)).height, 240);
    },
  );
}
