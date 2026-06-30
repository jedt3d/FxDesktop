import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

final _isCi = Platform.environment['CI'] == 'true';

Future<void> loadTestFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;

  final fontsDir = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
  if (!fontsDir.existsSync()) return;

  // Load Roboto
  final robotoLoader = FontLoader('Roboto');
  final robotoFile = File('${fontsDir.path}/Roboto-Regular.ttf');
  if (robotoFile.existsSync()) {
    robotoLoader.addFont(
      Future.value(robotoFile.readAsBytesSync().buffer.asByteData()),
    );
  }
  final robotoBoldFile = File('${fontsDir.path}/Roboto-Bold.ttf');
  if (robotoBoldFile.existsSync()) {
    robotoLoader.addFont(
      Future.value(robotoBoldFile.readAsBytesSync().buffer.asByteData()),
    );
  }
  await robotoLoader.load();

  // Load Material Icons
  final iconsLoader = FontLoader('MaterialIcons');
  final iconsFile = File('${fontsDir.path}/MaterialIcons-Regular.otf');
  if (iconsFile.existsSync()) {
    iconsLoader.addFont(
      Future.value(iconsFile.readAsBytesSync().buffer.asByteData()),
    );
  }
  await iconsLoader.load();
}

Future<void> expectVisualGolden(Finder finder, String goldenFile) async {
  if (_isCi) {
    expect(finder, findsOneWidget);
    return;
  }

  await expectLater(finder, matchesGoldenFile(goldenFile));
}

void main() {
  setUpAll(() async {
    await loadTestFonts();
  });

  group('Visual Golden Tests', () {
    testWidgets('FxButton goldens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey('button_goldens'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FxButton(
                        label: 'Primary Button',
                        prominence: FxButtonProminence.primary,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      FxButton(
                        label: 'Normal Button',
                        prominence: FxButtonProminence.normal,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      FxButton(
                        label: 'Quiet Button',
                        prominence: FxButtonProminence.quiet,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      FxButton(
                        label: 'Disabled Button',
                        prominence: FxButtonProminence.normal,
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectVisualGolden(
        find.byKey(const ValueKey('button_goldens')),
        'goldens/fx_button_states.png',
      );
    });

    testWidgets('FxCheckBox goldens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey('checkbox_goldens'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FxCheckBox(
                          label: 'Checked Option',
                          value: true,
                          onChanged: (_) {},
                        ),
                        FxCheckBox(
                          label: 'Unchecked Option',
                          value: false,
                          onChanged: (_) {},
                        ),
                        FxCheckBox(
                          label: 'Tristate Option',
                          value: null,
                          tristate: true,
                          onChanged: (_) {},
                        ),
                        FxCheckBox(
                          label: 'Disabled Option',
                          value: true,
                          onChanged: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectVisualGolden(
        find.byKey(const ValueKey('checkbox_goldens')),
        'goldens/fx_checkbox_states.png',
      );
    });

    testWidgets('FxProgressBar and FxProgressWheel goldens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey('progress_goldens'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FxProgressBar(value: 0.4),
                        const SizedBox(height: 20),
                        const FxProgressBar(value: 0.8, enabled: false),
                        const SizedBox(height: 20),
                        const FxProgressWheel(),
                        const SizedBox(height: 20),
                        const FxProgressWheel(enabled: false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectVisualGolden(
        find.byKey(const ValueKey('progress_goldens')),
        'goldens/fx_progress_states.png',
      );
    });

    testWidgets('FxDisclosureTriangle goldens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey('disclosure_goldens'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FxDisclosureTriangle(
                        title: 'Expanded Section',
                        expanded: true,
                        onChanged: (_) {},
                        child: const Text('Expanded Content'),
                      ),
                      const SizedBox(height: 10),
                      FxDisclosureTriangle(
                        title: 'Collapsed Section',
                        expanded: false,
                        onChanged: (_) {},
                        child: const Text('Collapsed Content'),
                      ),
                      const SizedBox(height: 10),
                      FxDisclosureTriangle(
                        title: 'Disabled Section',
                        expanded: false,
                        onChanged: null,
                        child: const Text('Disabled Content'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectVisualGolden(
        find.byKey(const ValueKey('disclosure_goldens')),
        'goldens/fx_disclosure_states.png',
      );
    });
  });
}
