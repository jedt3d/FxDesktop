import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  test('FxRibbonLayout lays out standard and contextual tabs', () {
    final definition = FxRibbonSamples.explorer();

    final hiddenContext = FxRibbonLayout.compute(
      definition: definition,
      width: 1280,
      activeTabIndex: 0,
      collapsed: false,
      density: FxRibbonDensity.regular,
      interactionMode: FxRibbonInteractionMode.mouse,
    );
    expect(hiddenContext.tabs.map((tab) => tab.tab.caption), [
      'Home',
      'Share',
      'View',
    ]);
    expect(hiddenContext.groups, hasLength(5));
    expect(hiddenContext.groups.first.items, hasLength(6));

    final visibleContext = FxRibbonLayout.compute(
      definition: definition,
      width: 1280,
      activeTabIndex: 3,
      collapsed: false,
      density: FxRibbonDensity.regular,
      interactionMode: FxRibbonInteractionMode.mouse,
      visibleContextGroups: const {'Picture Tools'},
    );
    expect(visibleContext.tabs.map((tab) => tab.tab.caption), [
      'Home',
      'Share',
      'View',
      'Format',
    ]);
    expect(visibleContext.groups.single.group.caption, 'Picture Styles');
  });

  test(
    'FxRibbonLayout uses collapsed height and skips groups when collapsed',
    () {
      final layout = FxRibbonLayout.compute(
        definition: FxRibbonSamples.explorer(),
        width: 1024,
        activeTabIndex: 0,
        collapsed: true,
        density: FxRibbonDensity.regular,
        interactionMode: FxRibbonInteractionMode.mouse,
      );

      expect(layout.collapsed, isTrue);
      expect(layout.groups, isEmpty);
      expect(layout.size.height, FxRibbonDensity.regular.collapsedHeight);
    },
  );
}
