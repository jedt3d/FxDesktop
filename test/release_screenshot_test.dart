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

  final iconsLoader = FontLoader('MaterialIcons');
  final icons = File('${fontsDir.path}/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    iconsLoader.addFont(
      Future.value(icons.readAsBytesSync().buffer.asByteData()),
    );
  }
  await iconsLoader.load();
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
