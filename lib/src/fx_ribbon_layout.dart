import 'dart:math' as math;
import 'dart:ui';

import 'fx_ribbon_models.dart';
import 'fx_ribbon_theme.dart';

/// Laid-out ribbon tab geometry.
class FxRibbonLaidTab {
  /// Creates tab geometry.
  const FxRibbonLaidTab({
    required this.tab,
    required this.visibleIndex,
    required this.rect,
  });

  /// Source tab.
  final FxRibbonTab tab;

  /// Visible tab index.
  final int visibleIndex;

  /// Bounds.
  final Rect rect;
}

/// Laid-out ribbon item geometry.
class FxRibbonLaidItem {
  /// Creates item geometry.
  const FxRibbonLaidItem({
    required this.item,
    required this.rect,
    this.bodyRect,
    this.arrowRect,
  });

  /// Source item.
  final FxRibbonItem item;

  /// Full item bounds.
  final Rect rect;

  /// Split-button body bounds.
  final Rect? bodyRect;

  /// Split-button arrow bounds.
  final Rect? arrowRect;
}

/// Laid-out ribbon group geometry.
class FxRibbonLaidGroup {
  /// Creates group geometry.
  const FxRibbonLaidGroup({
    required this.group,
    required this.rect,
    required this.items,
  });

  /// Source group.
  final FxRibbonGroup group;

  /// Bounds.
  final Rect rect;

  /// Laid items.
  final List<FxRibbonLaidItem> items;
}

/// Ribbon layout metrics.
class FxRibbonLayoutMetrics {
  /// Creates metrics.
  const FxRibbonLayoutMetrics({
    required this.tabStripHeight,
    required this.contentPadding,
    required this.groupLabelHeight,
    required this.groupPadding,
    required this.groupGap,
    required this.itemGap,
    required this.largeButtonWidth,
    required this.largeButtonHeight,
    required this.smallButtonHeight,
    required this.smallButtonMinWidth,
    required this.arrowZoneWidth,
    required this.collapseButtonSize,
  });

  /// Creates metrics from density and interaction mode.
  factory FxRibbonLayoutMetrics.forMode({
    required FxRibbonDensity density,
    required FxRibbonInteractionMode interactionMode,
  }) {
    final touch = interactionMode == FxRibbonInteractionMode.touch;
    final target = touch
        ? math.max(44.0, density.minTargetHeight)
        : density.minTargetHeight;
    return FxRibbonLayoutMetrics(
      tabStripHeight: touch ? 42 : density.collapsedHeight,
      contentPadding: touch ? 8 : 6,
      groupLabelHeight: touch ? 22 : 18,
      groupPadding: touch ? 10 : 8,
      groupGap: touch ? 10 : 8,
      itemGap: touch ? 6 : 4,
      largeButtonWidth: touch ? 76 : 64,
      largeButtonHeight: touch ? 78 : 68,
      smallButtonHeight: target,
      smallButtonMinWidth: touch ? 96 : 72,
      arrowZoneWidth: touch ? 28 : 22,
      collapseButtonSize: touch ? 32 : 26,
    );
  }

  /// Tab strip height.
  final double tabStripHeight;

  /// Content padding.
  final double contentPadding;

  /// Group caption height.
  final double groupLabelHeight;

  /// Group padding.
  final double groupPadding;

  /// Space between groups.
  final double groupGap;

  /// Space between items.
  final double itemGap;

  /// Base large button width.
  final double largeButtonWidth;

  /// Base large button height.
  final double largeButtonHeight;

  /// Small row height.
  final double smallButtonHeight;

  /// Minimum small column width.
  final double smallButtonMinWidth;

  /// Split-button arrow width.
  final double arrowZoneWidth;

  /// Collapse affordance size.
  final double collapseButtonSize;
}

/// Deterministic ribbon layout result.
class FxRibbonLayout {
  /// Creates layout result.
  const FxRibbonLayout({
    required this.size,
    required this.tabs,
    required this.groups,
    required this.collapseButtonRect,
    required this.collapsed,
  });

  /// Layout size.
  final Size size;

  /// Visible tabs.
  final List<FxRibbonLaidTab> tabs;

  /// Groups in the active tab.
  final List<FxRibbonLaidGroup> groups;

  /// Collapse button bounds.
  final Rect collapseButtonRect;

  /// Whether content is collapsed.
  final bool collapsed;

  /// Computes layout from a definition.
  static FxRibbonLayout compute({
    required FxRibbonDefinition definition,
    required double width,
    required int activeTabIndex,
    required bool collapsed,
    required FxRibbonDensity density,
    required FxRibbonInteractionMode interactionMode,
    Set<String> visibleContextGroups = const {},
  }) {
    final metrics = FxRibbonLayoutMetrics.forMode(
      density: density,
      interactionMode: interactionMode,
    );
    final visibleTabs = definition.visibleTabs(visibleContextGroups);
    final height = collapsed ? density.collapsedHeight : density.expandedHeight;
    final collapseRect = Rect.fromLTWH(
      math.max(0, width - metrics.collapseButtonSize - 8),
      (metrics.tabStripHeight - metrics.collapseButtonSize) / 2,
      metrics.collapseButtonSize,
      metrics.collapseButtonSize,
    );

    final laidTabs = <FxRibbonLaidTab>[];
    var tabX = 8.0;
    for (var i = 0; i < visibleTabs.length; i++) {
      final tab = visibleTabs[i];
      final tabWidth = _textWidth(tab.caption, 13) + 34;
      laidTabs.add(
        FxRibbonLaidTab(
          tab: tab,
          visibleIndex: i,
          rect: Rect.fromLTWH(tabX, 0, tabWidth, metrics.tabStripHeight),
        ),
      );
      tabX += tabWidth + 2;
    }

    if (collapsed || visibleTabs.isEmpty) {
      return FxRibbonLayout(
        size: Size(width, height),
        tabs: laidTabs,
        groups: const [],
        collapseButtonRect: collapseRect,
        collapsed: collapsed,
      );
    }

    final safeActive = activeTabIndex.clamp(0, visibleTabs.length - 1).toInt();
    final activeTab = visibleTabs[safeActive];
    final contentTop = metrics.tabStripHeight + metrics.contentPadding;
    final groupHeight =
        height - metrics.tabStripHeight - metrics.contentPadding * 2;
    final itemAreaHeight = groupHeight - metrics.groupLabelHeight;

    final laidGroups = <FxRibbonLaidGroup>[];
    var groupX = metrics.groupPadding;
    for (final group in activeTab.groups) {
      final laidItems = <FxRibbonLaidItem>[];
      var itemX = groupX + metrics.groupPadding;
      var index = 0;
      while (index < group.items.length) {
        final item = group.items[index];
        if (item.itemType == FxRibbonItemType.small ||
            item.itemType == FxRibbonItemType.checkBox) {
          final batch = <FxRibbonItem>[];
          var maxText = 0.0;
          while (index < group.items.length &&
              group.items[index].itemType == item.itemType &&
              batch.length < 3) {
            final candidate = group.items[index];
            maxText = math.max(maxText, _textWidth(candidate.caption, 12));
            batch.add(candidate);
            index++;
          }
          final columnWidth = math.max(
            metrics.smallButtonMinWidth,
            maxText + (item.itemType == FxRibbonItemType.checkBox ? 42 : 46),
          );
          final totalHeight = batch.length * metrics.smallButtonHeight;
          final startY = contentTop + (itemAreaHeight - totalHeight) / 2;
          for (var row = 0; row < batch.length; row++) {
            laidItems.add(
              FxRibbonLaidItem(
                item: batch[row],
                rect: Rect.fromLTWH(
                  itemX,
                  startY + row * metrics.smallButtonHeight,
                  columnWidth,
                  metrics.smallButtonHeight,
                ),
              ),
            );
          }
          itemX += columnWidth + metrics.itemGap;
          continue;
        }
        if (item.isSeparator) {
          itemX += metrics.itemGap + 2;
          index++;
          continue;
        }

        final captionWidth = _textWidth(item.caption, 12) + 18;
        var buttonWidth = math.max(metrics.largeButtonWidth, captionWidth);
        if (item.itemType == FxRibbonItemType.splitButton) {
          buttonWidth += metrics.arrowZoneWidth;
        }
        final rect = Rect.fromLTWH(
          itemX,
          contentTop,
          buttonWidth,
          math.min(metrics.largeButtonHeight, itemAreaHeight),
        );
        laidItems.add(
          FxRibbonLaidItem(
            item: item,
            rect: rect,
            bodyRect: item.itemType == FxRibbonItemType.splitButton
                ? Rect.fromLTWH(
                    rect.left,
                    rect.top,
                    rect.width - metrics.arrowZoneWidth,
                    rect.height,
                  )
                : null,
            arrowRect: item.itemType == FxRibbonItemType.splitButton
                ? Rect.fromLTWH(
                    rect.right - metrics.arrowZoneWidth,
                    rect.top,
                    metrics.arrowZoneWidth,
                    rect.height,
                  )
                : null,
          ),
        );
        itemX += buttonWidth + metrics.itemGap;
        index++;
      }

      final labelWidth =
          _textWidth(group.caption, 11) + metrics.groupPadding * 2;
      final groupWidth = math.max(
        labelWidth,
        itemX - groupX + metrics.groupPadding - metrics.itemGap,
      );
      laidGroups.add(
        FxRibbonLaidGroup(
          group: group,
          rect: Rect.fromLTWH(groupX, contentTop, groupWidth, groupHeight),
          items: laidItems,
        ),
      );
      groupX += groupWidth + metrics.groupGap;
    }

    return FxRibbonLayout(
      size: Size(math.max(width, groupX + metrics.groupPadding), height),
      tabs: laidTabs,
      groups: laidGroups,
      collapseButtonRect: collapseRect,
      collapsed: collapsed,
    );
  }
}

double _textWidth(String text, double fontSize) {
  final longest = text
      .split('\n')
      .fold<int>(0, (maxLength, line) => math.max(maxLength, line.length));
  return longest * fontSize * 0.58;
}
