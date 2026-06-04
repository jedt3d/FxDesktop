import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart'
    as table;

import 'fx_theme.dart';

/// Horizontal alignment for text in list/grid cells.
enum FxCellAlignment {
  /// Leading text alignment.
  leading,

  /// Center text alignment.
  center,

  /// Trailing text alignment.
  trailing,
}

/// Selection mode for [FxListBox].
enum FxListBoxSelectionMode {
  /// No selection allowed.
  none,

  /// At most one row selected.
  single,

  /// Multiple rows can be selected.
  multiple,
}

/// Selection mode for [FxGrid].
enum FxGridSelectionMode {
  /// No selection allowed.
  none,

  /// Individual cell selection.
  cell,

  /// Selection of entire rows.
  row,

  /// Rectangular range of cells selection.
  range,
}

/// Presentation states for FxDesktop table controls.
enum FxTableState {
  /// Ready to present row/cell data.
  ready,

  /// Presenting an indeterminate loading progress indicator.
  loading,

  /// Presenting an empty data placeholder message.
  empty,

  /// Presenting a detailed error message block.
  error,
}

/// A column descriptor for [FxListBox].
class FxListBoxColumn {
  /// Creates a list box column.
  const FxListBoxColumn({
    required this.id,
    required this.caption,
    this.width = 120,
    this.minWidth = 48,
    this.alignment = FxCellAlignment.leading,
    this.editable = false,
  });

  /// Stable column id.
  final String id;

  /// Header caption.
  final String caption;

  /// Preferred width.
  final double width;

  /// Minimum width metadata for generator use.
  final double minWidth;

  /// Cell alignment.
  final FxCellAlignment alignment;

  /// Whether the column is editable in generated UI.
  final bool editable;

  /// Converts this column to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'caption': caption,
      'width': width,
      'minWidth': minWidth,
      'alignment': alignment.name,
      'editable': editable,
    };
  }
}

/// A row descriptor for [FxListBox].
class FxListBoxRow {
  /// Creates a list box row.
  const FxListBoxRow({
    required this.id,
    required this.cells,
    this.enabled = true,
    this.height,
  });

  /// Stable row id.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, Object?> cells;

  /// Whether the row is interactive.
  final bool enabled;

  /// Optional row height.
  final double? height;

  /// Converts this row to JSON.
  Map<String, Object?> toJson() {
    return {'id': id, 'cells': cells, 'enabled': enabled, 'height': height};
  }
}

/// A Xojo-style desktop list box with columns, rows, sticky header, and single
/// selection.
class FxListBox extends StatefulWidget {
  /// Creates an FxDesktop list box.
  const FxListBox({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedRowIds = const <String>{},
    this.onSelectionChanged,
    this.selectionMode = FxListBoxSelectionMode.single,
    this.state = FxTableState.ready,
    this.errorText,
    this.loadingPlaceholder,
    this.emptyPlaceholder,
    this.errorPlaceholder,
    this.height = 260,
    this.headerHeight = 30,
    this.rowHeight = 28,
    this.showGridLines = true,
    this.focusNode,
  });

  /// Column descriptors.
  final List<FxListBoxColumn> columns;

  /// Row descriptors.
  final List<FxListBoxRow> rows;

  /// Currently selected row ids.
  final Set<String> selectedRowIds;

  /// Selection callback.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Selection mode for rows.
  final FxListBoxSelectionMode selectionMode;

  /// Loading or display state of the table.
  final FxTableState state;

  /// Custom error message.
  final String? errorText;

  /// Custom loading placeholder widget.
  final Widget? loadingPlaceholder;

  /// Custom empty list placeholder widget.
  final Widget? emptyPlaceholder;

  /// Custom error state placeholder widget.
  final Widget? errorPlaceholder;

  /// Preferred list box height.
  final double height;

  /// Header row height.
  final double headerHeight;

  /// Default row height.
  final double rowHeight;

  /// Whether to draw row/column separators.
  final bool showGridLines;

  /// Focus node for keyboard interactions.
  final FocusNode? focusNode;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxListBox',
      'xojo_desktop_class': 'DesktopListBox',
      'xojo_web_class': 'WebListBox',
      'selectionMode': selectionMode.name,
      'state': state.name,
      'columns': [for (final column in columns) column.toJson()],
      'rows': [for (final row in rows) row.toJson()],
    };
  }

  @override
  State<FxListBox> createState() => _FxListBoxState();
}

class _FxListBoxState extends State<FxListBox> {
  late FocusNode _focusNode;
  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(FxListBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _focusNode).removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleRowTap(String clickedRowId) {
    if (widget.onSelectionChanged == null ||
        widget.selectionMode == FxListBoxSelectionMode.none) {
      return;
    }

    if (widget.selectionMode == FxListBoxSelectionMode.single) {
      widget.onSelectionChanged!({clickedRowId});
      return;
    }

    if (widget.selectionMode == FxListBoxSelectionMode.multiple) {
      final keys = HardwareKeyboard.instance;
      final isShift = keys.isShiftPressed;
      final isControl = keys.isControlPressed || keys.isMetaPressed;

      if (isControl) {
        final nextSelection = Set<String>.from(widget.selectedRowIds);
        if (nextSelection.contains(clickedRowId)) {
          nextSelection.remove(clickedRowId);
        } else {
          nextSelection.add(clickedRowId);
        }
        widget.onSelectionChanged!(nextSelection);
      } else if (isShift && widget.selectedRowIds.isNotEmpty) {
        final lastId = widget.selectedRowIds.last;
        final startIdx = widget.rows.indexWhere((r) => r.id == lastId);
        final endIdx = widget.rows.indexWhere((r) => r.id == clickedRowId);

        if (startIdx != -1 && endIdx != -1) {
          final minIdx = startIdx < endIdx ? startIdx : endIdx;
          final maxIdx = startIdx > endIdx ? startIdx : endIdx;
          final nextSelection = Set<String>.from(widget.selectedRowIds);
          for (var i = minIdx; i <= maxIdx; i++) {
            if (widget.rows[i].enabled) {
              nextSelection.add(widget.rows[i].id);
            }
          }
          widget.onSelectionChanged!(nextSelection);
        }
      } else {
        widget.onSelectionChanged!({clickedRowId});
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (widget.rows.isEmpty ||
        widget.onSelectionChanged == null ||
        widget.selectionMode == FxListBoxSelectionMode.none) {
      return KeyEventResult.ignored;
    }

    int currentIndex = -1;
    if (widget.selectedRowIds.isNotEmpty) {
      final lastSelected = widget.selectedRowIds.last;
      currentIndex = widget.rows.indexWhere((r) => r.id == lastSelected);
    }

    int nextIndex;
    int step;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      nextIndex = currentIndex == -1 ? 0 : currentIndex + 1;
      step = 1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      nextIndex = currentIndex == -1
          ? widget.rows.length - 1
          : currentIndex - 1;
      step = -1;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      nextIndex = 0;
      step = 1;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      nextIndex = widget.rows.length - 1;
      step = -1;
    } else {
      return KeyEventResult.ignored;
    }

    if (nextIndex < 0) nextIndex = 0;
    if (nextIndex >= widget.rows.length) nextIndex = widget.rows.length - 1;

    // Search for first enabled row in direction of step
    while (nextIndex >= 0 &&
        nextIndex < widget.rows.length &&
        !widget.rows[nextIndex].enabled) {
      nextIndex += step;
    }

    if (nextIndex >= 0 &&
        nextIndex < widget.rows.length &&
        widget.rows[nextIndex].enabled) {
      final targetRow = widget.rows[nextIndex];
      if (widget.selectionMode == FxListBoxSelectionMode.single) {
        widget.onSelectionChanged!({targetRow.id});
      } else if (widget.selectionMode == FxListBoxSelectionMode.multiple) {
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        if (isShiftPressed) {
          final nextSelection = Set<String>.from(widget.selectedRowIds);
          nextSelection.add(targetRow.id);
          widget.onSelectionChanged!(nextSelection);
        } else {
          widget.onSelectionChanged!({targetRow.id});
        }
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildStateView(BuildContext context, FxTheme theme) {
    return Container(
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: theme.gridLineColor),
      ),
      child: _buildStateContent(context, theme),
    );
  }

  Widget _buildStateContent(BuildContext context, FxTheme theme) {
    switch (widget.state) {
      case FxTableState.loading:
        return widget.loadingPlaceholder ??
            const CircularProgressIndicator.adaptive();
      case FxTableState.empty:
        return widget.emptyPlaceholder ??
            Text(
              'No records to display',
              style: TextStyle(color: Theme.of(context).disabledColor),
            );
      case FxTableState.error:
        return widget.errorPlaceholder ??
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.errorText ?? 'An error occurred loading data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
      case FxTableState.ready:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FxTheme.of(context);
    _validateColumns(widget.columns);

    if (widget.state != FxTableState.ready) {
      return _buildStateView(context, theme);
    }

    final isFocused = _focusNode.hasFocus;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isFocused
                ? Theme.of(context).colorScheme.primary
                : theme.gridLineColor,
            width: isFocused ? 1.5 : 1.0,
          ),
        ),
        child: SizedBox(
          height: widget.height,
          child: table.TableView.builder(
            pinnedRowCount: 1,
            columnCount: widget.columns.length,
            rowCount: widget.rows.length + 1,
            columnBuilder: (index) {
              return table.TableSpan(
                extent: table.FixedTableSpanExtent(widget.columns[index].width),
                foregroundDecoration: _borderDecoration(
                  theme,
                  widget.showGridLines,
                ),
              );
            },
            rowBuilder: (index) {
              final isHeader = index == 0;
              final row = isHeader ? null : widget.rows[index - 1];
              final isSelected =
                  row != null && widget.selectedRowIds.contains(row.id);
              final isHovered = index == _hoveredRowIndex;
              return table.TableSpan(
                extent: table.FixedTableSpanExtent(
                  isHeader
                      ? widget.headerHeight
                      : (row?.height ?? widget.rowHeight),
                ),
                backgroundDecoration: table.TableSpanDecoration(
                  color: isHeader
                      ? theme.headerBackground
                      : isSelected
                      ? theme.selectionBackground
                      : isHovered
                      ? Theme.of(context).hoverColor
                      : index.isEven
                      ? theme.alternatingRowBackground
                      : Theme.of(context).colorScheme.surface,
                ),
                foregroundDecoration: _borderDecoration(
                  theme,
                  widget.showGridLines,
                ),
              );
            },
            cellBuilder: (context, vicinity) {
              final column = widget.columns[vicinity.column];
              if (vicinity.row == 0) {
                return table.TableViewCell(
                  child: _CellText(
                    text: column.caption,
                    alignment: column.alignment,
                    isHeader: true,
                  ),
                );
              }
              final row = widget.rows[vicinity.row - 1];
              final value = row.cells[column.id];
              final isSelected = widget.selectedRowIds.contains(row.id);
              return table.TableViewCell(
                child: MouseRegion(
                  onEnter: (_) {
                    if (row.enabled) {
                      setState(() => _hoveredRowIndex = vicinity.row);
                    }
                  },
                  onExit: (_) {
                    if (row.enabled) {
                      setState(() => _hoveredRowIndex = null);
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: row.enabled ? () => _handleRowTap(row.id) : null,
                    child: _CellText(
                      text: value?.toString() ?? '',
                      alignment: column.alignment,
                      enabled: row.enabled,
                      isSelected: isSelected,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A column descriptor for [FxGrid].
class FxGridColumn {
  /// Creates a data grid column.
  const FxGridColumn({
    required this.id,
    this.caption,
    this.width = 100,
    this.alignment = FxCellAlignment.leading,
  });

  /// Stable column id.
  final String id;

  /// Optional header caption.
  final String? caption;

  /// Column width.
  final double width;

  /// Cell alignment.
  final FxCellAlignment alignment;

  /// Converts this column to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'caption': caption,
      'width': width,
      'alignment': alignment.name,
    };
  }
}

/// A row descriptor for [FxGrid].
class FxGridRow {
  /// Creates a data grid row.
  const FxGridRow({
    required this.id,
    required this.cells,
    this.enabled = true,
    this.height,
  });

  /// Stable row id.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, Object?> cells;

  /// Whether the row is interactive.
  final bool enabled;

  /// Optional row height.
  final double? height;

  /// Converts this row to JSON.
  Map<String, Object?> toJson() {
    return {'id': id, 'cells': cells, 'enabled': enabled, 'height': height};
  }
}

/// A desktop data/cell grid comparable to Xojo's DesktopGrid.
class FxGrid extends StatefulWidget {
  /// Creates an FxDesktop data grid.
  const FxGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedCells = const <({String rowId, String columnId})>{},
    this.onCellsSelected,
    this.selectionMode = FxGridSelectionMode.cell,
    this.state = FxTableState.ready,
    this.errorText,
    this.loadingPlaceholder,
    this.emptyPlaceholder,
    this.errorPlaceholder,
    this.height = 260,
    this.headerHeight = 30,
    this.rowHeight = 28,
    this.showHeaders = true,
    this.showGridLines = true,
    this.focusNode,
  });

  /// Column descriptors.
  final List<FxGridColumn> columns;

  /// Row descriptors.
  final List<FxGridRow> rows;

  /// Set of selected cell descriptors.
  final Set<({String rowId, String columnId})> selectedCells;

  /// Cell selection callback.
  final ValueChanged<Set<({String rowId, String columnId})>>? onCellsSelected;

  /// Cell selection mode.
  final FxGridSelectionMode selectionMode;

  /// Loading or display state of the grid.
  final FxTableState state;

  /// Custom error message.
  final String? errorText;

  /// Custom loading placeholder widget.
  final Widget? loadingPlaceholder;

  /// Custom empty grid placeholder widget.
  final Widget? emptyPlaceholder;

  /// Custom error state placeholder widget.
  final Widget? errorPlaceholder;

  /// Preferred height.
  final double height;

  /// Header height.
  final double headerHeight;

  /// Default row height.
  final double rowHeight;

  /// Whether to show column headers.
  final bool showHeaders;

  /// Whether to draw grid lines.
  final bool showGridLines;

  /// Focus node for keyboard interactions.
  final FocusNode? focusNode;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxGrid',
      'xojo_desktop_class': 'DesktopGrid',
      'selectionMode': selectionMode.name,
      'state': state.name,
      'columns': [for (final column in columns) column.toJson()],
      'rows': [for (final row in rows) row.toJson()],
    };
  }

  @override
  State<FxGrid> createState() => _FxGridState();
}

class _FxGridState extends State<FxGrid> {
  late FocusNode _focusNode;
  table.TableVicinity? _hoveredCell;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(FxGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _focusNode).removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleCellTap(String rowId, String columnId) {
    if (widget.onCellsSelected == null ||
        widget.selectionMode == FxGridSelectionMode.none) {
      return;
    }

    if (widget.selectionMode == FxGridSelectionMode.cell) {
      widget.onCellsSelected!({(rowId: rowId, columnId: columnId)});
    } else if (widget.selectionMode == FxGridSelectionMode.row) {
      final nextSelection = <({String rowId, String columnId})>{};
      for (final col in widget.columns) {
        nextSelection.add((rowId: rowId, columnId: col.id));
      }
      widget.onCellsSelected!(nextSelection);
    }
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (widget.rows.isEmpty ||
        widget.columns.isEmpty ||
        widget.onCellsSelected == null ||
        widget.selectionMode == FxGridSelectionMode.none) {
      return KeyEventResult.ignored;
    }

    int currentRow = -1;
    int currentCol = -1;
    if (widget.selectedCells.isNotEmpty) {
      final lastSelected = widget.selectedCells.last;
      currentRow = widget.rows.indexWhere((r) => r.id == lastSelected.rowId);
      currentCol = widget.columns.indexWhere(
        (c) => c.id == lastSelected.columnId,
      );
    }

    int nextRow;
    int nextCol;
    int rowStep = 0;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      nextRow = currentRow == -1 ? 0 : currentRow + 1;
      nextCol = currentCol == -1 ? 0 : currentCol;
      rowStep = 1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      nextRow = currentRow == -1 ? widget.rows.length - 1 : currentRow - 1;
      nextCol = currentCol == -1 ? 0 : currentCol;
      rowStep = -1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = currentCol == -1 ? 0 : currentCol + 1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = currentCol == -1 ? widget.columns.length - 1 : currentCol - 1;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = widget.columns.length - 1;
    } else {
      return KeyEventResult.ignored;
    }

    if (nextRow < 0) nextRow = 0;
    if (nextRow >= widget.rows.length) nextRow = widget.rows.length - 1;
    if (nextCol < 0) nextCol = 0;
    if (nextCol >= widget.columns.length) nextCol = widget.columns.length - 1;

    // Skip disabled rows if navigating vertically
    if (rowStep != 0) {
      while (nextRow >= 0 &&
          nextRow < widget.rows.length &&
          !widget.rows[nextRow].enabled) {
        nextRow += rowStep;
      }
      if (nextRow < 0 ||
          nextRow >= widget.rows.length ||
          !widget.rows[nextRow].enabled) {
        return KeyEventResult.handled;
      }
    } else {
      // If navigating horizontally, ensure current row is enabled
      if (nextRow >= 0 &&
          nextRow < widget.rows.length &&
          !widget.rows[nextRow].enabled) {
        return KeyEventResult.handled;
      }
    }

    if (nextRow == currentRow && nextCol == currentCol) {
      return KeyEventResult.handled;
    }

    final targetRow = widget.rows[nextRow];
    final targetCol = widget.columns[nextCol];

    if (widget.selectionMode == FxGridSelectionMode.cell) {
      widget.onCellsSelected!({(rowId: targetRow.id, columnId: targetCol.id)});
    } else if (widget.selectionMode == FxGridSelectionMode.row) {
      final nextSelection = <({String rowId, String columnId})>{};
      for (final col in widget.columns) {
        nextSelection.add((rowId: targetRow.id, columnId: col.id));
      }
      widget.onCellsSelected!(nextSelection);
    }

    return KeyEventResult.handled;
  }

  Widget _buildStateView(BuildContext context, FxTheme theme) {
    return Container(
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: theme.gridLineColor),
      ),
      child: _buildStateContent(context, theme),
    );
  }

  Widget _buildStateContent(BuildContext context, FxTheme theme) {
    switch (widget.state) {
      case FxTableState.loading:
        return widget.loadingPlaceholder ??
            const CircularProgressIndicator.adaptive();
      case FxTableState.empty:
        return widget.emptyPlaceholder ??
            Text(
              'No records to display',
              style: TextStyle(color: Theme.of(context).disabledColor),
            );
      case FxTableState.error:
        return widget.errorPlaceholder ??
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.errorText ?? 'An error occurred loading data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
      case FxTableState.ready:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FxTheme.of(context);
    _validateGridColumns(widget.columns);

    if (widget.state != FxTableState.ready) {
      return _buildStateView(context, theme);
    }

    final rowOffset = widget.showHeaders ? 1 : 0;
    final isFocused = _focusNode.hasFocus;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleGridKeyEvent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isFocused
                ? Theme.of(context).colorScheme.primary
                : theme.gridLineColor,
            width: isFocused ? 1.5 : 1.0,
          ),
        ),
        child: SizedBox(
          height: widget.height,
          child: table.TableView.builder(
            pinnedRowCount: widget.showHeaders ? 1 : 0,
            columnCount: widget.columns.length,
            rowCount: widget.rows.length + rowOffset,
            columnBuilder: (index) {
              return table.TableSpan(
                extent: table.FixedTableSpanExtent(widget.columns[index].width),
                foregroundDecoration: _borderDecoration(
                  theme,
                  widget.showGridLines,
                ),
              );
            },
            rowBuilder: (index) {
              final isHeader = widget.showHeaders && index == 0;
              final dataRow = isHeader ? null : widget.rows[index - rowOffset];
              return table.TableSpan(
                extent: table.FixedTableSpanExtent(
                  isHeader
                      ? widget.headerHeight
                      : (dataRow?.height ?? widget.rowHeight),
                ),
                backgroundDecoration: table.TableSpanDecoration(
                  color: isHeader
                      ? theme.headerBackground
                      : index.isEven
                      ? theme.alternatingRowBackground
                      : Theme.of(context).colorScheme.surface,
                ),
                foregroundDecoration: _borderDecoration(
                  theme,
                  widget.showGridLines,
                ),
              );
            },
            cellBuilder: (context, vicinity) {
              final column = widget.columns[vicinity.column];
              if (widget.showHeaders && vicinity.row == 0) {
                return table.TableViewCell(
                  child: _CellText(
                    text: column.caption ?? column.id,
                    alignment: column.alignment,
                    isHeader: true,
                  ),
                );
              }
              final row = widget.rows[vicinity.row - rowOffset];
              final selected = widget.selectedCells.any(
                (cell) => cell.rowId == row.id && cell.columnId == column.id,
              );
              final hovered =
                  row.enabled &&
                  _hoveredCell != null &&
                  _hoveredCell!.row == vicinity.row &&
                  _hoveredCell!.column == vicinity.column;
              final value = row.cells[column.id];
              return table.TableViewCell(
                child: MouseRegion(
                  onEnter: (_) {
                    if (row.enabled) {
                      setState(() => _hoveredCell = vicinity);
                    }
                  },
                  onExit: (_) {
                    if (row.enabled) {
                      setState(() => _hoveredCell = null);
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: row.enabled
                        ? () => _handleCellTap(row.id, column.id)
                        : null,
                    child: ColoredBox(
                      color: selected
                          ? theme.selectionBackground
                          : hovered
                          ? Theme.of(context).hoverColor
                          : Colors.transparent,
                      child: _CellText(
                        text: value?.toString() ?? '',
                        alignment: column.alignment,
                        enabled: row.enabled,
                        isSelected: selected,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

table.TableSpanDecoration? _borderDecoration(
  FxTheme theme,
  bool showGridLines,
) {
  if (!showGridLines) {
    return null;
  }
  return table.TableSpanDecoration(
    border: table.TableSpanBorder(
      trailing: BorderSide(color: theme.gridLineColor),
    ),
  );
}

void _validateColumns(List<FxListBoxColumn> columns) {
  final ids = <String>{};
  for (final column in columns) {
    if (!ids.add(column.id)) {
      throw ArgumentError('Duplicate FxListBox column id: ${column.id}');
    }
  }
}

void _validateGridColumns(List<FxGridColumn> columns) {
  final ids = <String>{};
  for (final column in columns) {
    if (!ids.add(column.id)) {
      throw ArgumentError('Duplicate FxGrid column id: ${column.id}');
    }
  }
}

class _CellText extends StatelessWidget {
  const _CellText({
    required this.text,
    required this.alignment,
    this.isHeader = false,
    this.enabled = true,
    this.isSelected = false,
  });

  final String text;
  final FxCellAlignment alignment;
  final bool isHeader;
  final bool enabled;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = FxTheme.of(context);
    final textAlign = switch (alignment) {
      FxCellAlignment.leading => TextAlign.start,
      FxCellAlignment.center => TextAlign.center,
      FxCellAlignment.trailing => TextAlign.end,
    };

    Color textColor;
    if (!enabled) {
      textColor = Theme.of(context).disabledColor;
    } else if (isSelected) {
      final isDark =
          ThemeData.estimateBrightnessForColor(theme.selectionBackground) ==
          Brightness.dark;
      textColor = isDark
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurface;
    } else {
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Align(
        alignment: switch (alignment) {
          FxCellAlignment.leading => Alignment.centerLeft,
          FxCellAlignment.center => Alignment.center,
          FxCellAlignment.trailing => Alignment.centerRight,
        },
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
