import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  group('FxDesktopLocalizations', () {
    test(
      'looks up bundled locales and keeps duplicate Copy contexts separate',
      () {
        final thai = lookupFxDesktopLocalizations(const Locale('th'));
        final japanese = lookupFxDesktopLocalizations(const Locale('ja'));

        expect(thai.datePickerEmptyHint, 'เลือกวันที่');
        expect(thai.gridContextMenuCopySelection, 'คัดลอกส่วนที่เลือก');
        expect(thai.designerEditMenuCopyItem, 'คัดลอก');
        expect(japanese.galleryLanguageJapanese, '日本語');
      },
    );

    test(
      'FxLocalizedText resolves exact, script, language, and fallback values',
      () {
        const text = FxLocalizedText(
          fallback: 'Fallback',
          values: {
            'zh-Hans': 'Simplified',
            'pt': 'Portuguese',
            'pt-BR': 'Brazilian Portuguese',
          },
        );

        expect(
          text.resolve(
            const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
          ),
          'Brazilian Portuguese',
        );
        expect(
          text.resolve(
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          ),
          'Simplified',
        );
        expect(text.resolve(const Locale('pt', 'PT')), 'Portuguese');
        expect(text.resolve(const Locale('fr')), 'Fallback');
        expect(FxLocalizedText.fromJson(text.toJson()).toJson(), text.toJson());
      },
    );

    testWidgets(
      'component defaults fall back to English without the package delegate',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FxPopupMenu(options: [], onChanged: null)),
          ),
        );

        expect(find.text('No options'), findsOneWidget);
      },
    );

    testWidgets('component defaults resolve through Flutter delegates', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          locale: Locale('th'),
          home: Scaffold(body: FxDateTimePicker(label: 'Date')),
        ),
      );

      expect(find.text('เลือกวันที่'), findsOneWidget);
    });

    testWidgets('gallery switches all localized chrome to another locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
          supportedLocales: FxDesktopLocalizations.supportedLocales,
          home: const Scaffold(body: FxLocalizationGallery()),
        ),
      );

      expect(find.text('FxDesktop Localization Gallery'), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);

      await tester.tap(find.text('Thai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('แกลเลอรีการแปล FxDesktop'), findsOneWidget);
      expect(find.text('เลือกวันที่'), findsOneWidget);
      expect(
        find.textContaining('grid.context_menu.copy_selection'),
        findsOneWidget,
      );
      expect(find.textContaining('คัดลอกส่วนที่เลือก'), findsOneWidget);
    });
  });
}
