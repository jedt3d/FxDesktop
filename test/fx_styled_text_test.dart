import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/src/fx_styled_text.dart';

void main() {
  group('FxStyledLabel', () {
    testWidgets('renders styled text spans in order', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FxStyledLabel(
            text: 'Status: urgent',
            spans: [
              FxStyledTextSpan(text: 'Status: '),
              FxStyledTextSpan(
                text: 'urgent',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      final label = tester.widget<Text>(find.byType(Text));
      final span = label.textSpan! as TextSpan;
      final children = span.children!.cast<TextSpan>();

      expect(children.map((child) => child.text), ['Status: ', 'urgent']);
      expect(children.last.style?.color, Colors.red);
      expect(children.last.style?.fontWeight, FontWeight.bold);
      expect(label.semanticsLabel, 'Status: urgent');
    });

    testWidgets('uses plain fallback text when spans are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FxStyledLabel(text: 'Plain label')),
      );

      expect(find.text('Plain label'), findsOneWidget);
    });

    testWidgets('applies disabled appearance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FxStyledLabel(text: 'Disabled label', enabled: false),
        ),
      );

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('Disabled label'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.38);
    });

    testWidgets('maps alignment, wrapping, max lines, and overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 80,
            child: FxStyledLabel(
              text: 'Long styled label text',
              alignment: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Long styled label text'));
      expect(label.textAlign, TextAlign.center);
      expect(label.softWrap, isFalse);
      expect(label.maxLines, 1);
      expect(label.overflow, TextOverflow.ellipsis);
    });

    test('exports template metadata', () {
      const label = FxStyledLabel(
        text: 'Amount due',
        enabled: false,
        softWrap: false,
        alignment: TextAlign.end,
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 13),
        spans: [
          FxStyledTextSpan(text: 'Amount '),
          FxStyledTextSpan(
            text: 'due',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      );

      expect(label.toTemplateMap(), {
        'component': 'FxStyledLabel',
        'xojo_desktop_class': 'DesktopLabel',
        'text': 'Amount due',
        'spanCount': 2,
        'spans': [
          {'text': 'Amount '},
          {
            'text': 'due',
            'style': {'fontStyle': 'italic'},
          },
        ],
        'enabled': false,
        'softWrap': false,
        'alignment': 'end',
        'maxLines': 1,
        'overflow': 'fade',
        'style': {'fontSize': 13.0},
      });
    });
  });
}
