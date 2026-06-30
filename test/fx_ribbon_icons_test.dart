import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  test('FxRibbonIconRegistry merges entries and reports diagnostics', () {
    final first = FxRibbonIconRegistry(
      entries: const {
        'copy': FxRibbonIconSource.material(Icons.copy),
        'paste': FxRibbonIconSource.svgString(_svg),
      },
    );
    final second = FxRibbonIconRegistry(
      entries: {
        'paste': FxRibbonIconSource.pngBytes(_pngBytes),
        'delete': const FxRibbonIconSource.material(Icons.delete),
      },
    );

    final merged = first.merge(second);

    expect(merged.length, 3);
    expect(merged['copy']?.kind, FxRibbonIconKind.materialIcon);
    expect(merged['paste']?.kind, FxRibbonIconKind.pngBytes);
    expect(merged.toTemplateMap(), {
      'keys': ['copy', 'delete', 'paste'],
      'length': 3,
    });
  });

  test('FxRibbonIconSource converts embedded SVG and PNG data URLs', () {
    final svgData = Uri.dataFromString(
      _svg,
      mimeType: 'image/svg+xml',
    ).toString();
    final svgSource = FxRibbonIconSource.fromEmbedded(
      FxRibbonEmbeddedIcon(kind: FxRibbonEmbeddedIconKind.svg, data: svgData),
    );
    final pngSource = FxRibbonIconSource.fromEmbedded(
      FxRibbonEmbeddedIcon(
        kind: FxRibbonEmbeddedIconKind.png,
        data: 'data:image/png;base64,${base64Encode(_pngBytes)}',
      ),
    );

    expect(svgSource.kind, FxRibbonIconKind.svgString);
    expect(svgSource.svgString, contains('<svg'));
    expect(pngSource.kind, FxRibbonIconKind.pngBytes);
    expect(pngSource.pngBytes, isNotEmpty);
  });

  testWidgets('FxRibbonIconView renders material, SVG, PNG, and placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          textDirection: TextDirection.ltr,
          children: [
            const FxRibbonIconView(
              source: FxRibbonIconSource.material(Icons.copy),
              size: 24,
              label: 'Copy',
            ),
            const FxRibbonIconView(
              source: FxRibbonIconSource.svgString(_svg),
              size: 24,
              label: 'Paste',
            ),
            FxRibbonIconView(
              source: FxRibbonIconSource.pngBytes(_pngBytes),
              size: 24,
              label: 'Png',
              enabled: false,
            ),
            const FxRibbonIconView(source: null, size: 24, label: ''),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.byType(FxRibbonIconView), findsNWidgets(4));
  });
}

const _svg = '<svg viewBox="0 0 24 24"><path d="M4 4h16v16H4z"/></svg>';

final _pngBytes = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1f,
  0x15,
  0xc4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0a,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9c,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0d,
  0x0a,
  0x2d,
  0xb4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
]);
