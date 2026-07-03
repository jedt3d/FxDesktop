import 'package:flutter/material.dart';

import 'fx_form_inputs.dart';
import 'fx_localizations.dart';
import 'fx_ribbon_icons.dart';
import 'fx_ribbon_models.dart';
import 'fx_ribbon_theme.dart';
import 'fx_ribbon_toolbar.dart';
import 'fx_theme_data.dart';
import 'l10n/fx_desktop_localizations.dart';

/// Embeddable visual designer for [FxRibbonDefinition].
class FxRibbonDesigner extends StatefulWidget {
  /// Creates a ribbon designer.
  const FxRibbonDesigner({
    super.key,
    this.initialDefinition,
    this.icons = const FxRibbonIconRegistry.empty(),
    this.locale,
    this.onDefinitionChanged,
    this.onSelectionChanged,
    this.onExportRequested,
  });

  /// Initial editable definition. Defaults to [FxRibbonSamples.explorer].
  final FxRibbonDefinition? initialDefinition;

  /// Runtime icon registry.
  final FxRibbonIconRegistry icons;

  /// Optional initial preview locale.
  final Locale? locale;

  /// Called when the model changes.
  final ValueChanged<FxRibbonDefinition>? onDefinitionChanged;

  /// Called when the designer selection changes.
  final ValueChanged<FxRibbonSelection>? onSelectionChanged;

  /// Called when the user requests JSON export.
  final ValueChanged<String>? onExportRequested;

  @override
  State<FxRibbonDesigner> createState() => _FxRibbonDesignerState();
}

class _FxRibbonDesignerState extends State<FxRibbonDesigner> {
  late FxRibbonDefinition _definition;
  late FxRibbonSelection _selection;
  late Locale _previewLocale;

  @override
  void initState() {
    super.initState();
    _definition = widget.initialDefinition ?? FxRibbonSamples.explorer();
    _selection = FxRibbonSelection.firstTab;
    _previewLocale = widget.locale ?? const Locale('en');
  }

  @override
  void didUpdateWidget(FxRibbonDesigner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDefinition != null &&
        widget.initialDefinition != oldWidget.initialDefinition) {
      _definition = widget.initialDefinition!;
      _selection = FxRibbonSelection.firstTab;
    }
    if (widget.locale != null && widget.locale != oldWidget.locale) {
      _previewLocale = widget.locale!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = fxDesktopLocalizationsOf(context);
    final validation = FxRibbonValidator.validateDefinition(_definition);
    final visibleContextGroups = {
      for (final tab in _definition.contextualTabs)
        if (tab.contextGroup != null) tab.contextGroup!,
    };
    final scheme = Theme.of(context).colorScheme;
    final preview = _DesignerPanel(
      title: localizations.ribbonDesignerLivePreview,
      icon: Icons.visibility_outlined,
      expandChild: false,
      bodyPadding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1160,
          height: FxRibbonDensity.regular.expandedHeight,
          child: FxRibbonToolbar(
            definition: _definition,
            icons: widget.icons,
            locale: _previewLocale,
            visibleContextGroups: visibleContextGroups,
            onDefinitionChanged: _replaceDefinition,
          ),
        ),
      ),
    );

    return Material(
      color: scheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCommandRow(context, localizations),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 260,
                    child: _buildStructure(context, localizations),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        preview,
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildJsonPreview(context, localizations),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildInspector(
                            context,
                            localizations,
                            validation,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildValidation(context, localizations, validation),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandRow(
    BuildContext context,
    FxDesktopLocalizations localizations,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              localizations.ribbonDesignerTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            _ToolbarButton(
              icon: Icons.note_add_outlined,
              label: localizations.ribbonDesignerNew,
              onPressed: _newDefinition,
            ),
            _ToolbarButton(
              icon: Icons.tab_outlined,
              label: localizations.ribbonDesignerAddTab,
              onPressed: _addTab,
            ),
            _ToolbarButton(
              icon: Icons.view_column_outlined,
              label: localizations.ribbonDesignerAddGroup,
              onPressed: _addGroup,
            ),
            _ToolbarButton(
              icon: Icons.add_box_outlined,
              label: localizations.ribbonDesignerAddItem,
              onPressed: _addItem,
            ),
            _ToolbarButton(
              icon: Icons.delete_outline,
              label: localizations.ribbonDesignerDelete,
              onPressed: _deleteSelection,
            ),
            SizedBox(
              width: 230,
              child: FxPopupMenu(
                label: localizations.ribbonDesignerPreviewLocale,
                options: [
                  localizations.galleryLanguageEnglish,
                  localizations.galleryLanguageThai,
                  localizations.galleryLanguageJapanese,
                  localizations.galleryLanguageNepali,
                ],
                selectedValue: _localeName(localizations, _previewLocale),
                onChanged: (value) {
                  setState(() {
                    _previewLocale = switch (value) {
                      String v when v == localizations.galleryLanguageThai =>
                        const Locale('th'),
                      String v
                          when v == localizations.galleryLanguageJapanese =>
                        const Locale('ja'),
                      String v when v == localizations.galleryLanguageNepali =>
                        const Locale('ne'),
                      _ => const Locale('en'),
                    };
                  });
                },
              ),
            ),
            _ToolbarButton(
              icon: Icons.ios_share_outlined,
              label: localizations.ribbonDesignerExport,
              onPressed: () {
                widget.onExportRequested?.call(_definition.toJsonString());
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(
                    content: Text(localizations.ribbonDesignerExported),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructure(
    BuildContext context,
    FxDesktopLocalizations localizations,
  ) {
    return _DesignerPanel(
      title: localizations.ribbonDesignerStructure,
      icon: Icons.account_tree_outlined,
      bodyPadding: const EdgeInsets.all(4),
      child: ListView(
        key: const ValueKey('ribbonDesignerStructureTree'),
        padding: EdgeInsets.zero,
        children: [
          for (var ti = 0; ti < _definition.tabs.length; ti++)
            ..._tabStructure(context, ti),
        ],
      ),
    );
  }

  List<Widget> _tabStructure(BuildContext context, int ti) {
    final tab = _definition.tabs[ti];
    return [
      _StructureTile(
        depth: 0,
        selected: _selection == FxRibbonSelection(tabIndex: ti),
        icon: Icons.tab_outlined,
        label: tab.caption,
        badge: tab.keyTip,
        onTap: () => _select(FxRibbonSelection(tabIndex: ti)),
      ),
      for (var gi = 0; gi < tab.groups.length; gi++) ...[
        _StructureTile(
          depth: 1,
          selected:
              _selection == FxRibbonSelection(tabIndex: ti, groupIndex: gi),
          icon: Icons.folder_outlined,
          label: tab.groups[gi].caption,
          onTap: () => _select(FxRibbonSelection(tabIndex: ti, groupIndex: gi)),
        ),
        for (var ii = 0; ii < tab.groups[gi].items.length; ii++)
          _StructureTile(
            depth: 2,
            selected:
                _selection ==
                FxRibbonSelection(tabIndex: ti, groupIndex: gi, itemIndex: ii),
            icon: null,
            label: _labelForItem(tab.groups[gi].items[ii]),
            badge: tab.groups[gi].items[ii].itemType.jsonValue,
            onTap: () => _select(
              FxRibbonSelection(tabIndex: ti, groupIndex: gi, itemIndex: ii),
            ),
          ),
      ],
    ];
  }

  Widget _buildJsonPreview(
    BuildContext context,
    FxDesktopLocalizations localizations,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return _DesignerPanel(
      title: localizations.ribbonDesignerJsonPreview,
      icon: Icons.data_object_outlined,
      bodyPadding: EdgeInsets.zero,
      child: ColoredBox(
        color: scheme.surfaceContainerLowest,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            _definition.toJsonString(),
            style: TextStyle(
              fontFamily: FxThemeData.monoFontFamily,
              // Localized caption values in the JSON can be Thai/JA/NE; fall
              // back to the UI face (then the platform) for those glyphs.
              fontFamilyFallback: const [FxThemeData.uiFontFamily],
              fontSize: 12,
              height: 17 / 12,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspector(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonValidationResult validation,
  ) {
    return _DesignerPanel(
      title: localizations.ribbonDesignerInspector,
      icon: Icons.tune_outlined,
      child: SingleChildScrollView(
        child: _inspectorBody(context, localizations, validation),
      ),
    );
  }

  Widget _buildValidation(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonValidationResult validation,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final ok = !validation.hasErrors;
    final success = Theme.of(context).brightness == Brightness.dark
        ? FxThemeData.successDark
        : FxThemeData.successLight;
    final color = ok ? success : scheme.error;
    final text = ok
        ? localizations.ribbonDesignerValidationValid
        : validation.issues
              .take(2)
              .map((issue) => '${issue.code.name}: ${issue.message}')
              .join('  ');
    return _DesignerPanel(
      title: localizations.ribbonDesignerValidation,
      icon: Icons.check_circle_outline,
      expandChild: false,
      bodyPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.error, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inspectorBody(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonValidationResult validation,
  ) {
    final tab = _selectedTab();
    final group = _selectedGroup();
    final item = _selectedItem();

    if (item != null) {
      return _itemInspector(context, localizations, item);
    }
    if (group != null) {
      return _groupInspector(context, localizations, group);
    }
    if (tab != null) {
      return _tabInspector(context, localizations, tab);
    }

    return Text(localizations.ribbonDesignerNoSelection);
  }

  Widget _tabInspector(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonTab tab,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InspectorTextField(
          label: localizations.ribbonDesignerCaption,
          value: tab.caption,
          onChanged: (value) =>
              _updateSelectedTab((current) => current.copyWith(caption: value)),
        ),
        const SizedBox(height: 10),
        _InspectorTextField(
          label: localizations.ribbonDesignerKeyTip,
          value: tab.keyTip ?? '',
          onChanged: (value) => _updateSelectedTab(
            (current) => current.copyWith(keyTip: value.isEmpty ? null : value),
          ),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.ribbonDesignerContextual),
          value: tab.isContextual,
          onChanged: (value) => _updateSelectedTab(
            (current) => current.copyWith(
              isContextual: value ?? false,
              contextGroup: value == true
                  ? current.contextGroup ?? 'Context Tools'
                  : null,
            ),
          ),
        ),
        if (tab.isContextual)
          _InspectorTextField(
            label: localizations.ribbonDesignerContextGroup,
            value: tab.contextGroup ?? '',
            onChanged: (value) => _updateSelectedTab(
              (current) => current.copyWith(contextGroup: value),
            ),
          ),
        const SizedBox(height: 10),
        _localizedCaptionEditor(
          localizations,
          tab.localizedCaptions,
          (values) => _updateSelectedTab(
            (current) => current.copyWith(localizedCaptions: values),
          ),
        ),
      ],
    );
  }

  Widget _groupInspector(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonGroup group,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InspectorTextField(
          label: localizations.ribbonDesignerCaption,
          value: group.caption,
          onChanged: (value) => _updateSelectedGroup(
            (current) => current.copyWith(caption: value),
          ),
        ),
        const SizedBox(height: 10),
        _localizedCaptionEditor(
          localizations,
          group.localizedCaptions,
          (values) => _updateSelectedGroup(
            (current) => current.copyWith(localizedCaptions: values),
          ),
        ),
      ],
    );
  }

  Widget _itemInspector(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonItem item,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InspectorTextField(
          label: localizations.ribbonDesignerCaption,
          value: item.caption,
          onChanged: (value) => _updateSelectedItem(
            (current) => current.copyWith(caption: value),
          ),
        ),
        const SizedBox(height: 10),
        _InspectorTextField(
          label: localizations.ribbonDesignerCommandTag,
          value: item.tag,
          mono: true,
          onChanged: (value) =>
              _updateSelectedItem((current) => current.copyWith(tag: value)),
        ),
        const SizedBox(height: 10),
        FxPopupMenu(
          label: localizations.ribbonDesignerItemType,
          options: _itemTypeOptions(localizations),
          selectedValue: _itemTypeLabel(localizations, item.itemType),
          onChanged: (value) {
            final nextType = _itemTypeFromLabel(localizations, value);
            _updateSelectedItem((current) => _rebuildItemAs(current, nextType));
          },
        ),
        const SizedBox(height: 10),
        _InspectorTextField(
          label: localizations.ribbonDesignerTooltip,
          value: item.tooltipText ?? '',
          onChanged: (value) => _updateSelectedItem(
            (current) =>
                current.copyWith(tooltipText: value.isEmpty ? null : value),
          ),
        ),
        const SizedBox(height: 10),
        _InspectorTextField(
          label: localizations.ribbonDesignerIconKey,
          value: item.iconKey ?? '',
          mono: true,
          onChanged: (value) => _updateSelectedItem(
            (current) =>
                current.copyWith(iconKey: value.isEmpty ? null : value),
          ),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.ribbonDesignerEnabled),
          value: item.isEnabled,
          onChanged: item.isSeparator
              ? null
              : (value) => _updateSelectedItem(
                  (current) => current.copyWith(isEnabled: value ?? true),
                ),
        ),
        if (item.isToggleLike)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(localizations.ribbonDesignerChecked),
            value: item.isToggleActive,
            onChanged: (value) => _updateSelectedItem(
              (current) => current.copyWith(isToggleActive: value ?? false),
            ),
          ),
        const SizedBox(height: 10),
        _localizedCaptionEditor(
          localizations,
          item.localizedCaptions,
          (values) => _updateSelectedItem(
            (current) => current.copyWith(localizedCaptions: values),
          ),
        ),
      ],
    );
  }

  Widget _localizedCaptionEditor(
    FxDesktopLocalizations localizations,
    Map<String, String> values,
    ValueChanged<Map<String, String>> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.ribbonDesignerLocalizedCaptions,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _InspectorTextField(
          label: localizations.galleryLanguageThai,
          value: values['th'] ?? '',
          onChanged: (value) => onChanged(_withLocale(values, 'th', value)),
        ),
        const SizedBox(height: 8),
        _InspectorTextField(
          label: localizations.galleryLanguageJapanese,
          value: values['ja'] ?? '',
          onChanged: (value) => onChanged(_withLocale(values, 'ja', value)),
        ),
        const SizedBox(height: 8),
        _InspectorTextField(
          label: localizations.galleryLanguageNepali,
          value: values['ne'] ?? '',
          onChanged: (value) => onChanged(_withLocale(values, 'ne', value)),
        ),
      ],
    );
  }

  void _select(FxRibbonSelection selection) {
    setState(() => _selection = selection);
    widget.onSelectionChanged?.call(selection);
  }

  void _replaceDefinition(FxRibbonDefinition definition) {
    setState(() => _definition = definition);
    widget.onDefinitionChanged?.call(definition);
  }

  void _mutate(FxRibbonDefinition Function(FxRibbonDefinition current) change) {
    final next = change(_definition);
    _replaceDefinition(next);
  }

  void _newDefinition() {
    _replaceDefinition(
      const FxRibbonDefinition(
        name: 'New Ribbon',
        tabs: [
          FxRibbonTab(
            caption: 'Home',
            groups: [FxRibbonGroup(caption: 'New group', items: [])],
          ),
        ],
      ),
    );
    _select(FxRibbonSelection.firstTab);
  }

  void _addTab() {
    _mutate(
      (current) => current.copyWith(
        tabs: [
          ...current.tabs,
          const FxRibbonTab(caption: 'New tab', groups: []),
        ],
      ),
    );
    _select(FxRibbonSelection(tabIndex: _definition.tabs.length - 1));
  }

  void _addGroup() {
    final ti = _selection.tabIndex
        .clamp(0, _definition.tabs.length - 1)
        .toInt();
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      final tab = tabs[ti];
      tabs[ti] = tab.copyWith(
        groups: [
          ...tab.groups,
          const FxRibbonGroup(caption: 'New group', items: []),
        ],
      );
      return current.copyWith(tabs: tabs);
    });
    _select(
      FxRibbonSelection(
        tabIndex: ti,
        groupIndex: _definition.tabs[ti].groups.length - 1,
      ),
    );
  }

  void _addItem() {
    final ti = _selection.tabIndex
        .clamp(0, _definition.tabs.length - 1)
        .toInt();
    final tab = _definition.tabs[ti];
    final gi = (_selection.groupIndex ?? 0)
        .clamp(0, tab.groups.isEmpty ? 0 : tab.groups.length - 1)
        .toInt();
    if (tab.groups.isEmpty) {
      _addGroup();
    }
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      final groups = List<FxRibbonGroup>.of(tabs[ti].groups);
      final group = groups[gi];
      groups[gi] = group.copyWith(
        items: [
          ...group.items,
          FxRibbonItem.large(caption: 'New', tag: 'new'),
        ],
      );
      tabs[ti] = tabs[ti].copyWith(groups: groups);
      return current.copyWith(tabs: tabs);
    });
    _select(
      FxRibbonSelection(
        tabIndex: ti,
        groupIndex: gi,
        itemIndex: _definition.tabs[ti].groups[gi].items.length - 1,
      ),
    );
  }

  void _deleteSelection() {
    if (_definition.tabs.isEmpty) {
      return;
    }
    final selection = _selection;
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      if (selection.hasItem) {
        final groups = List<FxRibbonGroup>.of(tabs[selection.tabIndex].groups);
        final group = groups[selection.groupIndex!];
        final items = List<FxRibbonItem>.of(group.items)
          ..removeAt(selection.itemIndex!);
        groups[selection.groupIndex!] = group.copyWith(items: items);
        tabs[selection.tabIndex] = tabs[selection.tabIndex].copyWith(
          groups: groups,
        );
      } else if (selection.hasGroup) {
        final groups = List<FxRibbonGroup>.of(tabs[selection.tabIndex].groups)
          ..removeAt(selection.groupIndex!);
        tabs[selection.tabIndex] = tabs[selection.tabIndex].copyWith(
          groups: groups,
        );
      } else if (tabs.length > 1) {
        tabs.removeAt(selection.tabIndex);
      }
      return current.copyWith(tabs: tabs);
    });
    _select(FxRibbonSelection(tabIndex: 0));
  }

  FxRibbonTab? _selectedTab() {
    if (_selection.tabIndex < 0 ||
        _selection.tabIndex >= _definition.tabs.length) {
      return null;
    }
    return _definition.tabs[_selection.tabIndex];
  }

  FxRibbonGroup? _selectedGroup() {
    final tab = _selectedTab();
    final groupIndex = _selection.groupIndex;
    if (tab == null || groupIndex == null || groupIndex >= tab.groups.length) {
      return null;
    }
    return tab.groups[groupIndex];
  }

  FxRibbonItem? _selectedItem() {
    final group = _selectedGroup();
    final itemIndex = _selection.itemIndex;
    if (group == null || itemIndex == null || itemIndex >= group.items.length) {
      return null;
    }
    return group.items[itemIndex];
  }

  void _updateSelectedTab(FxRibbonTab Function(FxRibbonTab current) change) {
    final ti = _selection.tabIndex;
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      tabs[ti] = change(tabs[ti]);
      return current.copyWith(tabs: tabs);
    });
  }

  void _updateSelectedGroup(
    FxRibbonGroup Function(FxRibbonGroup current) change,
  ) {
    final ti = _selection.tabIndex;
    final gi = _selection.groupIndex!;
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      final groups = List<FxRibbonGroup>.of(tabs[ti].groups);
      groups[gi] = change(groups[gi]);
      tabs[ti] = tabs[ti].copyWith(groups: groups);
      return current.copyWith(tabs: tabs);
    });
  }

  void _updateSelectedItem(FxRibbonItem Function(FxRibbonItem current) change) {
    final ti = _selection.tabIndex;
    final gi = _selection.groupIndex!;
    final ii = _selection.itemIndex!;
    _mutate((current) {
      final tabs = List<FxRibbonTab>.of(current.tabs);
      final groups = List<FxRibbonGroup>.of(tabs[ti].groups);
      final items = List<FxRibbonItem>.of(groups[gi].items);
      items[ii] = change(items[ii]);
      groups[gi] = groups[gi].copyWith(items: items);
      tabs[ti] = tabs[ti].copyWith(groups: groups);
      return current.copyWith(tabs: tabs);
    });
  }

  String _localeName(FxDesktopLocalizations localizations, Locale locale) {
    return switch (locale.languageCode) {
      'th' => localizations.galleryLanguageThai,
      'ja' => localizations.galleryLanguageJapanese,
      'ne' => localizations.galleryLanguageNepali,
      _ => localizations.galleryLanguageEnglish,
    };
  }
}

/// DS card panel: rounded (8px) surface with an uppercase icon header on a
/// surface-container-low strip. Matches `components/ribbon/FxRibbonDesigner.jsx`.
class _DesignerPanel extends StatelessWidget {
  const _DesignerPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.bodyPadding = const EdgeInsets.all(12),
    this.expandChild = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final EdgeInsetsGeometry bodyPadding;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Padding(padding: bodyPadding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        height: 1.0,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (expandChild) Expanded(child: body) else body,
          ],
        ),
      ),
    );
  }
}

/// Compact icon action used in the command bar / panel headers.
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 2),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
    );
  }
}

/// DS structure tree row: 26px, hover / selected (primary @ 12%) states,
/// primary text + icon when selected, optional mono badge (key tip / kind).
class _StructureTile extends StatefulWidget {
  const _StructureTile({
    required this.depth,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final int depth;
  final bool selected;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  State<_StructureTile> createState() => _StructureTileState();
}

class _StructureTileState extends State<_StructureTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final background = selected
        ? scheme.primary.withValues(alpha: 0.12)
        : _hover
        ? scheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 26,
          padding: EdgeInsetsDirectional.only(
            start: 8 + widget.depth * 16,
            end: 8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 15,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  widget.label.isEmpty ? '(untitled)' : widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.0,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              if (widget.badge != null && widget.badge!.isNotEmpty)
                Text(
                  widget.badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: FxThemeData.monoFontFamily,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DS inspector field: uppercase micro-label over a compact 28px control box
/// (radius 4, outline-variant border, control-bg fill). Editable.
class _InspectorTextField extends StatefulWidget {
  const _InspectorTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.mono = false,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool mono;

  @override
  State<_InspectorTextField> createState() => _InspectorTextFieldState();
}

class _InspectorTextFieldState extends State<_InspectorTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_InspectorTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.4,
              height: 1.0,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 12.5,
            fontFamily: widget.mono ? FxThemeData.monoFontFamily : null,
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: scheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

Map<String, String> _withLocale(
  Map<String, String> values,
  String locale,
  String value,
) {
  final next = Map<String, String>.of(values);
  if (value.isEmpty) {
    next.remove(locale);
  } else {
    next[locale] = value;
  }
  return next;
}

String _labelForItem(FxRibbonItem item) {
  if (item.isSeparator) {
    return 'Separator';
  }
  if (item.isColumnBreak) {
    return 'Column break';
  }
  return item.caption;
}

List<String> _itemTypeOptions(FxDesktopLocalizations localizations) {
  return [
    localizations.ribbonItemTypeLarge,
    localizations.ribbonItemTypeSmall,
    localizations.ribbonItemTypeMedium,
    localizations.ribbonItemTypeDropdown,
    localizations.ribbonItemTypeSplitButton,
    localizations.ribbonItemTypeMediumDropdown,
    localizations.ribbonItemTypeMediumSplitButton,
    localizations.ribbonItemTypeGallery,
    localizations.ribbonItemTypeToggle,
    localizations.ribbonItemTypeCheckBox,
    localizations.ribbonItemTypeSeparator,
    localizations.ribbonItemTypeColumnBreak,
  ];
}

String _itemTypeLabel(
  FxDesktopLocalizations localizations,
  FxRibbonItemType type,
) {
  return switch (type) {
    FxRibbonItemType.large => localizations.ribbonItemTypeLarge,
    FxRibbonItemType.small => localizations.ribbonItemTypeSmall,
    FxRibbonItemType.medium => localizations.ribbonItemTypeMedium,
    FxRibbonItemType.dropdown => localizations.ribbonItemTypeDropdown,
    FxRibbonItemType.splitButton => localizations.ribbonItemTypeSplitButton,
    FxRibbonItemType.mediumDropdown =>
      localizations.ribbonItemTypeMediumDropdown,
    FxRibbonItemType.mediumSplitButton =>
      localizations.ribbonItemTypeMediumSplitButton,
    FxRibbonItemType.gallery => localizations.ribbonItemTypeGallery,
    FxRibbonItemType.toggle => localizations.ribbonItemTypeToggle,
    FxRibbonItemType.checkBox => localizations.ribbonItemTypeCheckBox,
    FxRibbonItemType.separator => localizations.ribbonItemTypeSeparator,
    FxRibbonItemType.columnBreak => localizations.ribbonItemTypeColumnBreak,
  };
}

FxRibbonItemType _itemTypeFromLabel(
  FxDesktopLocalizations localizations,
  String? label,
) {
  if (label == localizations.ribbonItemTypeSmall) {
    return FxRibbonItemType.small;
  }
  if (label == localizations.ribbonItemTypeMedium) {
    return FxRibbonItemType.medium;
  }
  if (label == localizations.ribbonItemTypeDropdown) {
    return FxRibbonItemType.dropdown;
  }
  if (label == localizations.ribbonItemTypeSplitButton) {
    return FxRibbonItemType.splitButton;
  }
  if (label == localizations.ribbonItemTypeMediumDropdown) {
    return FxRibbonItemType.mediumDropdown;
  }
  if (label == localizations.ribbonItemTypeMediumSplitButton) {
    return FxRibbonItemType.mediumSplitButton;
  }
  if (label == localizations.ribbonItemTypeGallery) {
    return FxRibbonItemType.gallery;
  }
  if (label == localizations.ribbonItemTypeToggle) {
    return FxRibbonItemType.toggle;
  }
  if (label == localizations.ribbonItemTypeCheckBox) {
    return FxRibbonItemType.checkBox;
  }
  if (label == localizations.ribbonItemTypeSeparator) {
    return FxRibbonItemType.separator;
  }
  if (label == localizations.ribbonItemTypeColumnBreak) {
    return FxRibbonItemType.columnBreak;
  }
  return FxRibbonItemType.large;
}

FxRibbonItem _rebuildItemAs(FxRibbonItem item, FxRibbonItemType type) {
  if (type == FxRibbonItemType.separator) {
    return const FxRibbonItem.separator();
  }
  if (type == FxRibbonItemType.columnBreak) {
    return const FxRibbonItem.columnBreak();
  }
  return FxRibbonItem(
    caption: item.caption,
    tag: item.tag.isEmpty ? 'new' : item.tag,
    itemType: type,
    isEnabled: item.isEnabled,
    isToggleActive: item.isToggleActive,
    tooltipText: item.tooltipText,
    iconKey: type == FxRibbonItemType.checkBox ? null : item.iconKey,
    keyTip: item.keyTip,
    menuItems:
        type == FxRibbonItemType.dropdown ||
            type == FxRibbonItemType.splitButton ||
            type == FxRibbonItemType.mediumDropdown ||
            type == FxRibbonItemType.mediumSplitButton ||
            type == FxRibbonItemType.gallery
        ? item.menuItems
        : const [],
    selectedMenuItemTag: type == FxRibbonItemType.gallery
        ? item.selectedMenuItemTag
        : null,
    semanticLabel: item.semanticLabel,
    localizedCaptions: item.localizedCaptions,
    localizedTooltips: item.localizedTooltips,
    localizedSemanticLabels: item.localizedSemanticLabels,
  );
}
