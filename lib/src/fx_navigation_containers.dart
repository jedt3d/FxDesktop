import 'package:flutter/material.dart';

/// A visible tabbed container comparable to Xojo's DesktopTabPanel.
///
/// [FxTabPanel] is controlled by [selectedIndex]. Tapping a tab reports the
/// requested index through [onChanged]; callers own updating the selected
/// index and rebuilding the panel.
class FxTabPanel extends StatelessWidget {
  /// Creates an FxDesktop tab panel.
  const FxTabPanel({
    super.key,
    required this.tabs,
    required this.children,
    required this.selectedIndex,
    this.onChanged,
  });

  /// Visible tab labels.
  final List<String> tabs;

  /// Content pages displayed for each tab.
  final List<Widget> children;

  /// Currently selected tab and content index.
  final int selectedIndex;

  /// Called when a tab is selected.
  final ValueChanged<int>? onChanged;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxTabPanel',
      'xojo_desktop_class': 'DesktopTabPanel',
      'selectedIndex': selectedIndex,
      'tabCount': tabs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(tabs.length == children.length);
    assert(tabs.isNotEmpty);
    assert(selectedIndex >= 0 && selectedIndex < children.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FxTabStrip(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        FxPagePanel(selectedIndex: selectedIndex, children: children),
      ],
    );
  }
}

/// A headless indexed page container comparable to Xojo's DesktopPagePanel.
///
/// Only the child at [selectedIndex] is visible. Children remain mounted while
/// hidden so local widget state is preserved when switching pages.
class FxPagePanel extends StatelessWidget {
  /// Creates an FxDesktop page panel.
  const FxPagePanel({
    super.key,
    required this.children,
    required this.selectedIndex,
  });

  /// Content pages in index order.
  final List<Widget> children;

  /// Currently visible page index.
  final int selectedIndex;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxPagePanel',
      'xojo_desktop_class': 'DesktopPagePanel',
      'selectedIndex': selectedIndex,
      'pageCount': children.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty);
    assert(selectedIndex >= 0 && selectedIndex < children.length);

    return _FxIndexedPreservingStack(
      selectedIndex: selectedIndex,
      children: children,
    );
  }
}

/// A generator-friendly indexed card stack.
///
/// [FxCardContainer] is visually headless and can be paired with external
/// controls such as an `FxSegmentedButton` to select the active card. Children
/// remain mounted while hidden so local widget state is preserved when
/// switching cards.
class FxCardContainer extends StatelessWidget {
  /// Creates an FxDesktop card container.
  const FxCardContainer({
    super.key,
    required this.children,
    required this.selectedIndex,
  });

  /// Cards in index order.
  final List<Widget> children;

  /// Currently visible card index.
  final int selectedIndex;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxCardContainer',
      'xojo_desktop_class': 'DesktopPagePanel',
      'selectedIndex': selectedIndex,
      'cardCount': children.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty);
    assert(selectedIndex >= 0 && selectedIndex < children.length);

    return _FxIndexedPreservingStack(
      selectedIndex: selectedIndex,
      children: children,
    );
  }
}

class _FxTabStrip extends StatelessWidget {
  const _FxTabStrip({
    required this.tabs,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < tabs.length; index++)
                _FxTabButton(
                  label: tabs[index],
                  selected: index == selectedIndex,
                  onTap: onChanged == null ? null : () => onChanged!(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FxTabButton extends StatelessWidget {
  const _FxTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 2,
                width: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FxIndexedPreservingStack extends StatelessWidget {
  const _FxIndexedPreservingStack({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        for (var index = 0; index < children.length; index++)
          Offstage(
            offstage: index != selectedIndex,
            child: TickerMode(
              enabled: index == selectedIndex,
              child: children[index],
            ),
          ),
      ],
    );
  }
}
