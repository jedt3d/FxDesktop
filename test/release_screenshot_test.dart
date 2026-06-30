import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

enum _Priority { normal, urgent, critical }

final bool _isCi = Platform.environment['CI'] == 'true';

Future<void> _loadReleaseScreenshotFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;

  final fontsDir = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
  if (!fontsDir.existsSync()) return;

  final robotoLoader = FontLoader('Roboto');
  final robotoRegular = File('${fontsDir.path}/Roboto-Regular.ttf');
  final robotoBold = File('${fontsDir.path}/Roboto-Bold.ttf');
  if (robotoRegular.existsSync()) {
    robotoLoader.addFont(
      Future.value(robotoRegular.readAsBytesSync().buffer.asByteData()),
    );
  }
  if (robotoBold.existsSync()) {
    robotoLoader.addFont(
      Future.value(robotoBold.readAsBytesSync().buffer.asByteData()),
    );
  }
  await robotoLoader.load();

  await _loadFontFamily(
    'FxScreenshotJapanese',
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
  );
  await _loadFontFamily(
    'FxScreenshotThai',
    '/System/Library/Fonts/Supplemental/Ayuthaya.ttf',
  );
  await _loadFontFamily(
    'FxScreenshotNepali',
    '/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc',
  );

  final iconsLoader = FontLoader('MaterialIcons');
  final icons = File('${fontsDir.path}/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    iconsLoader.addFont(
      Future.value(icons.readAsBytesSync().buffer.asByteData()),
    );
  }
  await iconsLoader.load();
}

Future<void> _loadFontFamily(String family, String path) async {
  final file = File(path);
  if (!file.existsSync()) return;
  final loader = FontLoader(family)
    ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadReleaseScreenshotFonts();
  });

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1200, 760);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('v0.3.6 lookup renderers release screenshot', (tester) async {
    const rootKey = ValueKey('v036_lookup_renderers');

    await tester.pumpWidget(
      _ReleaseScreenshotShell(
        boundaryKey: rootKey,
        title: 'FxDesktop v0.3.6 - Lookup Fields & Custom Rendering',
        subtitle:
            'Custom cell renderers, map/enum lookup labels, hosted editor-ready columns, and undo-safe table state.',
        child: _LookupRendererPanel(),
      ),
    );
    await tester.pumpAndSettle();

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.3.6/fxdesktop-v0.3.6-lookup-renderers.png',
    );
  });

  testWidgets('v0.3.6 database lookup overlay release screenshot', (
    tester,
  ) async {
    const rootKey = ValueKey('v036_db_lookup_overlay');

    await tester.pumpWidget(
      _ReleaseScreenshotShell(
        boundaryKey: rootKey,
        title: 'FxDesktop v0.3.6 - Multi-Column Lookup Overlay',
        subtitle:
            'Hosted `FxDbLookupProvider` editor showing code, vendor name, and rating columns above the virtualized table.',
        child: _AdvancedEditorsPanel(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Globex Industries').first);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('Globex Industries').first);
    await tester.pumpAndSettle();

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.3.6/fxdesktop-v0.3.6-db-lookup-overlay.png',
    );
  });

  testWidgets('v0.3.6 masked action editor release screenshot', (tester) async {
    const rootKey = ValueKey('v036_masked_action_editor');

    await tester.pumpWidget(
      _ReleaseScreenshotShell(
        boundaryKey: rootKey,
        title: 'FxDesktop v0.3.6 - Masked Fields & Cell Actions',
        subtitle:
            'Phone and SSN masks plus an attachment column with an ellipsis action button inside the active editor.',
        child: _AdvancedEditorsPanel(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('invoice_v01.pdf').first);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('invoice_v01.pdf').first);
    await tester.pumpAndSettle();

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.3.6/fxdesktop-v0.3.6-masked-action-editor.png',
    );
  });

  for (final scenario in const [
    _LocalizationScreenshotScenario(
      name: 'English',
      fileSuffix: 'en',
      locale: Locale('en'),
    ),
    _LocalizationScreenshotScenario(
      name: 'Thai',
      fileSuffix: 'th',
      locale: Locale('th'),
      fontFamily: 'FxScreenshotThai',
    ),
    _LocalizationScreenshotScenario(
      name: 'Japanese',
      fileSuffix: 'ja',
      locale: Locale('ja'),
      fontFamily: 'FxScreenshotJapanese',
    ),
    _LocalizationScreenshotScenario(
      name: 'Nepali',
      fileSuffix: 'ne',
      locale: Locale('ne'),
      fontFamily: 'FxScreenshotNepali',
    ),
    _LocalizationScreenshotScenario(
      name: 'RTL smoke',
      fileSuffix: 'rtl-smoke',
      locale: Locale('en'),
      direction: TextDirection.rtl,
    ),
  ]) {
    testWidgets('v0.4.0 localization gallery ${scenario.name}', (tester) async {
      _setReleaseScreenshotSurface(const Size(1360, 1080));

      final rootKey = ValueKey('v040_localization_${scenario.fileSuffix}');
      await tester.pumpWidget(
        _LocalizationScreenshotShell(boundaryKey: rootKey, scenario: scenario),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      await _expectReleaseScreenshot(
        tester,
        boundaryKey: rootKey,
        goldenPath:
            '../doc/screenshots/v0.4.0/localization/fxdesktop-localized-${scenario.fileSuffix}.png',
      );
    });
  }

  testWidgets('v0.5.1 ribbon toolbar Explorer presentation', (tester) async {
    _setReleaseScreenshotSurface(const Size(1280, 620));

    const rootKey = ValueKey('v051_ribbon_toolbar_explorer');
    await tester.pumpWidget(
      const _RibbonExplorerPresentationShell(boundaryKey: rootKey),
    );
    await tester.pumpAndSettle();

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-explorer.png',
    );
  });

  for (final tab in const [
    _RibbonTabScreenshot('home', 0),
    _RibbonTabScreenshot('share', 1),
    _RibbonTabScreenshot('view', 2),
  ]) {
    testWidgets('v0.5.1 ribbon toolbar ${tab.name} tab', (tester) async {
      _setReleaseScreenshotSurface(const Size(1280, 180));

      final rootKey = ValueKey('v051_ribbon_toolbar_${tab.name}');
      await tester.pumpWidget(
        _RibbonExplorerSingleShell(
          boundaryKey: rootKey,
          activeTabIndex: tab.activeTabIndex,
        ),
      );
      await tester.pumpAndSettle();

      await _expectReleaseScreenshot(
        tester,
        boundaryKey: rootKey,
        goldenPath:
            '../doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-${tab.name}.png',
      );
    });
  }

  testWidgets('v0.5.1 ribbon toolbar dropdown menu screenshot', (tester) async {
    _setReleaseScreenshotSurface(const Size(1280, 360));

    const rootKey = ValueKey('v051_ribbon_toolbar_menu');
    await tester.pumpWidget(
      const _RibbonExplorerSingleShell(boundaryKey: rootKey, activeTabIndex: 2),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-menu-en.png',
    );
  });

  testWidgets('v0.5.1 ribbon designer release screenshot', (tester) async {
    _setReleaseScreenshotSurface(const Size(1360, 920));

    const rootKey = ValueKey('v051_ribbon_designer_ja');
    await tester.pumpWidget(
      _RibbonDesignerScreenshotShell(
        boundaryKey: rootKey,
        locale: const Locale('ja'),
        fontFamily: 'FxScreenshotJapanese',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await _expectReleaseScreenshot(
      tester,
      boundaryKey: rootKey,
      goldenPath:
          '../doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-designer-ja.png',
    );
  });
}

void _setReleaseScreenshotSurface(Size size) {
  final view =
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
  view.physicalSize = size;
  view.devicePixelRatio = 1.0;
}

Future<void> _expectReleaseScreenshot(
  WidgetTester tester, {
  required Key boundaryKey,
  required String goldenPath,
}) async {
  expect(find.byKey(boundaryKey), findsOneWidget);
  if (_isCi) {
    return;
  }
  await expectLater(find.byKey(boundaryKey), matchesGoldenFile(goldenPath));
}

class _ReleaseScreenshotShell extends StatelessWidget {
  const _ReleaseScreenshotShell({
    required this.boundaryKey,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Key boundaryKey;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xff2563eb);
    return RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xfff6f7f9),
          extensions: const [
            FxTheme(
              gridLineColor: Color(0xffcbd5e1),
              headerBackground: Color(0xffe8eef8),
              alternatingRowBackground: Color(0xfff8fafc),
              selectionBackground: Color(0xffdbeafe),
            ),
          ],
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1120,
              height: 680,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff0f172a),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 900,
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Color(0xff475569),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalizationScreenshotScenario {
  const _LocalizationScreenshotScenario({
    required this.name,
    required this.fileSuffix,
    required this.locale,
    this.direction = TextDirection.ltr,
    this.fontFamily = 'Roboto',
  });

  final String name;
  final String fileSuffix;
  final Locale locale;
  final TextDirection direction;
  final String fontFamily;
}

class _LocalizationScreenshotShell extends StatelessWidget {
  const _LocalizationScreenshotShell({
    required this.boundaryKey,
    required this.scenario,
  });

  final Key boundaryKey;
  final _LocalizationScreenshotScenario scenario;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xff2563eb);
    return RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          fontFamily: scenario.fontFamily,
          scaffoldBackgroundColor: const Color(0xfff6f7f9),
          extensions: const [
            FxTheme(
              gridLineColor: Color(0xffcbd5e1),
              headerBackground: Color(0xffe8eef8),
              alternatingRowBackground: Color(0xfff8fafc),
              selectionBackground: Color(0xffdbeafe),
            ),
          ],
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1280,
              height: 1020,
              child: Directionality(
                textDirection: scenario.direction,
                child: FxLocalizationGallery(initialLocale: scenario.locale),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonTabScreenshot {
  const _RibbonTabScreenshot(this.name, this.activeTabIndex);

  final String name;
  final int activeTabIndex;
}

class _RibbonExplorerPresentationShell extends StatelessWidget {
  const _RibbonExplorerPresentationShell({required this.boundaryKey});

  final Key boundaryKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: _RibbonMaterialApp(
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1200,
              height: 420,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _RibbonToolbarFrame(activeTabIndex: 0),
                  SizedBox(height: 16),
                  _RibbonToolbarFrame(activeTabIndex: 1),
                  SizedBox(height: 16),
                  _RibbonToolbarFrame(activeTabIndex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonExplorerSingleShell extends StatelessWidget {
  const _RibbonExplorerSingleShell({
    required this.boundaryKey,
    required this.activeTabIndex,
  });

  final Key boundaryKey;
  final int activeTabIndex;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: _RibbonMaterialApp(
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1200,
              height: 118,
              child: _RibbonToolbarFrame(activeTabIndex: activeTabIndex),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonToolbarFrame extends StatelessWidget {
  const _RibbonToolbarFrame({required this.activeTabIndex});

  final int activeTabIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffd6d6d6)),
      ),
      child: FxRibbonToolbar(
        definition: FxRibbonSamples.explorer(),
        activeTabIndex: activeTabIndex,
        interactionMode: FxRibbonInteractionMode.mouse,
      ),
    );
  }
}

class _RibbonMaterialApp extends StatelessWidget {
  const _RibbonMaterialApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xff0078d7);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
      supportedLocales: FxDesktopLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
        extensions: const [
          FxTheme(
            gridLineColor: Color(0xffcbd5e1),
            headerBackground: Color(0xffe8eef8),
            alternatingRowBackground: Color(0xfff8fafc),
            selectionBackground: Color(0xffdbeafe),
          ),
          FxRibbonThemeData(
            density: FxRibbonDensity.regular,
            backgroundColor: Color(0xfff7f7f7),
            tabStripColor: Color(0xffffffff),
            activeTabColor: Color(0xffffffff),
            groupBackgroundColor: Color(0xfff7f7f7),
            hoverColor: Color(0xffdbeafe),
            pressedColor: Color(0xffcfe8ff),
            keyTipBackgroundColor: Color(0xff111827),
            keyTipForegroundColor: Colors.white,
          ),
        ],
      ),
      home: child,
    );
  }
}

class _RibbonDesignerScreenshotShell extends StatelessWidget {
  const _RibbonDesignerScreenshotShell({
    required this.boundaryKey,
    required this.locale,
    required this.fontFamily,
  });

  final Key boundaryKey;
  final Locale locale;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xff2563eb);
    return RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
        supportedLocales: FxDesktopLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          fontFamily: fontFamily,
          scaffoldBackgroundColor: const Color(0xfff6f7f9),
          extensions: const [
            FxTheme(
              gridLineColor: Color(0xffcbd5e1),
              headerBackground: Color(0xffe8eef8),
              alternatingRowBackground: Color(0xfff8fafc),
              selectionBackground: Color(0xffdbeafe),
            ),
            FxRibbonThemeData(
              density: FxRibbonDensity.compact,
              backgroundColor: Color(0xfffbfdff),
              tabStripColor: Color(0xffeef4fb),
              activeTabColor: Colors.white,
              groupBackgroundColor: Color(0xffffffff),
            ),
          ],
        ),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 1280,
              height: 860,
              child: FxRibbonDesigner(locale: Locale('ja')),
            ),
          ),
        ),
      ),
    );
  }
}

class _LookupRendererPanel extends StatelessWidget {
  const _LookupRendererPanel();

  final FxMapLookupProvider<int> _categoryProvider =
      const FxMapLookupProvider<int>({
        1: 'Electronics',
        2: 'Apparel',
        3: 'Home & Kitchen',
      });

  final FxEnumLookupProvider<_Priority> _priorityProvider =
      const FxEnumLookupProvider<_Priority>(
        values: _Priority.values,
        labels: {
          _Priority.normal: 'Normal Priority',
          _Priority.urgent: 'Urgent Priority',
          _Priority.critical: 'Critical Priority',
        },
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffd9e2ef)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FxListBox(
          height: 460,
          selectionMode: FxListBoxSelectionMode.single,
          selectedRowIds: const {'order-2'},
          columns: [
            const FxListBoxColumn(
              id: 'order',
              caption: 'Order',
              width: FxColumnWidth.fixed(92),
            ),
            FxListBoxColumn(
              id: 'category',
              caption: 'Category',
              editable: true,
              width: const FxColumnWidth.fixed(190),
              type: FxCellType.lookup(_categoryProvider),
            ),
            FxListBoxColumn(
              id: 'priority',
              caption: 'Priority',
              editable: true,
              width: const FxColumnWidth.fixed(190),
              type: FxCellType.lookup(_priorityProvider),
            ),
            FxListBoxColumn(
              id: 'trend',
              caption: 'Sales Trend',
              width: const FxColumnWidth.fixed(250),
              cellRenderer:
                  (context, rowId, columnId, value, isSelected, isHovered) {
                    final values = (value as List<num>)
                        .map((entry) => entry.toDouble())
                        .toList();
                    return RepaintBoundary(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            height: 30,
                            child: CustomPaint(
                              painter: _SparklinePainter(values),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${((values.last - values.first) / values.first * 100).round()}%',
                            style: TextStyle(
                              color: values.last >= values.first
                                  ? const Color(0xff047857)
                                  : const Color(0xffbe123c),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
            const FxListBoxColumn(
              id: 'status',
              caption: 'Status',
              width: FxColumnWidth.fixed(160),
            ),
          ],
          rows: const [
            FxListBoxRow(
              id: 'order-1',
              cells: {
                'order': '1001',
                'category': 1,
                'priority': _Priority.normal,
                'trend': [18, 24, 21, 29, 37],
                'status': 'Ready',
              },
            ),
            FxListBoxRow(
              id: 'order-2',
              cells: {
                'order': '1002',
                'category': 2,
                'priority': _Priority.urgent,
                'trend': [42, 39, 48, 53, 61],
                'status': 'Review',
              },
            ),
            FxListBoxRow(
              id: 'order-3',
              cells: {
                'order': '1003',
                'category': 3,
                'priority': _Priority.critical,
                'trend': [64, 55, 52, 47, 44],
                'status': 'Blocked',
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedEditorsPanel extends StatelessWidget {
  const _AdvancedEditorsPanel();

  final FxDbLookupProvider<String> _vendorProvider =
      const FxDbLookupProvider<String>(
        headers: ['Code', 'Vendor Name', 'Rating'],
        recordMap: {
          'V1': ['V1', 'Acme Medical', 'A'],
          'V2': ['V2', 'Globex Industries', 'A+'],
          'V3': ['V3', 'Initech Supplies', 'B'],
          'V4': ['V4', 'Umbrella Logistics', 'A-'],
        },
        displayColumnIndex: 1,
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffd9e2ef)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FxGrid(
          height: 460,
          selectionMode: FxGridSelectionMode.cell,
          selectedCells: const {(rowId: 'vendor-2', columnId: 'vendor')},
          columns: [
            const FxGridColumn(
              id: 'sku',
              caption: 'SKU',
              width: FxColumnWidth.fixed(92),
            ),
            FxGridColumn(
              id: 'vendor',
              caption: 'Vendor',
              editable: true,
              width: const FxColumnWidth.fixed(230),
              type: FxCellType.lookup(_vendorProvider),
            ),
            const FxGridColumn(
              id: 'phone',
              caption: 'Phone',
              editable: true,
              width: FxColumnWidth.fixed(170),
              inputMask: '(###) ###-####',
            ),
            const FxGridColumn(
              id: 'ssn',
              caption: 'SSN',
              editable: true,
              width: FxColumnWidth.fixed(140),
              inputMask: '###-##-####',
            ),
            FxGridColumn(
              id: 'attachment',
              caption: 'Attachment',
              editable: true,
              width: const FxColumnWidth.fixed(220),
              hasActionButton: true,
              actionIcon: Icons.more_horiz,
              onActionPressed: (_, _, _) {},
            ),
          ],
          rows: const [
            FxGridRow(
              id: 'vendor-1',
              cells: {
                'sku': 'A-100',
                'vendor': 'V1',
                'phone': '(555) 123-4567',
                'ssn': '123-45-6789',
                'attachment': 'invoice_v01.pdf',
              },
            ),
            FxGridRow(
              id: 'vendor-2',
              cells: {
                'sku': 'B-200',
                'vendor': 'V2',
                'phone': '(555) 867-5309',
                'ssn': '987-65-4321',
                'attachment': 'contract_final.docx',
              },
            ),
            FxGridRow(
              id: 'vendor-3',
              cells: {
                'sku': 'C-300',
                'vendor': 'V3',
                'phone': '(555) 222-0101',
                'ssn': '456-78-9012',
                'attachment': 'receipt.png',
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minValue) / span * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final gridPaint = Paint()
      ..color = const Color(0xffe2e8f0)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xff2563eb)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
