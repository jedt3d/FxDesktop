import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tool/fx_l10n.dart', () {
    test('audits ARB and PO fixture coverage', () {
      final result = _runFxL10n(['audit']);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        result.stdout.toString(),
        contains('FxDesktop localization audit passed'),
      );
    });

    test('imports PO by msgctxt and preserves duplicate English msgids', () {
      final tempDir = Directory.systemTemp.createTempSync('fx_l10n_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final output = '${tempDir.path}/fx_desktop_th.arb';
      final result = _runFxL10n([
        'import-po',
        '--input',
        'doc/localization/po-import-example-th.po',
        '--locale',
        'th',
        '--output',
        output,
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      final arb = jsonDecode(File(output).readAsStringSync()) as Map;
      expect(arb['gridContextMenuCopySelection'], 'คัดลอกส่วนที่เลือก');
      expect(arb['designerEditMenuCopyItem'], 'คัดลอก');
      expect(arb['colorPickerPreviewLabel'], 'ตัวอย่าง: {color}');
    });
  });
}

ProcessResult _runFxL10n(List<String> args) {
  return Process.runSync('dart', [
    'run',
    'tool/fx_l10n.dart',
    ...args,
  ], workingDirectory: Directory.current.path);
}
