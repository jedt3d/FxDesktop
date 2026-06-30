import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  test(
    'FxRibbonDefinition imports Jaspr-style schema and round-trips JSON',
    () {
      final definition = FxRibbonDefinition.fromJson(
        jsonDecode(_jasprRibbonJson) as Map<String, Object?>,
      );

      expect(definition.version, '2.0');
      expect(definition.projectType, 'web');
      expect(definition.tabs, hasLength(1));
      expect(
        definition.findItem('clipboard.copy')?.itemType,
        FxRibbonItemType.small,
      );
      expect(
        definition.findItem('organize.delete')?.itemType,
        FxRibbonItemType.splitButton,
      );

      final encoded = definition.toJsonString();
      final decoded = FxRibbonDefinition.fromJsonString(encoded);
      expect(decoded, definition);
    },
  );

  test('FxRibbonLocalizedText resolves exact, language, and fallback text', () {
    final item = FxRibbonItem.large(
      caption: 'Paste',
      tag: 'clipboard.paste',
      localizedCaptions: const {'th': 'วาง', 'ja': '貼り付け'},
    );

    expect(item.resolveCaption(const Locale('th', 'TH')), 'วาง');
    expect(item.resolveCaption(const Locale('ja')), '貼り付け');
    expect(item.resolveCaption(const Locale('ne')), 'Paste');
  });

  test(
    'FxRibbonValidator reports duplicate tags and unknown icon references',
    () {
      final definition = FxRibbonDefinition(
        tabs: [
          FxRibbonTab(
            caption: 'Home',
            groups: [
              FxRibbonGroup(
                caption: 'Commands',
                items: [
                  FxRibbonItem.large(
                    caption: 'Copy',
                    tag: 'copy',
                    iconKey: 'copy',
                  ),
                  FxRibbonItem.small(caption: 'Copy again', tag: 'copy'),
                ],
              ),
            ],
          ),
        ],
      );

      final result = FxRibbonValidator.validateDefinition(definition);
      expect(result.hasErrors, isTrue);
      expect(
        result.issues.map((issue) => issue.code),
        containsAll([
          FxRibbonValidationCode.duplicateItemTag,
          FxRibbonValidationCode.unknownIconKey,
        ]),
      );
    },
  );

  test('FxRibbonIconRegistry builds runtime entries from embedded icons', () {
    final definition = FxRibbonSamples.explorer();
    final registry = FxRibbonIconRegistry.fromEmbedded(definition.icons);

    expect(registry.containsKey('paste'), isTrue);
    expect(registry['paste']?.kind, FxRibbonIconKind.svgString);
  });

  test('FxRibbon embedded icons infer kind and compare by value', () {
    final svg = FxRibbonEmbeddedIcon.fromJson({
      'data': '<svg viewBox="0 0 24 24"></svg>',
    });
    final svgAsset = FxRibbonEmbeddedIcon.fromJson({'data': 'icons/copy.svg'});
    final png = FxRibbonEmbeddedIcon.fromJson({
      'kind': 'png',
      'data': 'iVBORw0KGgo=',
    });

    expect(svg.kind, FxRibbonEmbeddedIconKind.svg);
    expect(svgAsset.kind, FxRibbonEmbeddedIconKind.svg);
    expect(png.kind, FxRibbonEmbeddedIconKind.png);
    expect(svg, FxRibbonEmbeddedIcon.fromJson(svg.toJson()));
    expect(svg.hashCode, FxRibbonEmbeddedIcon.fromJson(svg.toJson()).hashCode);
  });

  test('FxRibbon menu items copy, localize, and serialize separators', () {
    const separator = FxRibbonMenuItem.separator();
    final item = FxRibbonMenuItem.fromJson({
      'caption': 'Open',
      'tag': 'file.open',
      'semanticLabel': 'Open file',
      'localizedCaptions': {'ja': '開く'},
      'localizedSemanticLabels': {'ja': 'ファイルを開く'},
    });
    final copy = item.copyWith(caption: 'Open recent');

    expect(separator.toJson(), {'itemType': 'separator'});
    expect(separator.copyWith(caption: 'ignored'), same(separator));
    expect(item.resolveCaption(const Locale('ja')), '開く');
    expect(item.resolveSemanticLabel(const Locale('ja')), 'ファイルを開く');
    expect(copy.caption, 'Open recent');
    expect(copy, isNot(item));
    expect(copy.hashCode, isA<int>());
  });

  test('FxRibbon items cover factories, copy, toggles, and serialization', () {
    final dropdown = FxRibbonItem.dropdown(
      caption: 'Arrange',
      tag: 'view.arrange',
      iconKey: 'arrange',
      menuItems: const [
        FxRibbonMenuItem(caption: 'Name', tag: 'view.arrange.name'),
      ],
      localizedSemanticLabels: const {'th': 'จัดเรียง'},
    );
    final toggle = FxRibbonItem.toggle(
      caption: 'Preview',
      tag: 'view.preview',
      isActive: true,
    );
    final checkbox = FxRibbonItem.checkBox(
      caption: 'Hidden',
      tag: 'view.hidden',
    );
    const separator = FxRibbonItem.separator();

    expect(dropdown.hasMenu, isTrue);
    expect(dropdown.resolveSemanticLabel(const Locale('th')), 'จัดเรียง');
    expect(
      dropdown.copyWith(tooltipText: 'Arrange items').tooltipText,
      'Arrange items',
    );
    expect(FxRibbonItem.fromJson(dropdown.toJson()), dropdown);
    expect(toggle.toggled().isToggleActive, isFalse);
    expect(checkbox.isToggleLike, isTrue);
    expect(separator.toJson(), {'itemType': 'separator'});
    expect(separator.copyWith(caption: 'ignored'), same(separator));
    expect(FxRibbonItemType.parse('unknown'), FxRibbonItemType.large);
  });

  test('FxRibbon tabs and groups support contextual JSON and copies', () {
    final tab = FxRibbonTab.fromJson({
      'caption': 'Format',
      'isContextual': true,
      'contextGroup': 'Picture Tools',
      'accentColor': '#ff00aa',
      'localizedContextGroups': {'ja': '画像ツール'},
      'groups': [
        {
          'caption': 'Styles',
          'items': [
            {'caption': 'Border', 'tag': 'picture.border'},
          ],
        },
      ],
    });
    final group = tab.groups.single.copyWith(caption: 'Picture Styles');

    expect(tab.isContextual, isTrue);
    expect(tab.resolveContextGroup(const Locale('ja')), '画像ツール');
    expect(tab.findItem('picture.border')?.caption, 'Border');
    expect(FxRibbonTab.fromJson(tab.toJson()), tab);
    expect(group.caption, 'Picture Styles');
    expect(group.findItem('missing'), isNull);
    expect(group.hashCode, isA<int>());
    expect(tab.hashCode, isA<int>());
  });

  test('FxRibbonDefinition copies, resolves names, and toggles safely', () {
    final definition = FxRibbonSamples.explorer();
    final renamed = definition.copyWith(
      name: 'Renamed',
      description: 'Sample',
      metadata: const {'owner': 'tests'},
    );

    expect(definition.resolveName(const Locale('ja')), 'Explorer リボン');
    expect(renamed.name, 'Renamed');
    expect(renamed.description, 'Sample');
    expect(renamed.toTemplateMap()['metadata'], {'owner': 'tests'});
    expect(definition.toggled('missing'), same(definition));
    expect(
      definition
          .toggled('view.preview')
          .findItem('view.preview')
          ?.isToggleActive,
      isTrue,
    );
    expect(renamed.hashCode, isA<int>());
  });

  test('FxRibbonValidator reports invalid source and soft warnings', () {
    final invalidJson = FxRibbonValidator.validateSource('{');
    final invalidRoot = FxRibbonValidator.validateSource('[]');
    final warningDefinition = FxRibbonDefinition(
      version: '9.9',
      tabs: [
        FxRibbonTab.contextual(
          caption: '',
          contextGroup: '',
          groups: [
            FxRibbonGroup(
              caption: '',
              localizedCaptions: const {'bad tag': 'Bad'},
              items: [
                FxRibbonItem.dropdown(
                  caption: '',
                  tag: '',
                  localizedCaptions: const {'bad tag': ''},
                ),
                const FxRibbonItem.separator(),
                const FxRibbonItem(
                  caption: '',
                  tag: '',
                  itemType: FxRibbonItemType.small,
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final warningResult = FxRibbonValidator.validateDefinition(
      warningDefinition,
    );

    expect(invalidJson.issues.single.code, FxRibbonValidationCode.invalidJson);
    expect(invalidRoot.issues.single.code, FxRibbonValidationCode.invalidRoot);
    expect(warningResult.isValid, isFalse);
    expect(
      warningResult.issues.map((issue) => issue.code),
      containsAll([
        FxRibbonValidationCode.unsupportedVersion,
        FxRibbonValidationCode.missingTabCaption,
        FxRibbonValidationCode.missingContextGroup,
        FxRibbonValidationCode.missingGroupCaption,
        FxRibbonValidationCode.missingItemCaption,
        FxRibbonValidationCode.missingItemTag,
        FxRibbonValidationCode.missingMenuItems,
        FxRibbonValidationCode.invalidLocaleTag,
      ]),
    );
    expect(warningResult.issues.first.toTemplateMap()['code'], isA<String>());
  });

  test('FxRibbonThemeData resolves, copies, and lerps values', () {
    const theme = FxRibbonThemeData(
      density: FxRibbonDensity.compact,
      borderRadius: 3,
      backgroundColor: Colors.white,
      tabStripColor: Colors.black,
      activeTabColor: Colors.blue,
      groupBackgroundColor: Colors.green,
      hoverColor: Colors.orange,
      pressedColor: Colors.red,
      keyTipBackgroundColor: Colors.purple,
      keyTipForegroundColor: Colors.yellow,
    );
    const other = FxRibbonThemeData(
      density: FxRibbonDensity.comfortable,
      borderRadius: 7,
      backgroundColor: Colors.black,
      tabStripColor: Colors.white,
      activeTabColor: Colors.red,
      groupBackgroundColor: Colors.blue,
      hoverColor: Colors.green,
      pressedColor: Colors.orange,
      keyTipBackgroundColor: Colors.yellow,
      keyTipForegroundColor: Colors.purple,
    );
    const scheme = ColorScheme.light();

    expect(FxRibbonDensity.comfortable.largeIconSize, 36);
    expect(FxRibbonDensity.comfortable.smallIconSize, 18);
    expect(FxRibbonDensity.comfortable.minTargetHeight, 36);
    expect(FxRibbonDensity.comfortable.collapsedHeight, 44);
    expect(theme.resolvedBackground(scheme), Colors.white);
    expect(theme.resolvedHover(scheme), Colors.orange);
    expect(theme.resolvedKeyTipBackground(scheme), Colors.purple);
    expect(theme.resolvedKeyTipForeground(scheme), Colors.yellow);
    expect(theme.copyWith(borderRadius: 6).borderRadius, 6);
    expect(theme.lerp(null, 0.5), same(theme));
    expect(theme.lerp(other, 0.75).density, FxRibbonDensity.comfortable);
    expect(theme.lerp(other, 0.5).borderRadius, 5);
    expect(
      const FxRibbonThemeData().resolvedPressed(scheme),
      scheme.primary.withValues(alpha: 0.14),
    );
  });
}

const _jasprRibbonJson = '''
{
  "version": "2.0",
  "projectType": "web",
  "tabs": [
    {
      "caption": "Home",
      "groups": [
        {
          "caption": "Clipboard",
          "items": [
            {"caption": "Copy", "tag": "clipboard.copy", "itemType": "small"},
            {
              "caption": "Delete",
              "tag": "organize.delete",
              "itemType": "splitbutton",
              "menuItems": [
                {"caption": "Recycle", "tag": "organize.delete.recycle"}
              ]
            }
          ]
        }
      ]
    }
  ]
}
''';
