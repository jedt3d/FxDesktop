import 'package:flutter/material.dart';

import 'fx_form_inputs.dart';
import 'fx_localizations.dart';
import 'fx_ribbon_icons.dart';
import 'fx_ribbon_models.dart';
import 'fx_ribbon_toolbar.dart';
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
  String _status = '';

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
    final status = _status.isEmpty
        ? localizations.ribbonDesignerStatusReady
        : _status;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCommandRow(context, localizations),
          FxRibbonToolbar(
            definition: _definition,
            icons: widget.icons,
            locale: _previewLocale,
            visibleContextGroups: visibleContextGroups,
            onDefinitionChanged: _replaceDefinition,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 260,
                  child: _buildStructure(context, localizations),
                ),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: _buildJsonPreview(context, localizations)),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                SizedBox(
                  width: 320,
                  child: _buildInspector(context, localizations, validation),
                ),
              ],
            ),
          ),
          _buildStatusRow(context, status, validation),
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
                final json = _definition.toJsonString();
                widget.onExportRequested?.call(json);
                setState(() => _status = localizations.ribbonDesignerExported);
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaneHeader(title: localizations.ribbonDesignerStructure),
          Expanded(
            child: ListView(
              children: [
                for (var ti = 0; ti < _definition.tabs.length; ti++)
                  ..._tabStructure(context, ti),
              ],
            ),
          ),
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
        icon: Icons.tab,
        label: tab.caption,
        onTap: () => _select(FxRibbonSelection(tabIndex: ti)),
      ),
      for (var gi = 0; gi < tab.groups.length; gi++) ...[
        _StructureTile(
          depth: 1,
          selected:
              _selection == FxRibbonSelection(tabIndex: ti, groupIndex: gi),
          icon: Icons.view_column,
          label: tab.groups[gi].caption,
          onTap: () => _select(FxRibbonSelection(tabIndex: ti, groupIndex: gi)),
        ),
        for (var ii = 0; ii < tab.groups[gi].items.length; ii++)
          _StructureTile(
            depth: 2,
            selected:
                _selection ==
                FxRibbonSelection(tabIndex: ti, groupIndex: gi, itemIndex: ii),
            icon: _iconForItem(tab.groups[gi].items[ii]),
            label: _labelForItem(tab.groups[gi].items[ii]),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaneHeader(title: localizations.ribbonDesignerJsonPreview),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _definition.toJsonString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInspector(
    BuildContext context,
    FxDesktopLocalizations localizations,
    FxRibbonValidationResult validation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaneHeader(title: localizations.ribbonDesignerInspector),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: _inspectorBody(context, localizations, validation),
          ),
        ),
      ],
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

  Widget _buildStatusRow(
    BuildContext context,
    String status,
    FxRibbonValidationResult validation,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final issueText = validation.issues.isEmpty
        ? ''
        : validation.issues
              .take(2)
              .map((issue) => '${issue.code.name}: ${issue.message}')
              .join('  ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(
              validation.hasErrors
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              size: 16,
              color: validation.hasErrors ? scheme.error : scheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                issueText.isEmpty ? status : issueText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StructureTile extends StatelessWidget {
  const _StructureTile({
    required this.depth,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int depth;
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: depth * 16),
        child: Icon(icon, size: 18),
      ),
      title: Text(
        label.isEmpty ? '-' : label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}

class _InspectorTextField extends StatefulWidget {
  const _InspectorTextField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

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
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        labelText: widget.label,
      ),
      onChanged: widget.onChanged,
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

IconData _iconForItem(FxRibbonItem item) {
  return switch (item.itemType) {
    FxRibbonItemType.large => Icons.crop_square,
    FxRibbonItemType.medium => Icons.table_rows_outlined,
    FxRibbonItemType.small => Icons.short_text,
    FxRibbonItemType.dropdown => Icons.arrow_drop_down_circle_outlined,
    FxRibbonItemType.splitButton => Icons.call_split_outlined,
    FxRibbonItemType.mediumDropdown => Icons.arrow_drop_down_outlined,
    FxRibbonItemType.mediumSplitButton => Icons.splitscreen_outlined,
    FxRibbonItemType.gallery => Icons.view_module_outlined,
    FxRibbonItemType.toggle => Icons.toggle_on_outlined,
    FxRibbonItemType.checkBox => Icons.check_box_outlined,
    FxRibbonItemType.separator => Icons.more_vert,
    FxRibbonItemType.columnBreak => Icons.view_column_outlined,
  };
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
