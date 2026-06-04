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

/// Defines column sizing strategies for FxDesktop tables.
sealed class FxColumnWidth {
  /// Base constant constructor.
  const FxColumnWidth();

  /// Creates a fixed column width in logical pixels.
  const factory FxColumnWidth.fixed(double pixels) = FxFixedColumnWidth;

  /// Creates a fractional column width representing a ratio (0.0 to 1.0) of
  /// the total viewport width.
  const factory FxColumnWidth.fraction(double fraction) =
      FxFractionalColumnWidth;

  /// Creates a flexible column width that consumes remaining viewport space.
  const factory FxColumnWidth.remaining() = FxRemainingColumnWidth;

  /// Parses an [FxColumnWidth] from a JSON map.
  factory FxColumnWidth.fromJson(Map<String, Object?> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'fixed':
        return FxColumnWidth.fixed((json['value'] as num).toDouble());
      case 'fraction':
        return FxColumnWidth.fraction((json['value'] as num).toDouble());
      case 'remaining':
        return const FxColumnWidth.remaining();
      default:
        return const FxColumnWidth.fixed(120.0);
    }
  }

  /// Converts this sizing strategy to JSON.
  Map<String, Object?> toJson();

  /// Converts this specification to the underlying [table.TableSpanExtent].
  table.TableSpanExtent toTableSpanExtent();
}

/// A fixed column width specification.
class FxFixedColumnWidth extends FxColumnWidth {
  /// Creates a fixed column width.
  const FxFixedColumnWidth(this.value);

  /// Width in logical pixels.
  final double value;

  @override
  Map<String, Object?> toJson() => {'type': 'fixed', 'value': value};

  @override
  table.TableSpanExtent toTableSpanExtent() =>
      table.FixedTableSpanExtent(value);
}

/// A fractional column width specification.
class FxFractionalColumnWidth extends FxColumnWidth {
  /// Creates a fractional column width.
  const FxFractionalColumnWidth(this.value);

  /// Fraction of viewport width (0.0 to 1.0).
  final double value;

  @override
  Map<String, Object?> toJson() => {'type': 'fraction', 'value': value};

  @override
  table.TableSpanExtent toTableSpanExtent() =>
      table.FractionalTableSpanExtent(value);
}

/// A column width that consumes remaining viewport space.
class FxRemainingColumnWidth extends FxColumnWidth {
  /// Creates a remaining column width.
  const FxRemainingColumnWidth();

  @override
  Map<String, Object?> toJson() => {'type': 'remaining'};

  @override
  table.TableSpanExtent toTableSpanExtent() =>
      const table.RemainingTableSpanExtent();
}

/// Defines rendering and interaction strategies for list/grid cells.
sealed class FxCellType {
  /// Base constant constructor.
  const FxCellType();

  /// Creates a text cell type (renders a standard text widget).
  const factory FxCellType.text() = FxTextCellType;

  /// Creates a boolean cell type (renders a checkbox directly in the cell).
  const factory FxCellType.boolean() = FxBooleanCellType;

  /// Creates a choice cell type (renders a dropdown menu when editing).
  const factory FxCellType.choice(List<String> options) = FxChoiceCellType;

  /// Parses an [FxCellType] from a JSON map.
  factory FxCellType.fromJson(Map<String, Object?> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'text':
        return const FxCellType.text();
      case 'boolean':
        return const FxCellType.boolean();
      case 'choice':
        final options =
            (json['options'] as List?)?.cast<String>() ?? const <String>[];
        return FxCellType.choice(options);
      default:
        return const FxCellType.text();
    }
  }

  /// Converts this cell type to JSON.
  Map<String, Object?> toJson();
}

/// A text cell type.
class FxTextCellType extends FxCellType {
  /// Creates a text cell type.
  const FxTextCellType();

  @override
  Map<String, Object?> toJson() => {'type': 'text'};
}

/// A boolean cell type.
class FxBooleanCellType extends FxCellType {
  /// Creates a boolean cell type.
  const FxBooleanCellType();

  @override
  Map<String, Object?> toJson() => {'type': 'boolean'};
}

/// A choice/dropdown cell type.
class FxChoiceCellType extends FxCellType {
  /// Creates a choice cell type.
  const FxChoiceCellType(this.options);

  /// Selection options.
  final List<String> options;

  @override
  Map<String, Object?> toJson() => {'type': 'choice', 'options': options};
}

/// A column descriptor for [FxListBox].
class FxListBoxColumn {
  /// Creates a list box column.
  const FxListBoxColumn({
    required this.id,
    required this.caption,
    this.width = const FxColumnWidth.fixed(120),
    this.minWidth = 48,
    this.alignment = FxCellAlignment.leading,
    this.editable = false,
    this.visible = true,
    this.sortable = false,
    this.type = const FxCellType.text(),
  });

  /// Stable column id.
  final String id;

  /// Header caption.
  final String caption;

  /// Preferred width specification.
  final FxColumnWidth width;

  /// Minimum width metadata for generator use.
  final double minWidth;

  /// Cell alignment.
  final FxCellAlignment alignment;

  /// Whether the column is editable in generated UI.
  final bool editable;

  /// Whether the column is visible.
  final bool visible;

  /// Whether the column can be sorted.
  final bool sortable;

  /// Sizing and interaction type of the cells in this column.
  final FxCellType type;

  /// Converts this column to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'caption': caption,
      'width': width.toJson(),
      'minWidth': minWidth,
      'alignment': alignment.name,
      'editable': editable,
      'visible': visible,
      'sortable': sortable,
      'type': type.toJson(),
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
    this.rowTag,
  });

  /// Stable row id.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, Object?> cells;

  /// Whether the row is interactive.
  final bool enabled;

  /// Optional row height.
  final double? height;

  /// Optional metadata associated with the row.
  final Object? rowTag;

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
    this.sortedColumnId,
    this.sortAscending = true,
    this.onSortChanged,
    this.onColumnResized,
    this.validationErrors,
    this.onCellEdited,
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

  /// Stable column id that is currently sorted.
  final String? sortedColumnId;

  /// Whether sorting is ascending.
  final bool sortAscending;

  /// Callback when column sort order changes.
  final void Function(String columnId, bool ascending)? onSortChanged;

  /// Callback when column is resized.
  final void Function(String columnId, double newWidth)? onColumnResized;

  /// Optional validation errors keyed by row ID and column ID.
  final Map<String, Map<String, String>>? validationErrors;

  /// Callback when a cell is successfully edited/committed.
  final void Function(String rowId, String columnId, Object? newValue)?
  onCellEdited;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxListBox',
      'xojo_desktop_class': 'DesktopListBox',
      'xojo_web_class': 'WebListBox',
      'selectionMode': selectionMode.name,
      'state': state.name,
      'sortedColumnId': sortedColumnId,
      'sortAscending': sortAscending,
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
  final Map<String, double> _columnWidths = {};
  String? _editingRowId;
  String? _editingColumnId;
  TextEditingController? _editingController;

  void _startEditing(String rowId, String columnId, Object? currentValue) {
    setState(() {
      _editingRowId = rowId;
      _editingColumnId = columnId;
      _editingController = TextEditingController(
        text: currentValue?.toString() ?? '',
      );
    });
  }

  void _commitEdit(String rowId, String columnId, String newValue) {
    if (widget.onCellEdited != null) {
      widget.onCellEdited!(rowId, columnId, newValue);
    }
    _cancelEdit();
  }

  void _cancelEdit() {
    final controller = _editingController;
    setState(() {
      _editingRowId = null;
      _editingColumnId = null;
      _editingController = null;
    });
    if (controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }

  void _commitAndMoveToNext(String rowId, String columnId, String newValue) {
    if (widget.onCellEdited != null) {
      widget.onCellEdited!(rowId, columnId, newValue);
    }

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final colIdx = visibleColumns.indexWhere((c) => c.id == columnId);
    if (colIdx != -1) {
      var nextColIdx = colIdx + 1;
      while (nextColIdx < visibleColumns.length) {
        final col = visibleColumns[nextColIdx];
        if (col.editable && col.type is! FxBooleanCellType) {
          final row = widget.rows.firstWhere((r) => r.id == rowId);
          _startEditing(rowId, col.id, row.cells[col.id]);
          return;
        }
        nextColIdx++;
      }
    }

    final rowIdx = widget.rows.indexWhere((r) => r.id == rowId);
    if (rowIdx != -1 && rowIdx + 1 < widget.rows.length) {
      final nextRow = widget.rows[rowIdx + 1];
      if (nextRow.enabled) {
        for (final col in visibleColumns) {
          if (col.editable && col.type is! FxBooleanCellType) {
            _startEditing(nextRow.id, col.id, nextRow.cells[col.id]);
            return;
          }
        }
      }
    }

    _cancelEdit();
  }

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
    _editingController?.dispose();
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

    if (_editingRowId != null) {
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

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (currentIndex != -1) {
        final selectedRow = widget.rows[currentIndex];
        if (selectedRow.enabled) {
          final visibleColumns = widget.columns
              .where((c) => c.visible)
              .toList();
          for (final col in visibleColumns) {
            if (col.editable && col.type is! FxBooleanCellType) {
              _startEditing(selectedRow.id, col.id, selectedRow.cells[col.id]);
              return KeyEventResult.handled;
            }
          }
        }
      }
      return KeyEventResult.ignored;
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

  double _getColumnWidth(FxListBoxColumn column, double totalWidth) {
    final dynamicWidth = _columnWidths[column.id];
    if (dynamicWidth != null) {
      return dynamicWidth;
    }
    return switch (column.width) {
      FxFixedColumnWidth(:final value) => value,
      FxFractionalColumnWidth(:final value) => value * totalWidth,
      FxRemainingColumnWidth() => 120.0,
    };
  }

  table.TableSpanExtent _getColumnExtent(
    FxListBoxColumn column,
    double totalWidth,
  ) {
    final dynamicWidth = _columnWidths[column.id];
    if (dynamicWidth != null) {
      return table.FixedTableSpanExtent(dynamicWidth);
    }
    return column.width.toTableSpanExtent();
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
    final visibleColumns = widget.columns.where((c) => c.visible).toList();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return DecoratedBox(
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
                columnCount: visibleColumns.length,
                rowCount: widget.rows.length + 1,
                columnBuilder: (index) {
                  final column = visibleColumns[index];
                  return table.TableSpan(
                    extent: _getColumnExtent(column, totalWidth),
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
                  final column = visibleColumns[vicinity.column];
                  if (vicinity.row == 0) {
                    final sorted = column.id == widget.sortedColumnId;
                    return table.TableViewCell(
                      child: _HeaderCell(
                        caption: column.caption,
                        alignment: column.alignment,
                        sortable: column.sortable,
                        sorted: sorted,
                        ascending: widget.sortAscending,
                        onSort: () {
                          widget.onSortChanged?.call(
                            column.id,
                            sorted ? !widget.sortAscending : true,
                          );
                        },
                        onResize: (delta) {
                          final currentWidth = _getColumnWidth(
                            column,
                            totalWidth,
                          );
                          final newWidth = (currentWidth + delta).clamp(
                            column.minWidth,
                            1000.0,
                          );
                          setState(() {
                            _columnWidths[column.id] = newWidth;
                          });
                          widget.onColumnResized?.call(column.id, newWidth);
                        },
                      ),
                    );
                  }
                  final row = widget.rows[vicinity.row - 1];
                  final value = row.cells[column.id];
                  final isSelected = widget.selectedRowIds.contains(row.id);
                  final isEditing =
                      _editingRowId == row.id && _editingColumnId == column.id;

                  Widget cellChild;

                  if (isEditing) {
                    if (column.type is FxChoiceCellType) {
                      final options = (column.type as FxChoiceCellType).options;
                      cellChild = Container(
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: options.contains(value?.toString())
                                ? value.toString()
                                : null,
                            isDense: true,
                            autofocus: true,
                            items: [
                              for (final opt in options)
                                DropdownMenuItem(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                            ],
                            onChanged: (newValue) {
                              _commitEdit(row.id, column.id, newValue ?? '');
                            },
                          ),
                        ),
                      );
                    } else {
                      cellChild = Container(
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.centerLeft,
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus &&
                                _editingRowId == row.id &&
                                _editingColumnId == column.id) {
                              _commitEdit(
                                row.id,
                                column.id,
                                _editingController!.text,
                              );
                            }
                          },
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.escape) {
                                _cancelEdit();
                                return KeyEventResult.handled;
                              }
                              if (event.logicalKey == LogicalKeyboardKey.tab) {
                                _commitAndMoveToNext(
                                  row.id,
                                  column.id,
                                  _editingController!.text,
                                );
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: _editingController,
                            autofocus: true,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (newValue) {
                              _commitEdit(row.id, column.id, newValue);
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    if (column.type is FxBooleanCellType) {
                      final bool val = value == true;
                      cellChild = Center(
                        child: Checkbox(
                          value: val,
                          onChanged: (row.enabled && column.editable)
                              ? (newValue) {
                                  if (widget.onCellEdited != null) {
                                    widget.onCellEdited!(
                                      row.id,
                                      column.id,
                                      newValue,
                                    );
                                  }
                                }
                              : null,
                        ),
                      );
                    } else {
                      cellChild = GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: row.enabled ? () => _handleRowTap(row.id) : null,
                        onDoubleTap: (row.enabled && column.editable)
                            ? () => _startEditing(row.id, column.id, value)
                            : null,
                        child: _CellText(
                          text: value?.toString() ?? '',
                          alignment: column.alignment,
                          enabled: row.enabled,
                          isSelected: isSelected,
                        ),
                      );
                    }
                  }

                  final validationError =
                      widget.validationErrors?[row.id]?[column.id];
                  if (validationError != null) {
                    cellChild = Tooltip(
                      message: validationError,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            cellChild,
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

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
                      child: cellChild,
                    ),
                  );
                },
              ),
            ),
          );
        },
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
    this.width = const FxColumnWidth.fixed(100),
    this.minWidth = 48,
    this.alignment = FxCellAlignment.leading,
    this.editable = false,
    this.visible = true,
    this.sortable = false,
    this.type = const FxCellType.text(),
  });

  /// Stable column id.
  final String id;

  /// Optional header caption.
  final String? caption;

  /// Column width specification.
  final FxColumnWidth width;

  /// Minimum width metadata.
  final double minWidth;

  /// Cell alignment.
  final FxCellAlignment alignment;

  /// Whether the column is editable in generated UI.
  final bool editable;

  /// Whether the column is visible.
  final bool visible;

  /// Whether the column can be sorted.
  final bool sortable;

  /// Sizing and interaction type of the cells in this column.
  final FxCellType type;

  /// Converts this column to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'caption': caption,
      'width': width.toJson(),
      'minWidth': minWidth,
      'alignment': alignment.name,
      'editable': editable,
      'visible': visible,
      'sortable': sortable,
      'type': type.toJson(),
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
    this.rowTag,
    this.cellTags,
  });

  /// Stable row id.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, Object?> cells;

  /// Whether the row is interactive.
  final bool enabled;

  /// Optional row height.
  final double? height;

  /// Optional metadata associated with the row.
  final Object? rowTag;

  /// Optional metadata associated with individual cells.
  final Map<String, Object?>? cellTags;

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
    this.sortedColumnId,
    this.sortAscending = true,
    this.onSortChanged,
    this.onColumnResized,
    this.validationErrors,
    this.onCellEdited,
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

  /// Stable column id that is currently sorted.
  final String? sortedColumnId;

  /// Whether sorting is ascending.
  final bool sortAscending;

  /// Callback when column sort order changes.
  final void Function(String columnId, bool ascending)? onSortChanged;

  /// Callback when column is resized.
  final void Function(String columnId, double newWidth)? onColumnResized;

  /// Optional validation errors keyed by row ID and column ID.
  final Map<String, Map<String, String>>? validationErrors;

  /// Callback when a cell is successfully edited/committed.
  final void Function(String rowId, String columnId, Object? newValue)?
  onCellEdited;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxGrid',
      'xojo_desktop_class': 'DesktopGrid',
      'selectionMode': selectionMode.name,
      'state': state.name,
      'sortedColumnId': sortedColumnId,
      'sortAscending': sortAscending,
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
  final Map<String, double> _columnWidths = {};
  String? _editingRowId;
  String? _editingColumnId;
  TextEditingController? _editingController;

  void _startEditing(String rowId, String columnId, Object? currentValue) {
    setState(() {
      _editingRowId = rowId;
      _editingColumnId = columnId;
      _editingController = TextEditingController(
        text: currentValue?.toString() ?? '',
      );
    });
  }

  void _commitEdit(String rowId, String columnId, String newValue) {
    if (widget.onCellEdited != null) {
      widget.onCellEdited!(rowId, columnId, newValue);
    }
    _cancelEdit();
  }

  void _cancelEdit() {
    final controller = _editingController;
    setState(() {
      _editingRowId = null;
      _editingColumnId = null;
      _editingController = null;
    });
    if (controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }

  void _commitAndMoveToNext(String rowId, String columnId, String newValue) {
    if (widget.onCellEdited != null) {
      widget.onCellEdited!(rowId, columnId, newValue);
    }

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final colIdx = visibleColumns.indexWhere((c) => c.id == columnId);
    if (colIdx != -1) {
      var nextColIdx = colIdx + 1;
      while (nextColIdx < visibleColumns.length) {
        final col = visibleColumns[nextColIdx];
        if (col.editable && col.type is! FxBooleanCellType) {
          final row = widget.rows.firstWhere((r) => r.id == rowId);
          _startEditing(rowId, col.id, row.cells[col.id]);
          widget.onCellsSelected?.call({(rowId: rowId, columnId: col.id)});
          return;
        }
        nextColIdx++;
      }
    }

    final rowIdx = widget.rows.indexWhere((r) => r.id == rowId);
    if (rowIdx != -1 && rowIdx + 1 < widget.rows.length) {
      final nextRow = widget.rows[rowIdx + 1];
      if (nextRow.enabled) {
        for (final col in visibleColumns) {
          if (col.editable && col.type is! FxBooleanCellType) {
            _startEditing(nextRow.id, col.id, nextRow.cells[col.id]);
            widget.onCellsSelected?.call({
              (rowId: nextRow.id, columnId: col.id),
            });
            return;
          }
        }
      }
    }

    _cancelEdit();
  }

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
    _editingController?.dispose();
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
      final visibleColumns = widget.columns.where((c) => c.visible).toList();
      for (final col in visibleColumns) {
        nextSelection.add((rowId: rowId, columnId: col.id));
      }
      widget.onCellsSelected!(nextSelection);
    }
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_editingRowId != null) {
      return KeyEventResult.ignored;
    }

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    if (widget.rows.isEmpty ||
        visibleColumns.isEmpty ||
        widget.onCellsSelected == null ||
        widget.selectionMode == FxGridSelectionMode.none) {
      return KeyEventResult.ignored;
    }

    int currentRow = -1;
    int currentCol = -1;
    if (widget.selectedCells.isNotEmpty) {
      final lastSelected = widget.selectedCells.last;
      currentRow = widget.rows.indexWhere((r) => r.id == lastSelected.rowId);
      currentCol = visibleColumns.indexWhere(
        (c) => c.id == lastSelected.columnId,
      );
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (widget.selectedCells.isNotEmpty) {
        final lastSelected = widget.selectedCells.last;
        final selectedRow = widget.rows.firstWhere(
          (r) => r.id == lastSelected.rowId,
        );
        final col = visibleColumns.firstWhere(
          (c) => c.id == lastSelected.columnId,
        );
        if (selectedRow.enabled &&
            col.editable &&
            col.type is! FxBooleanCellType) {
          _startEditing(selectedRow.id, col.id, selectedRow.cells[col.id]);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
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
      nextCol = currentCol == -1 ? visibleColumns.length - 1 : currentCol - 1;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      nextRow = currentRow == -1 ? 0 : currentRow;
      nextCol = visibleColumns.length - 1;
    } else {
      return KeyEventResult.ignored;
    }

    if (nextRow < 0) nextRow = 0;
    if (nextRow >= widget.rows.length) nextRow = widget.rows.length - 1;
    if (nextCol < 0) nextCol = 0;
    if (nextCol >= visibleColumns.length) nextCol = visibleColumns.length - 1;

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
    final targetCol = visibleColumns[nextCol];

    if (widget.selectionMode == FxGridSelectionMode.cell) {
      widget.onCellsSelected!({(rowId: targetRow.id, columnId: targetCol.id)});
    } else if (widget.selectionMode == FxGridSelectionMode.row) {
      final nextSelection = <({String rowId, String columnId})>{};
      for (final col in visibleColumns) {
        nextSelection.add((rowId: targetRow.id, columnId: col.id));
      }
      widget.onCellsSelected!(nextSelection);
    }

    return KeyEventResult.handled;
  }

  double _getColumnWidth(FxGridColumn column, double totalWidth) {
    final dynamicWidth = _columnWidths[column.id];
    if (dynamicWidth != null) {
      return dynamicWidth;
    }
    return switch (column.width) {
      FxFixedColumnWidth(:final value) => value,
      FxFractionalColumnWidth(:final value) => value * totalWidth,
      FxRemainingColumnWidth() => 100.0,
    };
  }

  table.TableSpanExtent _getColumnExtent(
    FxGridColumn column,
    double totalWidth,
  ) {
    final dynamicWidth = _columnWidths[column.id];
    if (dynamicWidth != null) {
      return table.FixedTableSpanExtent(dynamicWidth);
    }
    return column.width.toTableSpanExtent();
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
    final visibleColumns = widget.columns.where((c) => c.visible).toList();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleGridKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return DecoratedBox(
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
                columnCount: visibleColumns.length,
                rowCount: widget.rows.length + rowOffset,
                columnBuilder: (index) {
                  final column = visibleColumns[index];
                  return table.TableSpan(
                    extent: _getColumnExtent(column, totalWidth),
                    foregroundDecoration: _borderDecoration(
                      theme,
                      widget.showGridLines,
                    ),
                  );
                },
                rowBuilder: (index) {
                  final isHeader = widget.showHeaders && index == 0;
                  final dataRow = isHeader
                      ? null
                      : widget.rows[index - rowOffset];
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
                  final column = visibleColumns[vicinity.column];
                  if (widget.showHeaders && vicinity.row == 0) {
                    final sorted = column.id == widget.sortedColumnId;
                    return table.TableViewCell(
                      child: _HeaderCell(
                        caption: column.caption ?? column.id,
                        alignment: column.alignment,
                        sortable: column.sortable,
                        sorted: sorted,
                        ascending: widget.sortAscending,
                        onSort: () {
                          widget.onSortChanged?.call(
                            column.id,
                            sorted ? !widget.sortAscending : true,
                          );
                        },
                        onResize: (delta) {
                          final currentWidth = _getColumnWidth(
                            column,
                            totalWidth,
                          );
                          final newWidth = (currentWidth + delta).clamp(
                            column.minWidth,
                            1000.0,
                          );
                          setState(() {
                            _columnWidths[column.id] = newWidth;
                          });
                          widget.onColumnResized?.call(column.id, newWidth);
                        },
                      ),
                    );
                  }
                  final row = widget.rows[vicinity.row - rowOffset];
                  final selected = widget.selectedCells.any(
                    (cell) =>
                        cell.rowId == row.id && cell.columnId == column.id,
                  );
                  final hovered =
                      row.enabled &&
                      _hoveredCell != null &&
                      _hoveredCell!.row == vicinity.row &&
                      _hoveredCell!.column == vicinity.column;
                  final value = row.cells[column.id];
                  final isEditing =
                      _editingRowId == row.id && _editingColumnId == column.id;

                  Widget cellChild;

                  if (isEditing) {
                    if (column.type is FxChoiceCellType) {
                      final options = (column.type as FxChoiceCellType).options;
                      cellChild = Container(
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: options.contains(value?.toString())
                                ? value.toString()
                                : null,
                            isDense: true,
                            autofocus: true,
                            items: [
                              for (final opt in options)
                                DropdownMenuItem(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                            ],
                            onChanged: (newValue) {
                              _commitEdit(row.id, column.id, newValue ?? '');
                            },
                          ),
                        ),
                      );
                    } else {
                      cellChild = Container(
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.centerLeft,
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus &&
                                _editingRowId == row.id &&
                                _editingColumnId == column.id) {
                              _commitEdit(
                                row.id,
                                column.id,
                                _editingController!.text,
                              );
                            }
                          },
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.escape) {
                                _cancelEdit();
                                return KeyEventResult.handled;
                              }
                              if (event.logicalKey == LogicalKeyboardKey.tab) {
                                _commitAndMoveToNext(
                                  row.id,
                                  column.id,
                                  _editingController!.text,
                                );
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: _editingController,
                            autofocus: true,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (newValue) {
                              _commitEdit(row.id, column.id, newValue);
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    if (column.type is FxBooleanCellType) {
                      final bool val = value == true;
                      cellChild = GestureDetector(
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
                          child: Center(
                            child: Checkbox(
                              value: val,
                              onChanged: (row.enabled && column.editable)
                                  ? (newValue) {
                                      if (widget.onCellEdited != null) {
                                        widget.onCellEdited!(
                                          row.id,
                                          column.id,
                                          newValue,
                                        );
                                      }
                                      _handleCellTap(row.id, column.id);
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      );
                    } else {
                      cellChild = GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: row.enabled
                            ? () => _handleCellTap(row.id, column.id)
                            : null,
                        onDoubleTap: (row.enabled && column.editable)
                            ? () => _startEditing(row.id, column.id, value)
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
                      );
                    }
                  }

                  final validationError =
                      widget.validationErrors?[row.id]?[column.id];
                  if (validationError != null) {
                    cellChild = Tooltip(
                      message: validationError,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            cellChild,
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

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
                      child: cellChild,
                    ),
                  );
                },
              ),
            ),
          );
        },
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
    this.enabled = true,
    this.isSelected = false,
  });

  final String text;
  final FxCellAlignment alignment;
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
          style: TextStyle(fontWeight: FontWeight.normal, color: textColor),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.caption,
    required this.alignment,
    required this.sortable,
    required this.sorted,
    required this.ascending,
    this.onSort,
    this.onResize,
  });

  final String caption;
  final FxCellAlignment alignment;
  final bool sortable;
  final bool sorted;
  final bool ascending;
  final VoidCallback? onSort;
  final ValueChanged<double>? onResize;

  @override
  Widget build(BuildContext context) {
    // Chevron sort indicator
    Widget? sortIndicator;
    if (sortable && sorted) {
      sortIndicator = Icon(
        ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface,
      );
    }

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: sortable ? onSort : null,
      child: MouseRegion(
        cursor: sortable ? SystemMouseCursors.click : MouseCursor.defer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: switch (alignment) {
              FxCellAlignment.leading => MainAxisAlignment.start,
              FxCellAlignment.center => MainAxisAlignment.center,
              FxCellAlignment.trailing => MainAxisAlignment.end,
            },
            children: [
              Flexible(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (sortIndicator != null) ...[
                const SizedBox(width: 4),
                sortIndicator,
              ],
            ],
          ),
        ),
      ),
    );

    if (onResize == null) {
      return Align(
        alignment: switch (alignment) {
          FxCellAlignment.leading => Alignment.centerLeft,
          FxCellAlignment.center => Alignment.center,
          FxCellAlignment.trailing => Alignment.centerRight,
        },
        child: content,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: switch (alignment) {
            FxCellAlignment.leading => Alignment.centerLeft,
            FxCellAlignment.center => Alignment.center,
            FxCellAlignment.trailing => Alignment.centerRight,
          },
          child: content,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 8,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                onResize?.call(details.primaryDelta ?? 0.0);
              },
            ),
          ),
        ),
      ],
    );
  }
}
