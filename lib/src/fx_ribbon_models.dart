import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'fx_localized_text.dart';

/// Localized ribbon text uses the suite-wide FxDesktop localized text model.
typedef FxRibbonLocalizedText = FxLocalizedText;

/// Item kinds supported by [FxRibbonItem].
enum FxRibbonItemType {
  /// Large button with icon above caption.
  large('large'),

  /// Small row button, usually stacked three per column.
  small('small'),

  /// Whole button opens a menu.
  dropdown('dropdown'),

  /// Body fires a command and arrow opens a menu.
  splitButton('splitbutton'),

  /// Persistent on/off command.
  toggle('toggle'),

  /// Checkbox-style on/off command.
  checkBox('checkbox'),

  /// Non-interactive divider.
  separator('separator');

  const FxRibbonItemType(this.jsonValue);

  /// Serialized `.ribbon` item type token.
  final String jsonValue;

  /// Whether this item has no command behavior.
  bool get isSeparator => this == FxRibbonItemType.separator;

  /// Parses a Jaspr/FxDesktop item type token.
  static FxRibbonItemType parse(Object? value) {
    final normalized = value?.toString().toLowerCase();
    return FxRibbonItemType.values.firstWhere(
      (type) => type.jsonValue == normalized,
      orElse: () => FxRibbonItemType.large,
    );
  }
}

/// Embedded icon kind persisted in a ribbon definition.
enum FxRibbonEmbeddedIconKind {
  /// SVG markup, SVG data URL, or SVG asset reference.
  svg,

  /// PNG bytes encoded as base64 or a PNG data URL.
  png;

  /// Parses an icon kind, inferring PNG when unknown.
  static FxRibbonEmbeddedIconKind parse(Object? value, String data) {
    final normalized = value?.toString().toLowerCase();
    if (normalized == 'svg') {
      return FxRibbonEmbeddedIconKind.svg;
    }
    if (normalized == 'png') {
      return FxRibbonEmbeddedIconKind.png;
    }
    final lower = data.toLowerCase();
    if (lower.contains('image/svg') ||
        lower.trimLeft().startsWith('<svg') ||
        lower.endsWith('.svg')) {
      return FxRibbonEmbeddedIconKind.svg;
    }
    return FxRibbonEmbeddedIconKind.png;
  }
}

/// Icon asset embedded in a `.ribbon` bundle.
@immutable
class FxRibbonEmbeddedIcon {
  /// Creates an embedded icon asset.
  const FxRibbonEmbeddedIcon({required this.kind, required this.data});

  /// Creates an embedded icon from JSON.
  factory FxRibbonEmbeddedIcon.fromJson(Map<String, Object?> json) {
    final data = json['data']?.toString() ?? '';
    return FxRibbonEmbeddedIcon(
      kind: FxRibbonEmbeddedIconKind.parse(json['kind'], data),
      data: data,
    );
  }

  /// Icon format.
  final FxRibbonEmbeddedIconKind kind;

  /// Icon payload.
  final String data;

  /// Converts this icon asset to JSON.
  Map<String, Object?> toJson() => {'kind': kind.name, 'data': data};

  @override
  bool operator ==(Object other) {
    return other is FxRibbonEmbeddedIcon &&
        other.kind == kind &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(kind, data);
}

/// Menu item inside dropdown and split-button ribbon commands.
@immutable
class FxRibbonMenuItem {
  /// Creates an actionable menu item.
  const FxRibbonMenuItem({
    required this.caption,
    required this.tag,
    this.localizedCaptions = const {},
    this.semanticLabel,
    this.localizedSemanticLabels = const {},
  }) : isSeparator = false;

  /// Creates a menu separator.
  const FxRibbonMenuItem.separator()
    : caption = '',
      tag = '',
      localizedCaptions = const {},
      semanticLabel = null,
      localizedSemanticLabels = const {},
      isSeparator = true;

  /// Creates a menu item from JSON.
  factory FxRibbonMenuItem.fromJson(Map<String, Object?> json) {
    final type = json['type'] ?? json['itemType'];
    if (type == 'Separator' || type == 'separator') {
      return const FxRibbonMenuItem.separator();
    }
    return FxRibbonMenuItem(
      caption: (json['caption'] ?? json['label'] ?? '').toString(),
      tag: (json['tag'] ?? json['id'] ?? '').toString(),
      localizedCaptions: _stringMap(json['localizedCaptions']),
      semanticLabel: json['semanticLabel'] as String?,
      localizedSemanticLabels: _stringMap(json['localizedSemanticLabels']),
    );
  }

  /// Fallback caption.
  final String caption;

  /// Stable menu command tag.
  final String tag;

  /// Locale-specific captions keyed by locale tag.
  final Map<String, String> localizedCaptions;

  /// Optional fallback semantic label.
  final String? semanticLabel;

  /// Locale-specific semantic labels keyed by locale tag.
  final Map<String, String> localizedSemanticLabels;

  /// Whether this is a menu separator.
  final bool isSeparator;

  /// Resolves the caption for [locale].
  String resolveCaption(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: caption,
      values: localizedCaptions,
    ).resolve(locale);
  }

  /// Resolves the semantic label for [locale].
  String resolveSemanticLabel(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: semanticLabel ?? caption,
      values: localizedSemanticLabels,
    ).resolve(locale);
  }

  /// Converts this menu item to JSON.
  Map<String, Object?> toJson() {
    if (isSeparator) {
      return {'itemType': 'separator'};
    }
    return {
      'caption': caption,
      'tag': tag,
      if (localizedCaptions.isNotEmpty) 'localizedCaptions': localizedCaptions,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      if (localizedSemanticLabels.isNotEmpty)
        'localizedSemanticLabels': localizedSemanticLabels,
    };
  }

  /// Creates a modified copy.
  FxRibbonMenuItem copyWith({
    String? caption,
    String? tag,
    Map<String, String>? localizedCaptions,
    Object? semanticLabel = _sentinel,
    Map<String, String>? localizedSemanticLabels,
  }) {
    if (isSeparator) {
      return this;
    }
    return FxRibbonMenuItem(
      caption: caption ?? this.caption,
      tag: tag ?? this.tag,
      localizedCaptions: localizedCaptions ?? this.localizedCaptions,
      semanticLabel: identical(semanticLabel, _sentinel)
          ? this.semanticLabel
          : semanticLabel as String?,
      localizedSemanticLabels:
          localizedSemanticLabels ?? this.localizedSemanticLabels,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FxRibbonMenuItem &&
        other.caption == caption &&
        other.tag == tag &&
        other.isSeparator == isSeparator &&
        mapEquals(other.localizedCaptions, localizedCaptions) &&
        other.semanticLabel == semanticLabel &&
        mapEquals(other.localizedSemanticLabels, localizedSemanticLabels);
  }

  @override
  int get hashCode => Object.hash(
    caption,
    tag,
    isSeparator,
    Object.hashAllUnordered(localizedCaptions.entries),
    semanticLabel,
    Object.hashAllUnordered(localizedSemanticLabels.entries),
  );
}

/// A command item inside a [FxRibbonGroup].
@immutable
class FxRibbonItem {
  /// Creates a ribbon item.
  const FxRibbonItem({
    required this.caption,
    required this.tag,
    required this.itemType,
    this.isEnabled = true,
    this.isToggleActive = false,
    this.tooltipText,
    this.iconKey,
    this.keyTip,
    this.menuItems = const [],
    this.semanticLabel,
    this.localizedCaptions = const {},
    this.localizedTooltips = const {},
    this.localizedSemanticLabels = const {},
  });

  /// Creates a large command button.
  factory FxRibbonItem.large({
    required String caption,
    required String tag,
    String? tooltipText,
    String? iconKey,
    String? keyTip,
    bool isEnabled = true,
    List<FxRibbonMenuItem> menuItems = const [],
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.large,
      isEnabled: isEnabled,
      tooltipText: tooltipText,
      iconKey: iconKey,
      keyTip: keyTip,
      menuItems: menuItems,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a small command button.
  factory FxRibbonItem.small({
    required String caption,
    required String tag,
    String? tooltipText,
    String? iconKey,
    String? keyTip,
    bool isEnabled = true,
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.small,
      isEnabled: isEnabled,
      tooltipText: tooltipText,
      iconKey: iconKey,
      keyTip: keyTip,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a dropdown command.
  factory FxRibbonItem.dropdown({
    required String caption,
    required String tag,
    String? tooltipText,
    String? iconKey,
    String? keyTip,
    bool isEnabled = true,
    List<FxRibbonMenuItem> menuItems = const [],
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.dropdown,
      isEnabled: isEnabled,
      tooltipText: tooltipText,
      iconKey: iconKey,
      keyTip: keyTip,
      menuItems: menuItems,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a split button.
  factory FxRibbonItem.splitButton({
    required String caption,
    required String tag,
    String? tooltipText,
    String? iconKey,
    String? keyTip,
    bool isEnabled = true,
    List<FxRibbonMenuItem> menuItems = const [],
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.splitButton,
      isEnabled: isEnabled,
      tooltipText: tooltipText,
      iconKey: iconKey,
      keyTip: keyTip,
      menuItems: menuItems,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a toggle command.
  factory FxRibbonItem.toggle({
    required String caption,
    required String tag,
    bool isActive = false,
    String? tooltipText,
    String? iconKey,
    String? keyTip,
    bool isEnabled = true,
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.toggle,
      isEnabled: isEnabled,
      isToggleActive: isActive,
      tooltipText: tooltipText,
      iconKey: iconKey,
      keyTip: keyTip,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a checkbox command.
  factory FxRibbonItem.checkBox({
    required String caption,
    required String tag,
    bool isChecked = false,
    String? tooltipText,
    String? keyTip,
    bool isEnabled = true,
    String? semanticLabel,
    Map<String, String> localizedCaptions = const {},
    Map<String, String> localizedTooltips = const {},
    Map<String, String> localizedSemanticLabels = const {},
  }) {
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: FxRibbonItemType.checkBox,
      isEnabled: isEnabled,
      isToggleActive: isChecked,
      tooltipText: tooltipText,
      keyTip: keyTip,
      semanticLabel: semanticLabel,
      localizedCaptions: localizedCaptions,
      localizedTooltips: localizedTooltips,
      localizedSemanticLabels: localizedSemanticLabels,
    );
  }

  /// Creates a group separator.
  const FxRibbonItem.separator()
    : caption = '',
      tag = '',
      itemType = FxRibbonItemType.separator,
      isEnabled = false,
      isToggleActive = false,
      tooltipText = null,
      iconKey = null,
      keyTip = null,
      menuItems = const [],
      semanticLabel = null,
      localizedCaptions = const {},
      localizedTooltips = const {},
      localizedSemanticLabels = const {};

  /// Creates a ribbon item from JSON.
  factory FxRibbonItem.fromJson(Map<String, Object?> json) {
    final type = FxRibbonItemType.parse(json['itemType']);
    if (type.isSeparator) {
      return const FxRibbonItem.separator();
    }
    final caption = (json['caption'] ?? '').toString();
    final tag = (json['tag'] ?? '').toString();
    final menuItems = [
      for (final entry in json['menuItems'] as List<Object?>? ?? const [])
        if (entry is Map)
          FxRibbonMenuItem.fromJson(Map<String, Object?>.from(entry)),
    ];
    return FxRibbonItem(
      caption: caption,
      tag: tag,
      itemType: type,
      isEnabled: json['isEnabled'] as bool? ?? true,
      isToggleActive: json['isToggleActive'] as bool? ?? false,
      tooltipText: json['tooltipText'] as String?,
      iconKey: (json['iconKey'] ?? json['icon']) as String?,
      keyTip: json['keyTip'] as String?,
      menuItems: menuItems,
      semanticLabel: json['semanticLabel'] as String?,
      localizedCaptions: _stringMap(json['localizedCaptions']),
      localizedTooltips: _stringMap(json['localizedTooltips']),
      localizedSemanticLabels: _stringMap(json['localizedSemanticLabels']),
    );
  }

  /// Fallback caption.
  final String caption;

  /// Stable command tag used in events.
  final String tag;

  /// Item kind.
  final FxRibbonItemType itemType;

  /// Whether the command can be activated.
  final bool isEnabled;

  /// Toggle or checkbox state.
  final bool isToggleActive;

  /// Fallback tooltip.
  final String? tooltipText;

  /// Icon registry key.
  final String? iconKey;

  /// Optional keyboard keytip.
  final String? keyTip;

  /// Dropdown or split-button menu entries.
  final List<FxRibbonMenuItem> menuItems;

  /// Optional fallback semantic label.
  final String? semanticLabel;

  /// Locale-specific captions keyed by locale tag.
  final Map<String, String> localizedCaptions;

  /// Locale-specific tooltips keyed by locale tag.
  final Map<String, String> localizedTooltips;

  /// Locale-specific semantic labels keyed by locale tag.
  final Map<String, String> localizedSemanticLabels;

  /// Whether this item is a group separator.
  bool get isSeparator => itemType.isSeparator;

  /// Whether this item is a dropdown or split button.
  bool get hasMenu =>
      itemType == FxRibbonItemType.dropdown ||
      itemType == FxRibbonItemType.splitButton;

  /// Whether this item has persistent on/off state.
  bool get isToggleLike =>
      itemType == FxRibbonItemType.toggle ||
      itemType == FxRibbonItemType.checkBox;

  /// Resolves the caption for [locale].
  String resolveCaption(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: caption,
      values: localizedCaptions,
    ).resolve(locale);
  }

  /// Resolves the tooltip for [locale].
  String? resolveTooltip(Locale locale) {
    if (tooltipText == null && localizedTooltips.isEmpty) {
      return null;
    }
    return FxRibbonLocalizedText(
      fallback: tooltipText ?? '',
      values: localizedTooltips,
    ).resolve(locale);
  }

  /// Resolves the semantic label for [locale].
  String resolveSemanticLabel(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: semanticLabel ?? caption,
      values: localizedSemanticLabels,
    ).resolve(locale);
  }

  /// Converts this item to JSON.
  Map<String, Object?> toJson() {
    if (isSeparator) {
      return {'itemType': itemType.jsonValue};
    }
    return {
      'caption': caption,
      'tag': tag,
      'itemType': itemType.jsonValue,
      'isEnabled': isEnabled,
      if (isToggleLike) 'isToggleActive': isToggleActive,
      if (tooltipText != null) 'tooltipText': tooltipText,
      if (iconKey != null) 'iconKey': iconKey,
      if (keyTip != null) 'keyTip': keyTip,
      if (menuItems.isNotEmpty)
        'menuItems': menuItems.map((item) => item.toJson()).toList(),
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      if (localizedCaptions.isNotEmpty) 'localizedCaptions': localizedCaptions,
      if (localizedTooltips.isNotEmpty) 'localizedTooltips': localizedTooltips,
      if (localizedSemanticLabels.isNotEmpty)
        'localizedSemanticLabels': localizedSemanticLabels,
    };
  }

  /// Creates a modified copy.
  FxRibbonItem copyWith({
    String? caption,
    String? tag,
    FxRibbonItemType? itemType,
    bool? isEnabled,
    bool? isToggleActive,
    Object? tooltipText = _sentinel,
    Object? iconKey = _sentinel,
    Object? keyTip = _sentinel,
    List<FxRibbonMenuItem>? menuItems,
    Object? semanticLabel = _sentinel,
    Map<String, String>? localizedCaptions,
    Map<String, String>? localizedTooltips,
    Map<String, String>? localizedSemanticLabels,
  }) {
    if (isSeparator) {
      return this;
    }
    return FxRibbonItem(
      caption: caption ?? this.caption,
      tag: tag ?? this.tag,
      itemType: itemType ?? this.itemType,
      isEnabled: isEnabled ?? this.isEnabled,
      isToggleActive: isToggleActive ?? this.isToggleActive,
      tooltipText: identical(tooltipText, _sentinel)
          ? this.tooltipText
          : tooltipText as String?,
      iconKey: identical(iconKey, _sentinel)
          ? this.iconKey
          : iconKey as String?,
      keyTip: identical(keyTip, _sentinel) ? this.keyTip : keyTip as String?,
      menuItems: menuItems ?? this.menuItems,
      semanticLabel: identical(semanticLabel, _sentinel)
          ? this.semanticLabel
          : semanticLabel as String?,
      localizedCaptions: localizedCaptions ?? this.localizedCaptions,
      localizedTooltips: localizedTooltips ?? this.localizedTooltips,
      localizedSemanticLabels:
          localizedSemanticLabels ?? this.localizedSemanticLabels,
    );
  }

  /// Returns this item with [isToggleActive] flipped.
  FxRibbonItem toggled() => copyWith(isToggleActive: !isToggleActive);

  @override
  bool operator ==(Object other) {
    return other is FxRibbonItem &&
        other.caption == caption &&
        other.tag == tag &&
        other.itemType == itemType &&
        other.isEnabled == isEnabled &&
        other.isToggleActive == isToggleActive &&
        other.tooltipText == tooltipText &&
        other.iconKey == iconKey &&
        other.keyTip == keyTip &&
        listEquals(other.menuItems, menuItems) &&
        other.semanticLabel == semanticLabel &&
        mapEquals(other.localizedCaptions, localizedCaptions) &&
        mapEquals(other.localizedTooltips, localizedTooltips) &&
        mapEquals(other.localizedSemanticLabels, localizedSemanticLabels);
  }

  @override
  int get hashCode => Object.hash(
    caption,
    tag,
    itemType,
    isEnabled,
    isToggleActive,
    tooltipText,
    iconKey,
    keyTip,
    Object.hashAll(menuItems),
    semanticLabel,
    Object.hashAllUnordered(localizedCaptions.entries),
    Object.hashAllUnordered(localizedTooltips.entries),
    Object.hashAllUnordered(localizedSemanticLabels.entries),
  );
}

/// A labeled item group in a ribbon tab.
@immutable
class FxRibbonGroup {
  /// Creates a ribbon group.
  const FxRibbonGroup({
    required this.caption,
    required this.items,
    this.id,
    this.localizedCaptions = const {},
  });

  /// Creates a ribbon group from JSON.
  factory FxRibbonGroup.fromJson(Map<String, Object?> json) {
    return FxRibbonGroup(
      id: json['id'] as String?,
      caption: (json['caption'] ?? '').toString(),
      localizedCaptions: _stringMap(json['localizedCaptions']),
      items: [
        for (final entry in json['items'] as List<Object?>? ?? const [])
          if (entry is Map)
            FxRibbonItem.fromJson(Map<String, Object?>.from(entry)),
      ],
    );
  }

  /// Optional stable group id.
  final String? id;

  /// Fallback group caption.
  final String caption;

  /// Items in this group.
  final List<FxRibbonItem> items;

  /// Locale-specific captions keyed by locale tag.
  final Map<String, String> localizedCaptions;

  /// Resolves the caption for [locale].
  String resolveCaption(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: caption,
      values: localizedCaptions,
    ).resolve(locale);
  }

  /// Finds an item by command tag.
  FxRibbonItem? findItem(String tag) {
    for (final item in items) {
      if (item.tag == tag) {
        return item;
      }
    }
    return null;
  }

  /// Converts this group to JSON.
  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'caption': caption,
      if (localizedCaptions.isNotEmpty) 'localizedCaptions': localizedCaptions,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Creates a modified copy.
  FxRibbonGroup copyWith({
    Object? id = _sentinel,
    String? caption,
    List<FxRibbonItem>? items,
    Map<String, String>? localizedCaptions,
  }) {
    return FxRibbonGroup(
      id: identical(id, _sentinel) ? this.id : id as String?,
      caption: caption ?? this.caption,
      items: items ?? this.items,
      localizedCaptions: localizedCaptions ?? this.localizedCaptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FxRibbonGroup &&
        other.id == id &&
        other.caption == caption &&
        listEquals(other.items, items) &&
        mapEquals(other.localizedCaptions, localizedCaptions);
  }

  @override
  int get hashCode => Object.hash(
    id,
    caption,
    Object.hashAll(items),
    Object.hashAllUnordered(localizedCaptions.entries),
  );
}

/// A top-level ribbon tab.
@immutable
class FxRibbonTab {
  /// Creates a standard ribbon tab.
  const FxRibbonTab({
    required this.caption,
    required this.groups,
    this.id,
    this.keyTip,
    this.localizedCaptions = const {},
  }) : isContextual = false,
       contextGroup = null,
       accentColor = null,
       localizedContextGroups = const {};

  /// Creates a contextual ribbon tab.
  const FxRibbonTab.contextual({
    required this.caption,
    required this.groups,
    required this.contextGroup,
    this.id,
    this.accentColor,
    this.keyTip,
    this.localizedCaptions = const {},
    this.localizedContextGroups = const {},
  }) : isContextual = true;

  /// Creates a ribbon tab from JSON.
  factory FxRibbonTab.fromJson(Map<String, Object?> json) {
    final groups = [
      for (final entry in json['groups'] as List<Object?>? ?? const [])
        if (entry is Map)
          FxRibbonGroup.fromJson(Map<String, Object?>.from(entry)),
    ];
    final isContextual = json['isContextual'] as bool? ?? false;
    if (isContextual) {
      return FxRibbonTab.contextual(
        id: json['id'] as String?,
        caption: (json['caption'] ?? '').toString(),
        groups: groups,
        contextGroup: (json['contextGroup'] ?? '').toString(),
        accentColor: _colorFromJson(json['accentColor']),
        keyTip: json['keyTip'] as String?,
        localizedCaptions: _stringMap(json['localizedCaptions']),
        localizedContextGroups: _stringMap(json['localizedContextGroups']),
      );
    }
    return FxRibbonTab(
      id: json['id'] as String?,
      caption: (json['caption'] ?? '').toString(),
      groups: groups,
      keyTip: json['keyTip'] as String?,
      localizedCaptions: _stringMap(json['localizedCaptions']),
    );
  }

  /// Optional stable tab id.
  final String? id;

  /// Fallback tab caption.
  final String caption;

  /// Groups in this tab.
  final List<FxRibbonGroup> groups;

  /// Whether this is a contextual tab.
  final bool isContextual;

  /// Contextual group name.
  final String? contextGroup;

  /// Optional contextual accent color.
  final Color? accentColor;

  /// Optional manual tab keytip.
  final String? keyTip;

  /// Locale-specific captions keyed by locale tag.
  final Map<String, String> localizedCaptions;

  /// Locale-specific contextual group labels keyed by locale tag.
  final Map<String, String> localizedContextGroups;

  /// Resolves the tab caption for [locale].
  String resolveCaption(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: caption,
      values: localizedCaptions,
    ).resolve(locale);
  }

  /// Resolves the contextual group label for [locale].
  String? resolveContextGroup(Locale locale) {
    if (contextGroup == null) {
      return null;
    }
    return FxRibbonLocalizedText(
      fallback: contextGroup!,
      values: localizedContextGroups,
    ).resolve(locale);
  }

  /// Finds an item by command tag.
  FxRibbonItem? findItem(String tag) {
    for (final group in groups) {
      final found = group.findItem(tag);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Converts this tab to JSON.
  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'caption': caption,
      if (localizedCaptions.isNotEmpty) 'localizedCaptions': localizedCaptions,
      if (isContextual) 'isContextual': true,
      if (contextGroup != null) 'contextGroup': contextGroup,
      if (localizedContextGroups.isNotEmpty)
        'localizedContextGroups': localizedContextGroups,
      if (accentColor != null) 'accentColor': accentColor!.toARGB32(),
      if (keyTip != null) 'keyTip': keyTip,
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }

  /// Creates a modified copy.
  FxRibbonTab copyWith({
    Object? id = _sentinel,
    String? caption,
    List<FxRibbonGroup>? groups,
    bool? isContextual,
    Object? contextGroup = _sentinel,
    Object? accentColor = _sentinel,
    Object? keyTip = _sentinel,
    Map<String, String>? localizedCaptions,
    Map<String, String>? localizedContextGroups,
  }) {
    final nextContextual = isContextual ?? this.isContextual;
    if (nextContextual) {
      return FxRibbonTab.contextual(
        id: identical(id, _sentinel) ? this.id : id as String?,
        caption: caption ?? this.caption,
        groups: groups ?? this.groups,
        contextGroup: identical(contextGroup, _sentinel)
            ? this.contextGroup ?? ''
            : contextGroup as String,
        accentColor: identical(accentColor, _sentinel)
            ? this.accentColor
            : accentColor as Color?,
        keyTip: identical(keyTip, _sentinel) ? this.keyTip : keyTip as String?,
        localizedCaptions: localizedCaptions ?? this.localizedCaptions,
        localizedContextGroups:
            localizedContextGroups ?? this.localizedContextGroups,
      );
    }
    return FxRibbonTab(
      id: identical(id, _sentinel) ? this.id : id as String?,
      caption: caption ?? this.caption,
      groups: groups ?? this.groups,
      keyTip: identical(keyTip, _sentinel) ? this.keyTip : keyTip as String?,
      localizedCaptions: localizedCaptions ?? this.localizedCaptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FxRibbonTab &&
        other.id == id &&
        other.caption == caption &&
        listEquals(other.groups, groups) &&
        other.isContextual == isContextual &&
        other.contextGroup == contextGroup &&
        other.accentColor == accentColor &&
        other.keyTip == keyTip &&
        mapEquals(other.localizedCaptions, localizedCaptions) &&
        mapEquals(other.localizedContextGroups, localizedContextGroups);
  }

  @override
  int get hashCode => Object.hash(
    id,
    caption,
    Object.hashAll(groups),
    isContextual,
    contextGroup,
    accentColor,
    keyTip,
    Object.hashAllUnordered(localizedCaptions.entries),
    Object.hashAllUnordered(localizedContextGroups.entries),
  );
}

/// Root ribbon definition.
@immutable
class FxRibbonDefinition {
  /// Creates a ribbon definition.
  const FxRibbonDefinition({
    this.version = kSchemaVersion,
    this.projectType = kProjectTypeFlutter,
    required this.tabs,
    this.icons = const {},
    this.name,
    this.description,
    this.localizedNames = const {},
    this.metadata = const {},
  });

  /// Current FxDesktop ribbon schema version.
  static const String kSchemaVersion = '1.0';

  /// Project type used by FxDesktop Flutter ribbons.
  static const String kProjectTypeFlutter = 'flutter';

  /// Supported Jaspr source schema version.
  static const String kJasprSchemaVersion = '2.0';

  /// Creates a ribbon definition from JSON.
  factory FxRibbonDefinition.fromJson(Map<String, Object?> json) {
    final icons = <String, FxRibbonEmbeddedIcon>{};
    final rawIcons = json['icons'];
    if (rawIcons is Map) {
      for (final entry in rawIcons.entries) {
        if (entry.value is Map) {
          icons[entry.key.toString()] = FxRibbonEmbeddedIcon.fromJson(
            Map<String, Object?>.from(entry.value as Map),
          );
        }
      }
    }
    return FxRibbonDefinition(
      version: (json['version'] ?? kSchemaVersion).toString(),
      projectType: (json['projectType'] ?? kProjectTypeFlutter).toString(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      localizedNames: _stringMap(json['localizedNames']),
      metadata: _objectMap(json['metadata']),
      icons: icons,
      tabs: [
        for (final entry in json['tabs'] as List<Object?>? ?? const [])
          if (entry is Map)
            FxRibbonTab.fromJson(Map<String, Object?>.from(entry)),
      ],
    );
  }

  /// Creates a ribbon definition from a JSON string.
  factory FxRibbonDefinition.fromJsonString(String source) {
    return FxRibbonDefinition.fromJson(
      jsonDecode(source) as Map<String, Object?>,
    );
  }

  /// Schema version.
  final String version;

  /// Target project type.
  final String projectType;

  /// Ordered tabs.
  final List<FxRibbonTab> tabs;

  /// Optional embedded icons.
  final Map<String, FxRibbonEmbeddedIcon> icons;

  /// Optional fallback name for designer/tooling surfaces.
  final String? name;

  /// Optional definition description.
  final String? description;

  /// Locale-specific names keyed by locale tag.
  final Map<String, String> localizedNames;

  /// Additional metadata for tools.
  final Map<String, Object?> metadata;

  /// Standard tabs.
  Iterable<FxRibbonTab> get standardTabs =>
      tabs.where((tab) => !tab.isContextual);

  /// Contextual tabs.
  Iterable<FxRibbonTab> get contextualTabs =>
      tabs.where((tab) => tab.isContextual);

  /// Visible tabs for active context groups.
  List<FxRibbonTab> visibleTabs(Set<String> visibleContextGroups) {
    return [
      for (final tab in tabs)
        if (!tab.isContextual ||
            visibleContextGroups.contains(tab.contextGroup ?? ''))
          tab,
    ];
  }

  /// Finds an item by command tag.
  FxRibbonItem? findItem(String tag) {
    for (final tab in tabs) {
      final found = tab.findItem(tag);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Returns a copy with a toggle/check item flipped.
  FxRibbonDefinition toggled(String tag) {
    for (var tabIndex = 0; tabIndex < tabs.length; tabIndex++) {
      final tab = tabs[tabIndex];
      for (var groupIndex = 0; groupIndex < tab.groups.length; groupIndex++) {
        final group = tab.groups[groupIndex];
        for (var itemIndex = 0; itemIndex < group.items.length; itemIndex++) {
          final item = group.items[itemIndex];
          if (item.tag == tag && item.isToggleLike) {
            final nextTabs = List<FxRibbonTab>.of(tabs);
            final nextGroups = List<FxRibbonGroup>.of(tab.groups);
            final nextItems = List<FxRibbonItem>.of(group.items);
            nextItems[itemIndex] = item.toggled();
            nextGroups[groupIndex] = group.copyWith(items: nextItems);
            nextTabs[tabIndex] = tab.copyWith(groups: nextGroups);
            return copyWith(tabs: nextTabs);
          }
        }
      }
    }
    return this;
  }

  /// Resolves the definition name for [locale].
  String resolveName(Locale locale) {
    return FxRibbonLocalizedText(
      fallback: name ?? '',
      values: localizedNames,
    ).resolve(locale);
  }

  /// Converts this definition to JSON.
  Map<String, Object?> toJson() {
    return {
      'version': version,
      'projectType': projectType,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (localizedNames.isNotEmpty) 'localizedNames': localizedNames,
      if (metadata.isNotEmpty) 'metadata': metadata,
      'tabs': tabs.map((tab) => tab.toJson()).toList(),
      if (icons.isNotEmpty)
        'icons': {
          for (final entry in icons.entries) entry.key: entry.value.toJson(),
        },
    };
  }

  /// Converts this definition to a pretty-printed JSON string.
  String toJsonString() {
    return '${const JsonEncoder.withIndent('  ').convert(toJson())}\n';
  }

  /// Stable map for generators and diagnostics.
  Map<String, Object?> toTemplateMap() => toJson();

  /// Creates a modified copy.
  FxRibbonDefinition copyWith({
    String? version,
    String? projectType,
    List<FxRibbonTab>? tabs,
    Map<String, FxRibbonEmbeddedIcon>? icons,
    Object? name = _sentinel,
    Object? description = _sentinel,
    Map<String, String>? localizedNames,
    Map<String, Object?>? metadata,
  }) {
    return FxRibbonDefinition(
      version: version ?? this.version,
      projectType: projectType ?? this.projectType,
      tabs: tabs ?? this.tabs,
      icons: icons ?? this.icons,
      name: identical(name, _sentinel) ? this.name : name as String?,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      localizedNames: localizedNames ?? this.localizedNames,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FxRibbonDefinition &&
        other.version == version &&
        other.projectType == projectType &&
        listEquals(other.tabs, tabs) &&
        mapEquals(other.icons, icons) &&
        other.name == name &&
        other.description == description &&
        mapEquals(other.localizedNames, localizedNames) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    version,
    projectType,
    Object.hashAll(tabs),
    Object.hashAllUnordered(icons.entries),
    name,
    description,
    Object.hashAllUnordered(localizedNames.entries),
    Object.hashAllUnordered(metadata.entries),
  );
}

/// Base class for ribbon events.
@immutable
sealed class FxRibbonEvent {
  /// Creates a ribbon event.
  const FxRibbonEvent();
}

/// A ribbon item body was activated.
final class FxRibbonItemPressedEvent extends FxRibbonEvent {
  /// Creates an item-pressed event.
  const FxRibbonItemPressedEvent({
    required this.itemTag,
    required this.itemType,
    required this.isToggleActive,
  });

  /// Stable command tag.
  final String itemTag;

  /// Activated item type.
  final FxRibbonItemType itemType;

  /// Toggle/check state after the requested activation.
  final bool isToggleActive;
}

/// A dropdown or split-button menu item was selected.
final class FxRibbonMenuActionEvent extends FxRibbonEvent {
  /// Creates a menu action event.
  const FxRibbonMenuActionEvent({
    required this.itemTag,
    required this.menuItemTag,
  });

  /// Stable parent command tag.
  final String itemTag;

  /// Stable selected menu item tag.
  final String menuItemTag;
}

/// Active tab changed.
final class FxRibbonTabChangedEvent extends FxRibbonEvent {
  /// Creates a tab-changed event.
  const FxRibbonTabChangedEvent({required this.tabIndex, required this.tab});

  /// New visible tab index.
  final int tabIndex;

  /// New active tab.
  final FxRibbonTab tab;
}

/// Collapse state changed.
final class FxRibbonCollapseChangedEvent extends FxRibbonEvent {
  /// Creates a collapse-changed event.
  const FxRibbonCollapseChangedEvent({required this.collapsed});

  /// Requested collapsed state.
  final bool collapsed;
}

/// Selected object inside the ribbon designer.
@immutable
class FxRibbonSelection {
  /// Creates a designer selection.
  const FxRibbonSelection({
    required this.tabIndex,
    this.groupIndex,
    this.itemIndex,
    this.menuItemIndex,
  });

  /// Selected tab index.
  final int tabIndex;

  /// Selected group index.
  final int? groupIndex;

  /// Selected item index.
  final int? itemIndex;

  /// Selected menu item index.
  final int? menuItemIndex;

  /// Selection for the first tab.
  static const firstTab = FxRibbonSelection(tabIndex: 0);

  /// Whether this selection points to a group.
  bool get hasGroup => groupIndex != null;

  /// Whether this selection points to an item.
  bool get hasItem => groupIndex != null && itemIndex != null;

  /// Whether this selection points to a menu item.
  bool get hasMenuItem => hasItem && menuItemIndex != null;

  /// Stable map for diagnostics.
  Map<String, Object?> toTemplateMap() {
    return {
      'tabIndex': tabIndex,
      if (groupIndex != null) 'groupIndex': groupIndex,
      if (itemIndex != null) 'itemIndex': itemIndex,
      if (menuItemIndex != null) 'menuItemIndex': menuItemIndex,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is FxRibbonSelection &&
        other.tabIndex == tabIndex &&
        other.groupIndex == groupIndex &&
        other.itemIndex == itemIndex &&
        other.menuItemIndex == menuItemIndex;
  }

  @override
  int get hashCode =>
      Object.hash(tabIndex, groupIndex, itemIndex, menuItemIndex);
}

/// Validation severity.
enum FxRibbonValidationSeverity {
  /// Must be fixed before reliable use.
  error,

  /// Should be reviewed.
  warning,

  /// Informational note.
  info,
}

/// Stable ribbon validation code.
enum FxRibbonValidationCode {
  /// JSON could not be parsed.
  invalidJson,

  /// Root JSON value is not an object.
  invalidRoot,

  /// Unsupported schema version.
  unsupportedVersion,

  /// No tabs were defined.
  emptyTabs,

  /// A tab caption is missing.
  missingTabCaption,

  /// A contextual tab is missing its context group.
  missingContextGroup,

  /// A group caption is missing.
  missingGroupCaption,

  /// A group has no items.
  emptyGroup,

  /// An item is missing a caption.
  missingItemCaption,

  /// An item is missing its stable command tag.
  missingItemTag,

  /// A command tag is duplicated.
  duplicateItemTag,

  /// A dropdown or split button has no menu entries.
  missingMenuItems,

  /// A menu item is missing a caption.
  missingMenuItemCaption,

  /// A menu item is missing a tag.
  missingMenuItemTag,

  /// A localized text key is invalid.
  invalidLocaleTag,

  /// An item references an unknown icon key.
  unknownIconKey,
}

/// One validation issue.
@immutable
class FxRibbonValidationIssue {
  /// Creates a validation issue.
  const FxRibbonValidationIssue({
    required this.code,
    required this.severity,
    required this.path,
    required this.message,
  });

  /// Stable validation code.
  final FxRibbonValidationCode code;

  /// Severity.
  final FxRibbonValidationSeverity severity;

  /// JSON/model path.
  final String path;

  /// English diagnostic text.
  final String message;

  /// Stable map for tools.
  Map<String, Object?> toTemplateMap() {
    return {
      'code': code.name,
      'severity': severity.name,
      'path': path,
      'message': message,
    };
  }
}

/// Ribbon validation result.
@immutable
class FxRibbonValidationResult {
  /// Creates a validation result.
  const FxRibbonValidationResult(this.issues);

  /// Issues found during validation.
  final List<FxRibbonValidationIssue> issues;

  /// Whether any error was found.
  bool get hasErrors =>
      issues.any((issue) => issue.severity == FxRibbonValidationSeverity.error);

  /// Whether no issue was found.
  bool get isValid => issues.isEmpty || !hasErrors;
}

/// Validates ribbon definitions and source JSON.
class FxRibbonValidator {
  const FxRibbonValidator._();

  /// Validates a JSON source string.
  static FxRibbonValidationResult validateSource(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      return FxRibbonValidationResult([
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.invalidJson,
          severity: FxRibbonValidationSeverity.error,
          path: r'$',
          message: 'Invalid JSON: ${error.message}',
        ),
      ]);
    }
    if (decoded is! Map<String, Object?>) {
      return const FxRibbonValidationResult([
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.invalidRoot,
          severity: FxRibbonValidationSeverity.error,
          path: r'$',
          message: 'A ribbon document must be a JSON object.',
        ),
      ]);
    }
    return validateDefinition(FxRibbonDefinition.fromJson(decoded));
  }

  /// Validates a ribbon definition.
  static FxRibbonValidationResult validateDefinition(
    FxRibbonDefinition definition,
  ) {
    final issues = <FxRibbonValidationIssue>[];
    if (definition.version != FxRibbonDefinition.kSchemaVersion &&
        definition.version != FxRibbonDefinition.kJasprSchemaVersion) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.unsupportedVersion,
          severity: FxRibbonValidationSeverity.warning,
          path: r'$.version',
          message:
              'Unsupported schema version "${definition.version}". Expected 1.0 or Jaspr 2.0.',
        ),
      );
    }
    if (definition.tabs.isEmpty) {
      issues.add(
        const FxRibbonValidationIssue(
          code: FxRibbonValidationCode.emptyTabs,
          severity: FxRibbonValidationSeverity.error,
          path: r'$.tabs',
          message: 'The ribbon has no tabs.',
        ),
      );
    }
    final tags = <String>{};
    for (var ti = 0; ti < definition.tabs.length; ti++) {
      final tab = definition.tabs[ti];
      final tabPath =
          r'$.tabs['
          '$ti]';
      if (tab.caption.trim().isEmpty) {
        issues.add(
          FxRibbonValidationIssue(
            code: FxRibbonValidationCode.missingTabCaption,
            severity: FxRibbonValidationSeverity.warning,
            path: '$tabPath.caption',
            message: 'Tab $ti has no caption.',
          ),
        );
      }
      _validateLocaleMap(
        tab.localizedCaptions,
        '$tabPath.localizedCaptions',
        issues,
      );
      if (tab.isContextual && (tab.contextGroup ?? '').trim().isEmpty) {
        issues.add(
          FxRibbonValidationIssue(
            code: FxRibbonValidationCode.missingContextGroup,
            severity: FxRibbonValidationSeverity.warning,
            path: '$tabPath.contextGroup',
            message: 'Contextual tab $ti has no context group.',
          ),
        );
      }
      for (var gi = 0; gi < tab.groups.length; gi++) {
        final group = tab.groups[gi];
        final groupPath = '$tabPath.groups[$gi]';
        if (group.caption.trim().isEmpty) {
          issues.add(
            FxRibbonValidationIssue(
              code: FxRibbonValidationCode.missingGroupCaption,
              severity: FxRibbonValidationSeverity.warning,
              path: '$groupPath.caption',
              message: 'Group $gi has no caption.',
            ),
          );
        }
        if (group.items.isEmpty) {
          issues.add(
            FxRibbonValidationIssue(
              code: FxRibbonValidationCode.emptyGroup,
              severity: FxRibbonValidationSeverity.info,
              path: '$groupPath.items',
              message: 'Group $gi has no items.',
            ),
          );
        }
        _validateLocaleMap(
          group.localizedCaptions,
          '$groupPath.localizedCaptions',
          issues,
        );
        for (var ii = 0; ii < group.items.length; ii++) {
          final item = group.items[ii];
          final itemPath = '$groupPath.items[$ii]';
          _validateItem(item, itemPath, tags, definition.icons.keys, issues);
        }
      }
    }
    return FxRibbonValidationResult(List.unmodifiable(issues));
  }

  static void _validateItem(
    FxRibbonItem item,
    String path,
    Set<String> tags,
    Iterable<String> iconKeys,
    List<FxRibbonValidationIssue> issues,
  ) {
    if (item.isSeparator) {
      return;
    }
    if (item.caption.trim().isEmpty) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.missingItemCaption,
          severity: FxRibbonValidationSeverity.warning,
          path: '$path.caption',
          message: 'Ribbon item is missing a caption.',
        ),
      );
    }
    if (item.tag.trim().isEmpty) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.missingItemTag,
          severity: FxRibbonValidationSeverity.error,
          path: '$path.tag',
          message: 'Ribbon item is missing a stable command tag.',
        ),
      );
    } else if (!tags.add(item.tag)) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.duplicateItemTag,
          severity: FxRibbonValidationSeverity.error,
          path: '$path.tag',
          message: 'Duplicate ribbon command tag "${item.tag}".',
        ),
      );
    }
    if (item.hasMenu && item.menuItems.isEmpty) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.missingMenuItems,
          severity: FxRibbonValidationSeverity.info,
          path: '$path.menuItems',
          message: 'Dropdown or split button has no menu items.',
        ),
      );
    }
    final iconKey = item.iconKey;
    if (iconKey != null && iconKey.isNotEmpty && !iconKeys.contains(iconKey)) {
      issues.add(
        FxRibbonValidationIssue(
          code: FxRibbonValidationCode.unknownIconKey,
          severity: FxRibbonValidationSeverity.info,
          path: '$path.iconKey',
          message:
              'Ribbon item references icon "$iconKey", which is not embedded in the definition.',
        ),
      );
    }
    _validateLocaleMap(
      item.localizedCaptions,
      '$path.localizedCaptions',
      issues,
    );
    _validateLocaleMap(
      item.localizedTooltips,
      '$path.localizedTooltips',
      issues,
    );
    for (var mi = 0; mi < item.menuItems.length; mi++) {
      final menuItem = item.menuItems[mi];
      final menuPath = '$path.menuItems[$mi]';
      if (menuItem.isSeparator) {
        continue;
      }
      if (menuItem.caption.trim().isEmpty) {
        issues.add(
          FxRibbonValidationIssue(
            code: FxRibbonValidationCode.missingMenuItemCaption,
            severity: FxRibbonValidationSeverity.warning,
            path: '$menuPath.caption',
            message: 'Menu item is missing a caption.',
          ),
        );
      }
      if (menuItem.tag.trim().isEmpty) {
        issues.add(
          FxRibbonValidationIssue(
            code: FxRibbonValidationCode.missingMenuItemTag,
            severity: FxRibbonValidationSeverity.error,
            path: '$menuPath.tag',
            message: 'Menu item is missing a stable tag.',
          ),
        );
      }
      _validateLocaleMap(
        menuItem.localizedCaptions,
        '$menuPath.localizedCaptions',
        issues,
      );
    }
  }

  static void _validateLocaleMap(
    Map<String, String> values,
    String path,
    List<FxRibbonValidationIssue> issues,
  ) {
    for (final localeTag in values.keys) {
      if (!_localeTagPattern.hasMatch(localeTag)) {
        issues.add(
          FxRibbonValidationIssue(
            code: FxRibbonValidationCode.invalidLocaleTag,
            severity: FxRibbonValidationSeverity.warning,
            path: '$path.$localeTag',
            message: 'Locale tag "$localeTag" is not BCP-47-like.',
          ),
        );
      }
    }
  }
}

/// Built-in ribbon samples used by docs, tests, and the designer.
class FxRibbonSamples {
  const FxRibbonSamples._();

  /// Explorer-style ribbon adapted from the Jaspr reference sample.
  static FxRibbonDefinition explorer() {
    return FxRibbonDefinition(
      name: 'Explorer Ribbon',
      localizedNames: const {
        'th': 'ริบบอน Explorer',
        'ja': 'Explorer リボン',
        'ne': 'एक्सप्लोरर रिबन',
      },
      metadata: const {
        'source': 'jaspr-ribbon-toolbar examples/explorer.ribbon',
      },
      icons: const {
        'paste': FxRibbonEmbeddedIcon(
          kind: FxRibbonEmbeddedIconKind.svg,
          data:
              '<svg viewBox="0 0 24 24"><path d="M8 4h8v3h3v14H5V7h3V4zm2 2v3h4V6h-4zm-3 5v8h10V9H7z"/></svg>',
        ),
        'copy': FxRibbonEmbeddedIcon(
          kind: FxRibbonEmbeddedIconKind.svg,
          data:
              '<svg viewBox="0 0 24 24"><path d="M8 7h10v13H8V7zm-3-3h10v2H7v11H5V4z"/></svg>',
        ),
        'delete': FxRibbonEmbeddedIcon(
          kind: FxRibbonEmbeddedIconKind.svg,
          data:
              '<svg viewBox="0 0 24 24"><path d="M9 3h6l1 2h5v2H3V5h5l1-2zm-3 6h12l-1 12H7L6 9z"/></svg>',
        ),
      },
      tabs: [
        FxRibbonTab(
          caption: 'Home',
          localizedCaptions: const {'th': 'หน้าหลัก', 'ja': 'ホーム', 'ne': 'गृह'},
          keyTip: 'H',
          groups: [
            FxRibbonGroup(
              caption: 'Clipboard',
              localizedCaptions: const {
                'th': 'คลิปบอร์ด',
                'ja': 'クリップボード',
                'ne': 'क्लिपबोर्ड',
              },
              items: [
                FxRibbonItem.large(
                  caption: 'Paste',
                  tag: 'clipboard.paste',
                  iconKey: 'paste',
                  keyTip: 'V',
                  tooltipText: 'Paste from clipboard',
                  localizedCaptions: const {
                    'th': 'วาง',
                    'ja': '貼り付け',
                    'ne': 'टाँस्नुहोस्',
                  },
                  localizedTooltips: const {
                    'th': 'วางจากคลิปบอร์ด',
                    'ja': 'クリップボードから貼り付け',
                    'ne': 'क्लिपबोर्डबाट टाँस्नुहोस्',
                  },
                ),
                FxRibbonItem.small(
                  caption: 'Cut',
                  tag: 'clipboard.cut',
                  iconKey: 'copy',
                  keyTip: 'X',
                  localizedCaptions: const {
                    'th': 'ตัด',
                    'ja': '切り取り',
                    'ne': 'काट्नुहोस्',
                  },
                ),
                FxRibbonItem.small(
                  caption: 'Copy',
                  tag: 'clipboard.copy',
                  iconKey: 'copy',
                  keyTip: 'C',
                  localizedCaptions: const {
                    'th': 'คัดลอก',
                    'ja': 'コピー',
                    'ne': 'प्रतिलिपि',
                  },
                ),
                FxRibbonItem.small(
                  caption: 'Copy path',
                  tag: 'clipboard.copy_path',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'คัดลอกเส้นทาง',
                    'ja': 'パスをコピー',
                    'ne': 'पथ प्रतिलिपि',
                  },
                ),
              ],
            ),
            FxRibbonGroup(
              caption: 'Organize',
              localizedCaptions: const {
                'th': 'จัดระเบียบ',
                'ja': '整理',
                'ne': 'व्यवस्थित',
              },
              items: [
                FxRibbonItem.splitButton(
                  caption: 'Delete',
                  tag: 'organize.delete',
                  iconKey: 'delete',
                  keyTip: 'D',
                  localizedCaptions: const {
                    'th': 'ลบ',
                    'ja': '削除',
                    'ne': 'मेटाउनुहोस्',
                  },
                  menuItems: const [
                    FxRibbonMenuItem(
                      caption: 'Recycle',
                      tag: 'organize.delete.recycle',
                      localizedCaptions: {
                        'th': 'ย้ายไปถังขยะ',
                        'ja': 'ごみ箱へ',
                        'ne': 'रिसाइकलमा',
                      },
                    ),
                    FxRibbonMenuItem(
                      caption: 'Permanently delete',
                      tag: 'organize.delete.permanent',
                      localizedCaptions: {
                        'th': 'ลบถาวร',
                        'ja': '完全に削除',
                        'ne': 'स्थायी रूपमा मेटाउनुहोस्',
                      },
                    ),
                  ],
                ),
                FxRibbonItem.small(
                  caption: 'Rename',
                  tag: 'organize.rename',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'เปลี่ยนชื่อ',
                    'ja': '名前を変更',
                    'ne': 'नाम परिवर्तन',
                  },
                ),
              ],
            ),
          ],
        ),
        FxRibbonTab(
          caption: 'View',
          localizedCaptions: const {'th': 'มุมมอง', 'ja': '表示', 'ne': 'दृश्य'},
          keyTip: 'V',
          groups: [
            FxRibbonGroup(
              caption: 'Panes',
              localizedCaptions: const {
                'th': 'พาเนล',
                'ja': 'ペイン',
                'ne': 'फलक',
              },
              items: [
                FxRibbonItem.splitButton(
                  caption: 'Navigation pane',
                  tag: 'view.nav',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'แถบนำทาง',
                    'ja': 'ナビゲーション ペイン',
                    'ne': 'नेभिगेसन फलक',
                  },
                  menuItems: const [
                    FxRibbonMenuItem(
                      caption: 'Navigation pane',
                      tag: 'view.nav.toggle',
                    ),
                    FxRibbonMenuItem(
                      caption: 'Expand to open folder',
                      tag: 'view.nav.expand',
                    ),
                  ],
                ),
                FxRibbonItem.toggle(
                  caption: 'Preview pane',
                  tag: 'view.preview',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'พาเนลตัวอย่าง',
                    'ja': 'プレビュー ペイン',
                    'ne': 'पूर्वावलोकन फलक',
                  },
                ),
                FxRibbonItem.toggle(
                  caption: 'Details pane',
                  tag: 'view.details',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'พาเนลรายละเอียด',
                    'ja': '詳細ペイン',
                    'ne': 'विवरण फलक',
                  },
                ),
              ],
            ),
            FxRibbonGroup(
              caption: 'Show/hide',
              localizedCaptions: const {
                'th': 'แสดง/ซ่อน',
                'ja': '表示/非表示',
                'ne': 'देखाउनु/लुकाउनु',
              },
              items: [
                FxRibbonItem.checkBox(
                  caption: 'File name extensions',
                  tag: 'view.ext',
                  localizedCaptions: const {
                    'th': 'นามสกุลไฟล์',
                    'ja': 'ファイル名拡張子',
                    'ne': 'फाइल नाम विस्तार',
                  },
                ),
                FxRibbonItem.checkBox(
                  caption: 'Hidden items',
                  tag: 'view.hidden',
                  isChecked: true,
                  localizedCaptions: const {
                    'th': 'รายการที่ซ่อน',
                    'ja': '隠し項目',
                    'ne': 'लुकेका वस्तुहरू',
                  },
                ),
                const FxRibbonItem.separator(),
                FxRibbonItem.small(
                  caption: 'Hide selected items',
                  tag: 'view.hide',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'ซ่อนรายการที่เลือก',
                    'ja': '選択項目を非表示',
                    'ne': 'चयनित वस्तु लुकाउनुहोस्',
                  },
                ),
              ],
            ),
          ],
        ),
        FxRibbonTab.contextual(
          caption: 'Format',
          contextGroup: 'Picture Tools',
          localizedCaptions: const {'th': 'รูปแบบ', 'ja': '書式', 'ne': 'ढाँचा'},
          localizedContextGroups: const {
            'th': 'เครื่องมือรูปภาพ',
            'ja': '画像ツール',
            'ne': 'तस्बिर उपकरण',
          },
          accentColor: const Color(0xff22c55e),
          keyTip: 'JP',
          groups: [
            FxRibbonGroup(
              caption: 'Picture Styles',
              localizedCaptions: const {
                'th': 'สไตล์รูปภาพ',
                'ja': '画像スタイル',
                'ne': 'तस्बिर शैली',
              },
              items: [
                FxRibbonItem.large(
                  caption: 'Crop',
                  tag: 'pic.crop',
                  iconKey: 'copy',
                  localizedCaptions: const {
                    'th': 'ครอบตัด',
                    'ja': 'トリミング',
                    'ne': 'काटछाँट',
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

final _localeTagPattern = RegExp(r'^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$');
const Object _sentinel = Object();

Map<String, String> _stringMap(Object? raw) {
  if (raw is! Map) {
    return const {};
  }
  return Map<String, String>.unmodifiable({
    for (final entry in raw.entries)
      entry.key.toString(): entry.value?.toString() ?? '',
  });
}

Map<String, Object?> _objectMap(Object? raw) {
  if (raw is! Map) {
    return const {};
  }
  return Map<String, Object?>.unmodifiable({
    for (final entry in raw.entries) entry.key.toString(): entry.value,
  });
}

Color? _colorFromJson(Object? raw) {
  if (raw is int) {
    return Color(raw);
  }
  if (raw is String && raw.isNotEmpty) {
    final normalized = raw.startsWith('#') ? raw.substring(1) : raw;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed != null) {
      return Color(normalized.length <= 6 ? 0xff000000 | parsed : parsed);
    }
  }
  return null;
}
