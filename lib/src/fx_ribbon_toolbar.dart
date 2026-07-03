import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fx_localizations.dart';
import 'l10n/fx_desktop_localizations.dart';
import 'fx_ribbon_icons.dart';
import 'fx_ribbon_models.dart';
import 'fx_ribbon_theme.dart';

/// Flutter-native Office-style ribbon toolbar for desktop and web.
class FxRibbonToolbar extends StatefulWidget {
  /// Creates a ribbon toolbar.
  const FxRibbonToolbar({
    super.key,
    required this.definition,
    this.icons = const FxRibbonIconRegistry.empty(),
    this.activeTabIndex = 0,
    this.collapsed = false,
    this.visibleContextGroups = const {},
    this.density,
    this.interactionMode = FxRibbonInteractionMode.auto,
    this.locale,
    this.onEvent,
    this.onDefinitionChanged,
    this.onTabChanged,
    this.onCollapsedChanged,
  });

  /// Ribbon definition.
  final FxRibbonDefinition definition;

  /// Runtime icon registry. Runtime entries override embedded definition icons.
  final FxRibbonIconRegistry icons;

  /// Initial or controlled visible active tab index.
  final int activeTabIndex;

  /// Initial or controlled collapse state.
  final bool collapsed;

  /// Context groups whose contextual tabs should be visible.
  final Set<String> visibleContextGroups;

  /// Optional density override.
  final FxRibbonDensity? density;

  /// Pointer interaction mode.
  final FxRibbonInteractionMode interactionMode;

  /// Optional locale override for preview/testing.
  final Locale? locale;

  /// Semantic ribbon event callback.
  final ValueChanged<FxRibbonEvent>? onEvent;

  /// Called when internal toggle/check state changes.
  final ValueChanged<FxRibbonDefinition>? onDefinitionChanged;

  /// Called when active visible tab changes.
  final ValueChanged<int>? onTabChanged;

  /// Called when collapsed state changes.
  final ValueChanged<bool>? onCollapsedChanged;

  @override
  State<FxRibbonToolbar> createState() => _FxRibbonToolbarState();
}

class _FxRibbonToolbarState extends State<FxRibbonToolbar> {
  late FxRibbonDefinition _definition;
  late int _activeTabIndex;
  late bool _collapsed;
  bool _showKeyTips = false;
  PointerDeviceKind? _lastPointerKind;

  @override
  void initState() {
    super.initState();
    _definition = widget.definition;
    _activeTabIndex = widget.activeTabIndex;
    _collapsed = widget.collapsed;
  }

  @override
  void didUpdateWidget(FxRibbonToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.definition != oldWidget.definition) {
      _definition = widget.definition;
    }
    if (widget.activeTabIndex != oldWidget.activeTabIndex) {
      _activeTabIndex = widget.activeTabIndex;
    }
    if (widget.collapsed != oldWidget.collapsed) {
      _collapsed = widget.collapsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ribbonTheme = FxRibbonThemeData.of(context);
    final density = widget.density ?? ribbonTheme.density;
    final interactionMode = _effectiveInteractionMode();
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = fxDesktopLocalizationsOf(context);
    final visibleTabs = _definition.visibleTabs(widget.visibleContextGroups);
    if (_activeTabIndex >= visibleTabs.length) {
      _activeTabIndex = visibleTabs.isEmpty ? 0 : visibleTabs.length - 1;
    }
    final activeTab = visibleTabs.isEmpty ? null : visibleTabs[_activeTabIndex];
    final touchMode = interactionMode == FxRibbonInteractionMode.touch;
    final double effectiveHeight = _collapsed
        ? (touchMode
              ? math.max(44.0, density.collapsedHeight)
              : density.collapsedHeight)
        : (touchMode
              ? math.max(
                  FxRibbonDensity.comfortable.expandedHeight,
                  density.expandedHeight,
                )
              : density.expandedHeight);

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.f6): _FxRibbonToggleKeyTipsIntent(),
        SingleActivator(LogicalKeyboardKey.escape):
            _FxRibbonHideKeyTipsIntent(),
      },
      child: Actions(
        actions: {
          _FxRibbonToggleKeyTipsIntent:
              CallbackAction<_FxRibbonToggleKeyTipsIntent>(
                onInvoke: (_) {
                  setState(() => _showKeyTips = !_showKeyTips);
                  return null;
                },
              ),
          _FxRibbonHideKeyTipsIntent:
              CallbackAction<_FxRibbonHideKeyTipsIntent>(
                onInvoke: (_) {
                  setState(() => _showKeyTips = false);
                  return null;
                },
              ),
        },
        child: FocusTraversalGroup(
          child: Listener(
            onPointerDown: (event) {
              if (widget.interactionMode == FxRibbonInteractionMode.auto) {
                setState(() => _lastPointerKind = event.kind);
              }
            },
            child: Semantics(
              container: true,
              label: localizations.ribbonToolbarSemantics,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ribbonTheme.resolvedBackground(colorScheme),
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: SizedBox(
                  height: effectiveHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTabStrip(
                        context,
                        visibleTabs,
                        ribbonTheme,
                        colorScheme,
                        localizations,
                        density,
                      ),
                      if (!_collapsed)
                        Expanded(
                          child: activeTab == null
                              ? Center(child: Text(localizations.ribbonNoTabs))
                              : _buildContent(
                                  context,
                                  activeTab,
                                  density,
                                  interactionMode,
                                  ribbonTheme,
                                  colorScheme,
                                ),
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
  }

  Widget _buildTabStrip(
    BuildContext context,
    List<FxRibbonTab> visibleTabs,
    FxRibbonThemeData ribbonTheme,
    ColorScheme colorScheme,
    FxDesktopLocalizations localizations,
    FxRibbonDensity density,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ribbonTheme.resolvedTabStrip(colorScheme),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SizedBox(
        height: density.collapsedHeight,
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent || visibleTabs.isEmpty) {
              return KeyEventResult.ignored;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _changeTab(
                (_activeTabIndex + 1) % visibleTabs.length,
                visibleTabs,
              );
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _changeTab(
                (_activeTabIndex - 1 + visibleTabs.length) % visibleTabs.length,
                visibleTabs,
              );
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Row(
            children: [
              _ApplicationRibbonButton(
                label:
                    _definition.metadata['applicationButtonLabel']
                        ?.toString() ??
                    'File',
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < visibleTabs.length; index++)
                        _RibbonTabButton(
                          tab: visibleTabs[index],
                          selected: index == _activeTabIndex,
                          keyTip: _keyTipForTab(visibleTabs[index], index),
                          showKeyTip: _showKeyTips,
                          locale: _effectiveLocale(context),
                          theme: ribbonTheme,
                          onPressed: () => _changeTab(index, visibleTabs),
                          onDoubleTap: _toggleCollapsed,
                        ),
                    ],
                  ),
                ),
              ),
              Tooltip(
                message: _collapsed
                    ? localizations.ribbonExpand
                    : localizations.ribbonCollapse,
                child: SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    iconSize: 17,
                    onPressed: _toggleCollapsed,
                    icon: Icon(
                      _collapsed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Icon(
                  Icons.help,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FxRibbonTab tab,
    FxRibbonDensity density,
    FxRibbonInteractionMode interactionMode,
    FxRibbonThemeData ribbonTheme,
    ColorScheme colorScheme,
  ) {
    final embeddedIcons = FxRibbonIconRegistry.fromEmbedded(_definition.icons);
    final icons = embeddedIcons.merge(widget.icons);
    final locale = _effectiveLocale(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var groupIndex = 0; groupIndex < tab.groups.length; groupIndex++)
            _RibbonGroupView(
              group: tab.groups[groupIndex],
              icons: icons,
              locale: locale,
              density: density,
              interactionMode: interactionMode,
              ribbonTheme: ribbonTheme,
              colorScheme: colorScheme,
              showKeyTips: _showKeyTips,
              onPressed: _handleItemPressed,
              onMenuItemPressed: _handleMenuItemPressed,
            ),
        ],
      ),
    );
  }

  FxRibbonInteractionMode _effectiveInteractionMode() {
    if (widget.interactionMode != FxRibbonInteractionMode.auto) {
      return widget.interactionMode;
    }
    return _lastPointerKind == PointerDeviceKind.touch
        ? FxRibbonInteractionMode.touch
        : FxRibbonInteractionMode.mouse;
  }

  Locale _effectiveLocale(BuildContext context) {
    return widget.locale ??
        Localizations.maybeLocaleOf(context) ??
        const Locale('en');
  }

  void _changeTab(int index, List<FxRibbonTab> visibleTabs) {
    setState(() {
      _activeTabIndex = index;
      _showKeyTips = false;
    });
    widget.onTabChanged?.call(index);
    widget.onEvent?.call(
      FxRibbonTabChangedEvent(tabIndex: index, tab: visibleTabs[index]),
    );
  }

  void _toggleCollapsed() {
    setState(() {
      _collapsed = !_collapsed;
      _showKeyTips = false;
    });
    widget.onCollapsedChanged?.call(_collapsed);
    widget.onEvent?.call(FxRibbonCollapseChangedEvent(collapsed: _collapsed));
  }

  void _handleItemPressed(FxRibbonItem item) {
    var nextActive = item.isToggleActive;
    if (item.isToggleLike) {
      nextActive = !item.isToggleActive;
      final nextDefinition = _definition.toggled(item.tag);
      setState(() => _definition = nextDefinition);
      widget.onDefinitionChanged?.call(nextDefinition);
    } else {
      setState(() => _showKeyTips = false);
    }
    widget.onEvent?.call(
      FxRibbonItemPressedEvent(
        itemTag: item.tag,
        itemType: item.itemType,
        isToggleActive: nextActive,
      ),
    );
  }

  void _handleMenuItemPressed(FxRibbonItem item, FxRibbonMenuItem menuItem) {
    setState(() => _showKeyTips = false);
    widget.onEvent?.call(
      FxRibbonMenuActionEvent(itemTag: item.tag, menuItemTag: menuItem.tag),
    );
  }

  String _keyTipForTab(FxRibbonTab tab, int index) {
    final explicit = tab.keyTip;
    if (explicit != null && explicit.isNotEmpty) {
      return explicit.toUpperCase();
    }
    final caption = tab.caption.trim();
    if (caption.isNotEmpty) {
      return caption.characters.first.toUpperCase();
    }
    return '${index + 1}';
  }
}

class _RibbonGroupView extends StatelessWidget {
  const _RibbonGroupView({
    required this.group,
    required this.icons,
    required this.locale,
    required this.density,
    required this.interactionMode,
    required this.ribbonTheme,
    required this.colorScheme,
    required this.showKeyTips,
    required this.onPressed,
    required this.onMenuItemPressed,
  });

  final FxRibbonGroup group;
  final FxRibbonIconRegistry icons;
  final Locale locale;
  final FxRibbonDensity density;
  final FxRibbonInteractionMode interactionMode;
  final FxRibbonThemeData ribbonTheme;
  final ColorScheme colorScheme;
  final bool showKeyTips;
  final ValueChanged<FxRibbonItem> onPressed;
  final void Function(FxRibbonItem item, FxRibbonMenuItem menuItem)
  onMenuItemPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = fxDesktopLocalizationsOf(context);
    final groupCaption = group.resolveCaption(locale);
    return Semantics(
      container: true,
      label: localizations.ribbonGroupSemantics(groupCaption),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ribbonTheme.resolvedGroupBackground(colorScheme),
          border: BorderDirectional(
            end: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 6, 2),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: _buildItemFlow(context)),
              const SizedBox(height: 1),
              Text(
                groupCaption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemFlow(BuildContext context) {
    final children = <Widget>[];
    var index = 0;
    while (index < group.items.length) {
      final item = group.items[index];
      if (item.isSeparator) {
        children.add(
          VerticalDivider(
            width: 7,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
        );
        index++;
        continue;
      }
      if (item.isColumnBreak) {
        index++;
        continue;
      }
      if (_isRowRibbonItem(item)) {
        final batch = <FxRibbonItem>[];
        while (index < group.items.length &&
            _isRowRibbonItem(group.items[index]) &&
            batch.length < 3) {
          batch.add(group.items[index]);
          index++;
        }
        final columnWidth = _rowColumnWidth(batch, locale);
        children.add(
          SizedBox(
            width: columnWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final batched in batch)
                  SizedBox(
                    width: columnWidth,
                    child: _RibbonItemButton(
                      item: batched,
                      icon: icons[batched.iconKey],
                      locale: locale,
                      density: density,
                      interactionMode: interactionMode,
                      ribbonTheme: ribbonTheme,
                      compact: true,
                      showKeyTip: showKeyTips,
                      onPressed: onPressed,
                      onMenuItemPressed: onMenuItemPressed,
                    ),
                  ),
              ],
            ),
          ),
        );
        continue;
      }
      if (item.itemType == FxRibbonItemType.gallery) {
        children.add(
          _RibbonGalleryView(
            item: item,
            locale: locale,
            showKeyTip: showKeyTips,
            onMenuItemPressed: onMenuItemPressed,
          ),
        );
        index++;
        continue;
      }
      children.add(
        _RibbonItemButton(
          item: item,
          icon: icons[item.iconKey],
          locale: locale,
          density: density,
          interactionMode: interactionMode,
          ribbonTheme: ribbonTheme,
          compact: false,
          showKeyTip: showKeyTips,
          onPressed: onPressed,
          onMenuItemPressed: onMenuItemPressed,
        ),
      );
      index++;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          children[i],
        ],
      ],
    );
  }
}

class _RibbonItemButton extends StatelessWidget {
  const _RibbonItemButton({
    required this.item,
    required this.icon,
    required this.locale,
    required this.density,
    required this.interactionMode,
    required this.ribbonTheme,
    required this.compact,
    required this.showKeyTip,
    required this.onPressed,
    required this.onMenuItemPressed,
  });

  final FxRibbonItem item;
  final FxRibbonIconSource? icon;
  final Locale locale;
  final FxRibbonDensity density;
  final FxRibbonInteractionMode interactionMode;
  final FxRibbonThemeData ribbonTheme;
  final bool compact;
  final bool showKeyTip;
  final ValueChanged<FxRibbonItem> onPressed;
  final void Function(FxRibbonItem item, FxRibbonMenuItem menuItem)
  onMenuItemPressed;

  @override
  Widget build(BuildContext context) {
    final caption = item.resolveCaption(locale);
    final tooltip = item.resolveTooltip(locale);
    final localizations = fxDesktopLocalizationsOf(context);
    final interactive = item.isEnabled;
    final command = _isDropdownButton(item)
        ? _menuButton(context, caption)
        : _isSplitButton(item)
        ? _splitButton(context, caption)
        : _commandButton(context, caption);

    return Tooltip(
      message: tooltip ?? caption,
      child: Semantics(
        button: item.itemType != FxRibbonItemType.checkBox,
        checked: item.itemType == FxRibbonItemType.checkBox
            ? item.isToggleActive
            : null,
        toggled: item.itemType == FxRibbonItemType.toggle
            ? item.isToggleActive
            : null,
        enabled: interactive,
        label: item.resolveSemanticLabel(locale),
        hint: item.hasMenu ? localizations.ribbonOpenMenu : null,
        child: command,
      ),
    );
  }

  Widget _commandButton(BuildContext context, String caption) {
    return _RibbonCommandChrome(
      caption: caption,
      item: item,
      icon: icon,
      locale: locale,
      density: density,
      interactionMode: interactionMode,
      ribbonTheme: ribbonTheme,
      compact: compact,
      showKeyTip: showKeyTip,
      onPressed: item.isEnabled ? () => onPressed(item) : null,
    );
  }

  Widget _menuButton(BuildContext context, String caption) {
    return MenuAnchor(
      menuChildren: _menuChildren(context),
      builder: (context, controller, child) {
        return _RibbonCommandChrome(
          caption: caption,
          item: item,
          icon: icon,
          locale: locale,
          density: density,
          interactionMode: interactionMode,
          ribbonTheme: ribbonTheme,
          compact: compact,
          trailing: const Icon(Icons.arrow_drop_down, size: 16),
          showKeyTip: showKeyTip,
          onPressed: item.isEnabled ? controller.open : null,
        );
      },
    );
  }

  Widget _splitButton(BuildContext context, String caption) {
    final minHeight = _minTargetHeight(density, interactionMode);
    final largeHeight = interactionMode == FxRibbonInteractionMode.touch
        ? 100.0
        : 68.0;
    final arrowWidth = interactionMode == FxRibbonInteractionMode.touch
        ? 30.0
        : compact
        ? 16.0
        : 20.0;
    if (compact) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : _rowColumnWidth([item], locale);
          return SizedBox(
            width: width,
            height: minHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(ribbonTheme.borderRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RibbonCommandChrome(
                      caption: caption,
                      item: item,
                      icon: icon,
                      locale: locale,
                      density: density,
                      interactionMode: interactionMode,
                      ribbonTheme: ribbonTheme,
                      compact: true,
                      borderless: true,
                      showKeyTip: showKeyTip,
                      onPressed: item.isEnabled ? () => onPressed(item) : null,
                    ),
                  ),
                  MenuAnchor(
                    menuChildren: _menuChildren(context),
                    builder: (context, controller, child) {
                      return InkWell(
                        onTap: item.isEnabled ? controller.open : null,
                        child: SizedBox(
                          width: arrowWidth,
                          height: minHeight,
                          child: const Icon(Icons.arrow_drop_down, size: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return IntrinsicHeight(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(ribbonTheme.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RibbonCommandChrome(
              caption: caption,
              item: item,
              icon: icon,
              locale: locale,
              density: density,
              interactionMode: interactionMode,
              ribbonTheme: ribbonTheme,
              compact: compact,
              borderless: true,
              showKeyTip: showKeyTip,
              onPressed: item.isEnabled ? () => onPressed(item) : null,
            ),
            MenuAnchor(
              menuChildren: _menuChildren(context),
              builder: (context, controller, child) {
                return InkWell(
                  onTap: item.isEnabled ? controller.open : null,
                  child: SizedBox(
                    width: arrowWidth,
                    height: compact ? minHeight : largeHeight,
                    child: const Icon(Icons.arrow_drop_down, size: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _menuChildren(BuildContext context) {
    if (item.menuItems.isEmpty) {
      return [
        MenuItemButton(
          onPressed: null,
          child: Text(fxDesktopLocalizationsOf(context).ribbonMenuEmpty),
        ),
      ];
    }
    return [
      for (final menuItem in item.menuItems)
        if (menuItem.isSeparator)
          const PopupMenuDivider()
        else
          MenuItemButton(
            onPressed: item.isEnabled
                ? () => onMenuItemPressed(item, menuItem)
                : null,
            child: Text(menuItem.resolveCaption(locale)),
          ),
    ];
  }
}

class _RibbonCommandChrome extends StatelessWidget {
  const _RibbonCommandChrome({
    required this.caption,
    required this.item,
    required this.icon,
    required this.locale,
    required this.density,
    required this.interactionMode,
    required this.ribbonTheme,
    required this.compact,
    required this.showKeyTip,
    this.trailing,
    this.borderless = false,
    this.onPressed,
  });

  final String caption;
  final FxRibbonItem item;
  final FxRibbonIconSource? icon;
  final Locale locale;
  final FxRibbonDensity density;
  final FxRibbonInteractionMode interactionMode;
  final FxRibbonThemeData ribbonTheme;
  final bool compact;
  final bool showKeyTip;
  final Widget? trailing;
  final bool borderless;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final iconSize = compact ? density.smallIconSize : density.largeIconSize;
    final minHeight = _minTargetHeight(density, interactionMode);
    final largeHeight = interactionMode == FxRibbonInteractionMode.touch
        ? 100.0
        : 68.0;
    final content = compact
        ? Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (item.itemType == FxRibbonItemType.checkBox)
                Transform.scale(
                  scale: 0.78,
                  child: Checkbox(
                    value: item.isToggleActive,
                    onChanged: enabled ? (_) => onPressed?.call() : null,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              else
                FxRibbonIconView(
                  source: icon,
                  size: iconSize,
                  label: caption,
                  enabled: enabled,
                ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.0,
                    color: enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
              ?trailing,
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxRibbonIconView(
                source: icon,
                size: iconSize,
                label: caption,
                enabled: enabled,
              ),
              const SizedBox(height: 3),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 86),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        caption,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.0,
                          color: enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ),
                    if (trailing != null)
                      IconTheme.merge(
                        data: const IconThemeData(size: 13),
                        child: trailing!,
                      ),
                  ],
                ),
              ),
            ],
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(ribbonTheme.borderRadius),
            onTap: onPressed,
            child: Container(
              height: compact ? minHeight : largeHeight,
              constraints: BoxConstraints(minWidth: compact ? 0 : 54),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 2 : 4,
                vertical: compact ? 1 : 3,
              ),
              decoration: borderless
                  ? null
                  : BoxDecoration(
                      border: Border.all(
                        color: item.isToggleActive
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(
                        ribbonTheme.borderRadius,
                      ),
                      color: item.isToggleActive
                          ? ribbonTheme.resolvedPressed(colorScheme)
                          : null,
                    ),
              child: content,
            ),
          ),
        ),
        if (showKeyTip)
          PositionedDirectional(
            top: -5,
            end: -3,
            child: _KeyTipBadge(text: _keyTipForItem(item, caption)),
          ),
      ],
    );
  }
}

class _RibbonTabButton extends StatelessWidget {
  const _RibbonTabButton({
    required this.tab,
    required this.selected,
    required this.keyTip,
    required this.showKeyTip,
    required this.locale,
    required this.theme,
    required this.onPressed,
    required this.onDoubleTap,
  });

  final FxRibbonTab tab;
  final bool selected;
  final String keyTip;
  final bool showKeyTip;
  final Locale locale;
  final FxRibbonThemeData theme;
  final VoidCallback onPressed;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final caption = tab.resolveCaption(locale);
    final accent = tab.accentColor;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: selected
                ? theme.resolvedActiveTab(colorScheme)
                : Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Container(
                height: 25,
                constraints: const BoxConstraints(minWidth: 58),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: selected
                          ? colorScheme.outlineVariant
                          : Colors.transparent,
                    ),
                    right: BorderSide(
                      color: selected
                          ? colorScheme.outlineVariant
                          : Colors.transparent,
                    ),
                    top: BorderSide(
                      color: selected
                          ? colorScheme.outlineVariant
                          : Colors.transparent,
                    ),
                    bottom: BorderSide(
                      color: selected
                          ? theme.resolvedActiveTab(colorScheme)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (accent != null || selected)
                      Container(
                        height: 2,
                        width: 34,
                        margin: const EdgeInsets.only(bottom: 1),
                        color: accent ?? colorScheme.primary,
                      ),
                    Text(
                      caption,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.0,
                        color: selected
                            ? (accent ?? colorScheme.primary)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showKeyTip)
            PositionedDirectional(
              top: 2,
              end: 4,
              child: _KeyTipBadge(text: keyTip),
            ),
        ],
      ),
    );
  }
}

class _ApplicationRibbonButton extends StatelessWidget {
  const _ApplicationRibbonButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary,
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          width: 55,
          height: 25,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 12,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonGalleryView extends StatelessWidget {
  const _RibbonGalleryView({
    required this.item,
    required this.locale,
    required this.showKeyTip,
    required this.onMenuItemPressed,
  });

  final FxRibbonItem item;
  final Locale locale;
  final bool showKeyTip;
  final void Function(FxRibbonItem item, FxRibbonMenuItem menuItem)
  onMenuItemPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = item.menuItems
        .where((entry) => !entry.isSeparator)
        .toList();
    final visible = entries.take(6).toList();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 236,
          height: 66,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(3, 3, 2, 3),
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 5.35,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 2,
                    children: [
                      for (final entry in visible)
                        _RibbonGalleryTile(
                          item: item,
                          menuItem: entry,
                          locale: locale,
                          selected: entry.tag == item.selectedMenuItemTag,
                          onPressed: () => onMenuItemPressed(item, entry),
                        ),
                    ],
                  ),
                ),
                const _RibbonGalleryScrollStrip(),
              ],
            ),
          ),
        ),
        if (showKeyTip)
          PositionedDirectional(
            top: -5,
            end: -3,
            child: _KeyTipBadge(text: _keyTipForItem(item, item.caption)),
          ),
      ],
    );
  }
}

class _RibbonGalleryTile extends StatelessWidget {
  const _RibbonGalleryTile({
    required this.item,
    required this.menuItem,
    required this.locale,
    required this.selected,
    required this.onPressed,
  });

  final FxRibbonItem item;
  final FxRibbonMenuItem menuItem;
  final Locale locale;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final caption = menuItem.resolveCaption(locale);
    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: item.isEnabled ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 2),
              Icon(
                selected ? Icons.view_list : Icons.crop_square,
                size: 12,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, height: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RibbonGalleryScrollStrip extends StatelessWidget {
  const _RibbonGalleryScrollStrip();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final divider = colorScheme.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(left: BorderSide(color: divider)),
      ),
      child: SizedBox(
        width: 16,
        child: Column(
          children: [
            const Expanded(child: Icon(Icons.keyboard_arrow_up, size: 13)),
            Divider(height: 1, thickness: 1, color: divider),
            const Expanded(child: Icon(Icons.keyboard_arrow_down, size: 13)),
            Divider(height: 1, thickness: 1, color: divider),
            const Expanded(child: Icon(Icons.arrow_drop_down, size: 13)),
          ],
        ),
      ),
    );
  }
}

class _KeyTipBadge extends StatelessWidget {
  const _KeyTipBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FxRibbonThemeData.of(context);
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.resolvedKeyTipBackground(scheme),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            color: theme.resolvedKeyTipForeground(scheme),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _FxRibbonToggleKeyTipsIntent extends Intent {
  const _FxRibbonToggleKeyTipsIntent();
}

class _FxRibbonHideKeyTipsIntent extends Intent {
  const _FxRibbonHideKeyTipsIntent();
}

double _minTargetHeight(
  FxRibbonDensity density,
  FxRibbonInteractionMode interactionMode,
) {
  return interactionMode == FxRibbonInteractionMode.touch
      ? 44
      : density.minTargetHeight;
}

bool _isDropdownButton(FxRibbonItem item) {
  return item.itemType == FxRibbonItemType.dropdown ||
      item.itemType == FxRibbonItemType.mediumDropdown;
}

bool _isSplitButton(FxRibbonItem item) {
  return item.itemType == FxRibbonItemType.splitButton ||
      item.itemType == FxRibbonItemType.mediumSplitButton;
}

bool _isRowRibbonItem(FxRibbonItem item) {
  return item.itemType == FxRibbonItemType.small ||
      item.itemType == FxRibbonItemType.medium ||
      item.itemType == FxRibbonItemType.mediumDropdown ||
      item.itemType == FxRibbonItemType.mediumSplitButton ||
      item.itemType == FxRibbonItemType.toggle ||
      item.itemType == FxRibbonItemType.checkBox;
}

double _rowColumnWidth(List<FxRibbonItem> items, Locale locale) {
  var width = 0.0;
  for (final item in items) {
    final caption = item.resolveCaption(locale);
    final textWidth = caption.length * 6.2;
    final base = switch (item.itemType) {
      FxRibbonItemType.checkBox => 54,
      FxRibbonItemType.mediumDropdown ||
      FxRibbonItemType.mediumSplitButton => 62,
      FxRibbonItemType.medium => 34,
      _ => 28,
    };
    width = math.max(width, textWidth + base);
  }
  return width.clamp(58.0, 190.0);
}

String _keyTipForItem(FxRibbonItem item, String caption) {
  final explicit = item.keyTip;
  if (explicit != null && explicit.isNotEmpty) {
    return explicit.toUpperCase();
  }
  final tagParts = item.tag.split('.');
  if (tagParts.isNotEmpty && tagParts.last.isNotEmpty) {
    return tagParts.last.characters.first.toUpperCase();
  }
  return caption.trim().isEmpty
      ? '?'
      : caption.trim().characters.first.toUpperCase();
}
