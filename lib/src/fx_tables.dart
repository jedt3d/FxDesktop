import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart'
    as table;

import 'fx_lookup_provider.dart';
import 'fx_localizations.dart';
import 'fx_theme.dart';
import 'fx_undo.dart';

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

/// Represents a rectangular selection range of cells in an [FxGrid].
class FxGridCellRange {
  /// Creates a cell range from start cell to end cell.
  const FxGridCellRange({
    required this.startRowId,
    required this.startColumnId,
    required this.endRowId,
    required this.endColumnId,
  });

  /// The row ID of the starting cell.
  final String startRowId;

  /// The column ID of the starting cell.
  final String startColumnId;

  /// The row ID of the ending cell.
  final String endRowId;

  /// The column ID of the ending cell.
  final String endColumnId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FxGridCellRange &&
        other.startRowId == startRowId &&
        other.startColumnId == startColumnId &&
        other.endRowId == endRowId &&
        other.endColumnId == endColumnId;
  }

  @override
  int get hashCode =>
      Object.hash(startRowId, startColumnId, endRowId, endColumnId);

  @override
  String toString() {
    return 'FxGridCellRange(start: ($startRowId, $startColumnId), end: ($endRowId, $endColumnId))';
  }
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

  /// Creates a lookup cell type.
  const factory FxCellType.lookup(FxLookupProvider provider) = FxLookupCellType;

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
      case 'lookup':
        final providerJson = json['provider'] as Map<String, Object?>?;
        FxLookupProvider provider;
        if (providerJson != null) {
          final pType = providerJson['type'] as String?;
          if (pType == 'map') {
            final mapData =
                (providerJson['map'] as Map?)?.cast<Object?, String>().map(
                  (k, v) => MapEntry(k, v),
                ) ??
                const <Object?, String>{};
            provider = FxMapLookupProvider(mapData);
          } else if (pType == 'enum') {
            final labels =
                (providerJson['labels'] as Map?)?.cast<String, String>() ??
                const <String, String>{};
            provider = FxMapLookupProvider<String>(labels);
          } else {
            provider = const FxMapLookupProvider<String>({});
          }
        } else {
          provider = const FxMapLookupProvider<String>({});
        }
        return FxLookupCellType(provider);
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

/// A lookup cell type.
class FxLookupCellType extends FxCellType {
  /// Creates a lookup cell type.
  const FxLookupCellType(this.provider);

  /// The lookup provider.
  final FxLookupProvider provider;

  @override
  Map<String, Object?> toJson() => {
    'type': 'lookup',
    'provider': provider.toJson(),
  };
}

/// Callback signature for custom cell rendering.
typedef FxCellRendererBuilder =
    Widget Function(
      BuildContext context,
      String rowId,
      String columnId,
      Object? value,
      bool isSelected,
      bool isHovered,
    );

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
    this.lineWrap = false,
    this.supportStyledText = false,
    this.cellRenderer,
    this.hasActionButton = false,
    this.actionIcon,
    this.onActionPressed,
    this.inputMask,
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

  /// Whether long text line wraps in cells of this column.
  final bool lineWrap;

  /// Whether the cell text supports rich styled tags (**bold**, *italic*, ~underline~).
  final bool supportStyledText;

  /// Optional custom cell renderer builder callback.
  final FxCellRendererBuilder? cellRenderer;

  /// Whether to show an action/ellipsis button at the end of the cell editor.
  final bool hasActionButton;

  /// Custom icon for the action button. Defaults to `Icons.more_horiz`.
  final IconData? actionIcon;

  /// Callback invoked when the action button is pressed.
  final void Function(String rowId, String columnId, Object? value)?
  onActionPressed;

  /// Input mask pattern for text fields (e.g., '(###) ###-####').
  /// '#' matches a digit, 'A' matches a letter, '*' matches any character.
  final String? inputMask;

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
      'lineWrap': lineWrap,
      'supportStyledText': supportStyledText,
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
    this.cellBackgroundColorBuilder,
    this.allowRowReordering = false,
    this.onRowReordered,
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

  /// Callback to build conditional background color for a cell.
  final Color? Function(String rowId, String columnId, Object? value)?
  cellBackgroundColorBuilder;

  /// Whether manual drag-and-drop row reordering is allowed.
  final bool allowRowReordering;

  /// Callback triggered when a row is reordered.
  final void Function(int oldIndex, int newIndex)? onRowReordered;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxListBox',
      'xojo_desktop_class': 'DesktopListBox',
      'allowRowReordering': allowRowReordering,
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
  final Map<String, bool> _columnLineWrapOverrides = {};
  String? _editingRowId;
  String? _editingColumnId;
  TextEditingController? _editingController;
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;
  String? _activeColumnId;
  int? _draggedOverRowIndex;
  bool _isDragAbove = true;

  bool _getColumnLineWrap(FxListBoxColumn column) {
    return _columnLineWrapOverrides[column.id] ?? column.lineWrap;
  }

  void _commitCellEdit(String rowId, String columnId, Object? newValue) {
    final row = widget.rows.firstWhere((r) => r.id == rowId);
    final oldValue = row.cells[columnId];
    if (oldValue == newValue) {
      return;
    }

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null && widget.onCellEdited != null) {
      final col = widget.columns.firstWhere((c) => c.id == columnId);
      final colLabel = col.caption.isNotEmpty ? col.caption : col.id;
      undoController.commit(
        FxUndoAction(
          label: fxDesktopLocalizationsOf(context).tableEditUndoLabel(colLabel),
          apply: () => widget.onCellEdited?.call(rowId, columnId, newValue),
          revert: () => widget.onCellEdited?.call(rowId, columnId, oldValue),
        ),
      );
    } else {
      widget.onCellEdited?.call(rowId, columnId, newValue);
    }
  }

  Future<void> _handleCopy() async {
    if (widget.selectedRowIds.isEmpty || widget.rows.isEmpty) return;

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final List<String> lines = [];

    for (final row in widget.rows) {
      if (widget.selectedRowIds.contains(row.id)) {
        final List<String> rowVals = [];
        for (final col in visibleColumns) {
          rowVals.add(row.cells[col.id]?.toString() ?? '');
        }
        lines.add(rowVals.join('\t'));
      }
    }

    if (lines.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
  }

  List<List<String>> _parseTsv(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final List<List<String>> result = [];
    for (final line in lines) {
      if (line.isEmpty && line == lines.last) {
        continue;
      }
      result.add(line.split('\t'));
    }
    return result;
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text == null || text.isEmpty) return;

    final grid = _parseTsv(text);
    if (grid.isEmpty) return;

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    if (visibleColumns.isEmpty || widget.rows.isEmpty) return;

    int startRowIdx = 0;
    if (widget.selectedRowIds.isNotEmpty) {
      final firstSelectedId = widget.selectedRowIds.first;
      final rIdx = widget.rows.indexWhere((r) => r.id == firstSelectedId);
      if (rIdx != -1) startRowIdx = rIdx;
    }

    final actions = <FxUndoAction>[];

    for (var r = 0; r < grid.length; r++) {
      final targetRowIdx = startRowIdx + r;
      if (targetRowIdx >= widget.rows.length) break;

      final row = widget.rows[targetRowIdx];
      if (!row.enabled) continue;

      final rowVals = grid[r];
      for (var c = 0; c < rowVals.length; c++) {
        if (c >= visibleColumns.length) break;

        final col = visibleColumns[c];
        if (!col.editable) continue;

        final rawValue = rowVals[c];
        final oldValue = row.cells[col.id];

        Object? newValue;
        if (col.type is FxBooleanCellType) {
          final valLower = rawValue.trim().toLowerCase();
          newValue = valLower == 'true' || valLower == '1' || valLower == 'yes';
        } else {
          newValue = rawValue;
        }

        if (oldValue != newValue) {
          final colLabel = col.caption.isNotEmpty ? col.caption : col.id;
          actions.add(
            FxUndoAction(
              label: fxDesktopLocalizationsOf(
                context,
              ).tableEditUndoLabel(colLabel),
              apply: () => widget.onCellEdited?.call(row.id, col.id, newValue),
              revert: () => widget.onCellEdited?.call(row.id, col.id, oldValue),
            ),
          );
        }
      }
    }

    if (actions.isEmpty) return;

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null) {
      undoController.commitBatch(
        fxDesktopLocalizationsOf(context).tablePasteValuesUndoLabel,
        actions,
      );
    } else {
      for (final action in actions) {
        action.apply();
      }
    }
  }

  void _startEditing(String rowId, String columnId, Object? currentValue) {
    final col = widget.columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => widget.columns.first,
    );
    final String initialText;
    if (col.type is FxLookupCellType) {
      initialText = (col.type as FxLookupCellType).provider.getDisplayValue(
        currentValue,
      );
    } else {
      initialText = currentValue?.toString() ?? '';
    }
    setState(() {
      _editingRowId = rowId;
      _editingColumnId = columnId;
      _editingController = TextEditingController(text: initialText);
    });
  }

  void _commitEdit(String rowId, String columnId, String newValue) {
    _commitCellEdit(rowId, columnId, newValue);
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
    _commitCellEdit(rowId, columnId, newValue);

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
    _verticalController = ScrollController()..addListener(_cancelEdit);
    _horizontalController = ScrollController()..addListener(_cancelEdit);
  }

  @override
  void didUpdateWidget(FxListBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _focusNode).removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
    for (final col in widget.columns) {
      final oldCol = oldWidget.columns.firstWhere(
        (c) => c.id == col.id,
        orElse: () => col,
      );
      if (oldCol.lineWrap != col.lineWrap) {
        _columnLineWrapOverrides.remove(col.id);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _editingController?.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
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

    final hasModifier =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.keyC && hasModifier) {
      _handleCopy();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyV && hasModifier) {
      _handlePaste();
      return KeyEventResult.handled;
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
              fxDesktopLocalizationsOf(context).tableNoRecords,
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
                    widget.errorText ??
                        fxDesktopLocalizationsOf(context).tableLoadError,
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

  double _getRowHeight(
    FxListBoxRow row,
    List<FxListBoxColumn> visibleColumns,
    double totalWidth,
  ) {
    if (row.height != null) {
      return row.height!;
    }
    double maxCellHeight = widget.rowHeight;
    final defaultStyle = DefaultTextStyle.of(context).style;
    final cellStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.normal),
    );

    for (final col in visibleColumns) {
      if (_getColumnLineWrap(col)) {
        final rawValue = row.cells[col.id];
        if (rawValue != null &&
            rawValue is! bool &&
            !_isImplicitCheckbox(col, rawValue)) {
          final text = rawValue.toString();
          final colWidth = _getColumnWidth(col, totalWidth);
          final textWidth = (colWidth - 16.0).clamp(0.0, double.infinity);

          final textPainter = TextPainter(
            text: TextSpan(
              children: col.supportStyledText
                  ? _parseStyledText(text, cellStyle)
                  : [TextSpan(text: text, style: cellStyle)],
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: textWidth);
          final cellHeight = textPainter.height + 10.0;
          if (cellHeight > maxCellHeight) {
            maxCellHeight = cellHeight;
          }
        }
      }
    }
    return maxCellHeight;
  }

  void _autoFitColumn(FxListBoxColumn column, double totalWidth) {
    double maxNeededWidth = 0.0;
    final defaultStyle = DefaultTextStyle.of(context).style;

    final headerStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.w600),
    );
    final headerPainter = TextPainter(
      text: TextSpan(text: column.caption, style: headerStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    double headerWidth = headerPainter.width + 16.0;
    if (column.sortable) {
      headerWidth += 20.0;
    }
    maxNeededWidth = headerWidth;

    final cellStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.normal),
    );
    for (final row in widget.rows) {
      final rawValue = row.cells[column.id];
      if (column.type is FxBooleanCellType ||
          _isImplicitCheckbox(column, rawValue)) {
        const double checkboxWidth = 40.0;
        if (checkboxWidth > maxNeededWidth) {
          maxNeededWidth = checkboxWidth;
        }
      } else {
        final text = rawValue?.toString() ?? '';
        final cellPainter = TextPainter(
          text: TextSpan(text: text, style: cellStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final cellWidth = cellPainter.width + 16.0;
        if (cellWidth > maxNeededWidth) {
          maxNeededWidth = cellWidth;
        }
      }
    }

    final newWidth = (maxNeededWidth + 4.0).clamp(column.minWidth, 1000.0);
    final capWidth = totalWidth * 0.5;

    final double targetWidth;
    final bool targetWrap;
    if (newWidth > capWidth) {
      targetWidth = capWidth.clamp(column.minWidth, 1000.0);
      targetWrap = true;
    } else {
      targetWidth = newWidth;
      targetWrap = false;
    }

    final oldWidth = _getColumnWidth(column, totalWidth);
    final oldWrap = _getColumnLineWrap(column);

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null) {
      final label = column.caption.isNotEmpty ? column.caption : column.id;
      undoController.commit(
        FxUndoAction(
          label: fxDesktopLocalizationsOf(context).tableAutoFitUndoLabel(label),
          apply: () {
            setState(() {
              _columnWidths[column.id] = targetWidth;
              _columnLineWrapOverrides[column.id] = targetWrap;
            });
            widget.onColumnResized?.call(column.id, targetWidth);
          },
          revert: () {
            setState(() {
              _columnWidths[column.id] = oldWidth;
              _columnLineWrapOverrides[column.id] = oldWrap;
            });
            widget.onColumnResized?.call(column.id, oldWidth);
          },
        ),
      );
    } else {
      setState(() {
        _columnWidths[column.id] = targetWidth;
        _columnLineWrapOverrides[column.id] = targetWrap;
      });
      widget.onColumnResized?.call(column.id, targetWidth);
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
    if (widget.allowRowReordering) {
      visibleColumns.insert(
        0,
        const FxListBoxColumn(
          id: '__reorder_handle__',
          caption: '',
          width: FxColumnWidth.fixed(30),
          minWidth: 30,
          visible: true,
          editable: false,
        ),
      );
    }

    final activeRowId = widget.selectedRowIds.isEmpty
        ? null
        : widget.selectedRowIds.last;
    final activeRowIndex = activeRowId == null
        ? -1
        : widget.rows.indexWhere((r) => r.id == activeRowId);
    final activeColId =
        _activeColumnId ??
        (activeRowId != null && visibleColumns.isNotEmpty
            ? (widget.allowRowReordering && visibleColumns.length > 1
                  ? visibleColumns[1].id
                  : visibleColumns.first.id)
            : null);
    final activeColIndex = activeColId == null
        ? -1
        : visibleColumns.indexWhere((c) => c.id == activeColId);

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
              child: Scrollbar(
                controller: _verticalController,
                interactive: true,
                thumbVisibility: true,
                notificationPredicate: (notification) =>
                    notification.depth == 0 &&
                    notification.metrics.axis == Axis.vertical,
                child: Scrollbar(
                  controller: _horizontalController,
                  interactive: true,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.depth == 0 &&
                      notification.metrics.axis == Axis.horizontal,
                  child: table.TableView.builder(
                    pinnedRowCount: 1,
                    columnCount: visibleColumns.length,
                    rowCount: widget.rows.length + 1,
                    verticalDetails: ScrollableDetails.vertical(
                      controller: _verticalController,
                    ),
                    horizontalDetails: ScrollableDetails.horizontal(
                      controller: _horizontalController,
                    ),
                    columnBuilder: (index) {
                      final column = visibleColumns[index];
                      final isActive =
                          activeColIndex != -1 && index == activeColIndex;
                      return table.TableSpan(
                        extent: _getColumnExtent(column, totalWidth),
                        foregroundDecoration: _borderDecoration(
                          theme: theme,
                          showGridLines: widget.showGridLines,
                          isActive: isActive,
                          isColumn: true,
                        ),
                      );
                    },
                    rowBuilder: (index) {
                      final isHeader = index == 0;
                      final row = isHeader ? null : widget.rows[index - 1];
                      final isSelected =
                          row != null && widget.selectedRowIds.contains(row.id);
                      final isHovered = index == _hoveredRowIndex;
                      final isActive =
                          !isHeader &&
                          activeRowIndex != -1 &&
                          (index - 1) == activeRowIndex;
                      final isDragTarget =
                          widget.allowRowReordering &&
                          _draggedOverRowIndex == (index - 1);
                      return table.TableSpan(
                        extent: table.FixedTableSpanExtent(
                          isHeader
                              ? widget.headerHeight
                              : _getRowHeight(row!, visibleColumns, totalWidth),
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
                          theme: theme,
                          showGridLines: widget.showGridLines,
                          isActive: isActive,
                          isColumn: false,
                          isDragTarget: isDragTarget,
                          isDragAbove: _isDragAbove,
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
                            alignment: _getResolvedAlignment(
                              column,
                              widget.rows,
                            ),
                            sortable:
                                column.sortable &&
                                column.id != '__reorder_handle__',
                            sorted: sorted,
                            ascending: widget.sortAscending,
                            onSort: column.id == '__reorder_handle__'
                                ? null
                                : () {
                                    widget.onSortChanged?.call(
                                      column.id,
                                      sorted ? !widget.sortAscending : true,
                                    );
                                  },
                            onResize: column.id == '__reorder_handle__'
                                ? null
                                : (delta) {
                                    final currentWidth = _getColumnWidth(
                                      column,
                                      totalWidth,
                                    );
                                    final newWidth = (currentWidth + delta)
                                        .clamp(column.minWidth, 1000.0);
                                    setState(() {
                                      _columnWidths[column.id] = newWidth;
                                    });
                                    widget.onColumnResized?.call(
                                      column.id,
                                      newWidth,
                                    );
                                  },
                            onDoubleResize: column.id == '__reorder_handle__'
                                ? null
                                : () {
                                    _autoFitColumn(column, totalWidth);
                                  },
                          ),
                        );
                      }
                      final row = widget.rows[vicinity.row - 1];
                      final value = row.cells[column.id];
                      final isSelected = widget.selectedRowIds.contains(row.id);
                      final isEditing =
                          _editingRowId == row.id &&
                          _editingColumnId == column.id;

                      Widget cellChild;

                      if (column.id == '__reorder_handle__') {
                        cellChild = Center(
                          child: Draggable<int>(
                            data: vicinity.row - 1,
                            feedback: Material(
                              elevation: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.selectionBackground.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  fxDesktopLocalizationsOf(
                                    context,
                                  ).tableMovingRowFeedback(vicinity.row),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: const Opacity(
                              opacity: 0.3,
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      } else if (isEditing) {
                        if (column.type is FxChoiceCellType) {
                          final options =
                              (column.type as FxChoiceCellType).options;
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
                                  _commitEdit(
                                    row.id,
                                    column.id,
                                    newValue ?? '',
                                  );
                                },
                              ),
                            ),
                          );
                        } else if (column.type is FxLookupCellType) {
                          cellChild = FxLookupComboBox(
                            provider:
                                (column.type as FxLookupCellType).provider,
                            initialValue: value,
                            onCommit: (newValue) {
                              _commitCellEdit(row.id, column.id, newValue);
                              _cancelEdit();
                            },
                            onCancel: _cancelEdit,
                          );
                        } else {
                          final List<TextInputFormatter> formatters = [];
                          if (column.inputMask != null) {
                            formatters.add(
                              FxMaskTextInputFormatter(column.inputMask!),
                            );
                          }
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
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.tab) {
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _editingController,
                                      autofocus: true,
                                      style: const TextStyle(fontSize: 13),
                                      inputFormatters: formatters.isNotEmpty
                                          ? formatters
                                          : null,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onSubmitted: (newValue) {
                                        _commitEdit(
                                          row.id,
                                          column.id,
                                          newValue,
                                        );
                                      },
                                    ),
                                  ),
                                  if (column.hasActionButton)
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 16,
                                        icon: Icon(
                                          column.actionIcon ?? Icons.more_horiz,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          column.onActionPressed?.call(
                                            row.id,
                                            column.id,
                                            _editingController!.text,
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else if (column.cellRenderer != null) {
                        final isHovered =
                            (vicinity.row - 1 == _hoveredRowIndex);
                        final customChild = column.cellRenderer!(
                          context,
                          row.id,
                          column.id,
                          value,
                          isSelected,
                          isHovered,
                        );
                        cellChild = GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: row.enabled
                              ? () {
                                  setState(() {
                                    _activeColumnId = column.id;
                                  });
                                  _handleRowTap(row.id);
                                }
                              : null,
                          onDoubleTap: (row.enabled && column.editable)
                              ? () {
                                  setState(() {
                                    _activeColumnId = column.id;
                                  });
                                  _startEditing(row.id, column.id, value);
                                }
                              : null,
                          child: customChild,
                        );
                      } else {
                        final isCheckbox =
                            column.type is FxBooleanCellType ||
                            _isImplicitCheckbox(column, value);
                        if (isCheckbox) {
                          final bool val =
                              (value == true ||
                              value?.toString().toLowerCase().trim() == 'true');
                          cellChild = Center(
                            child: Checkbox(
                              value: val,
                              onChanged: (row.enabled && column.editable)
                                  ? (newValue) {
                                      Object? committedValue = newValue;
                                      if (value is String) {
                                        committedValue = newValue.toString();
                                      }
                                      _commitCellEdit(
                                        row.id,
                                        column.id,
                                        committedValue,
                                      );
                                    }
                                  : null,
                            ),
                          );
                        } else {
                          final String displayText;
                          if (column.type is FxLookupCellType) {
                            displayText = (column.type as FxLookupCellType)
                                .provider
                                .getDisplayValue(value);
                          } else {
                            displayText = value?.toString() ?? '';
                          }
                          cellChild = GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: row.enabled
                                ? () {
                                    setState(() {
                                      _activeColumnId = column.id;
                                    });
                                    _handleRowTap(row.id);
                                  }
                                : null,
                            onDoubleTap: (row.enabled && column.editable)
                                ? () {
                                    setState(() {
                                      _activeColumnId = column.id;
                                    });
                                    _startEditing(row.id, column.id, value);
                                  }
                                : null,
                            child: _CellText(
                              text: displayText,
                              alignment: _getResolvedAlignment(
                                column,
                                widget.rows,
                              ),
                              enabled: row.enabled,
                              isSelected: isSelected,
                              lineWrap: _getColumnLineWrap(column),
                              supportStyledText: column.supportStyledText,
                            ),
                          );
                        }
                      }

                      final customBgColor = widget.cellBackgroundColorBuilder
                          ?.call(row.id, column.id, value);
                      final isHovered = (vicinity.row - 1) == _hoveredRowIndex;
                      final cellBgColor = _getHighlightCellColor(
                        context: context,
                        theme: theme,
                        isSelected: isSelected,
                        isHovered: isHovered,
                        rowIndex: vicinity.row - 1,
                        colIndex: vicinity.column,
                        activeRowIndex: activeRowIndex,
                        activeColIndex: activeColIndex,
                        customBgColor: customBgColor,
                        primaryColor: Theme.of(context).colorScheme.primary,
                      );
                      cellChild = Container(
                        color: cellBgColor,
                        child: cellChild,
                      );

                      // Apply percentage progress bar overlay
                      final pct = _parsePercentage(value);
                      if (pct != null) {
                        cellChild = Stack(
                          children: [
                            cellChild,
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 5,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FractionallySizedBox(
                                  widthFactor: pct / 100.0,
                                  child: Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(180),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (widget.allowRowReordering && vicinity.row > 0) {
                        final childToDrag = cellChild;
                        cellChild = DragTarget<int>(
                          onWillAcceptWithDetails: (details) {
                            return details.data != (vicinity.row - 1);
                          },
                          onAcceptWithDetails: (details) {
                            final draggedIndex = details.data;
                            setState(() {
                              _draggedOverRowIndex = null;
                            });
                            widget.onRowReordered?.call(
                              draggedIndex,
                              vicinity.row - 1,
                            );
                          },
                          onMove: (details) {
                            final targetIndex = vicinity.row - 1;
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final localPosition = renderBox.globalToLocal(
                                details.offset,
                              );
                              final isAbove =
                                  localPosition.dy <
                                  (renderBox.size.height / 2);
                              if (_draggedOverRowIndex != targetIndex ||
                                  _isDragAbove != isAbove) {
                                setState(() {
                                  _draggedOverRowIndex = targetIndex;
                                  _isDragAbove = isAbove;
                                });
                              }
                            }
                          },
                          onLeave: (data) {
                            setState(() {
                              _draggedOverRowIndex = null;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return childToDrag;
                          },
                        );
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

                      final cellVal = row.cells[column.id];
                      final String valueText;
                      if (column.type is FxBooleanCellType) {
                        valueText = (cellVal == true)
                            ? fxDesktopLocalizationsOf(
                                context,
                              ).tableBooleanChecked
                            : fxDesktopLocalizationsOf(
                                context,
                              ).tableBooleanUnchecked;
                      } else {
                        valueText = cellVal?.toString() ?? '';
                      }

                      final cellSemantics = Semantics(
                        selected: isSelected,
                        enabled: row.enabled,
                        label: fxDesktopLocalizationsOf(context)
                            .tableCellSemantics(
                              vicinity.row,
                              column.caption,
                              valueText,
                            ),
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

                      return table.TableViewCell(child: cellSemantics);
                    },
                  ),
                ),
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
    this.lineWrap = false,
    this.supportStyledText = false,
    this.cellRenderer,
    this.hasActionButton = false,
    this.actionIcon,
    this.onActionPressed,
    this.inputMask,
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

  /// Whether long text line wraps in cells of this column.
  final bool lineWrap;

  /// Whether the cell text supports rich styled tags (**bold**, *italic*, ~underline~).
  final bool supportStyledText;

  /// Optional custom cell renderer builder callback.
  final FxCellRendererBuilder? cellRenderer;

  /// Whether to show an action/ellipsis button at the end of the cell editor.
  final bool hasActionButton;

  /// Custom icon for the action button. Defaults to `Icons.more_horiz`.
  final IconData? actionIcon;

  /// Callback invoked when the action button is pressed.
  final void Function(String rowId, String columnId, Object? value)?
  onActionPressed;

  /// Input mask pattern for text fields (e.g., '(###) ###-####').
  /// '#' matches a digit, 'A' matches a letter, '*' matches any character.
  final String? inputMask;

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
      'lineWrap': lineWrap,
      'supportStyledText': supportStyledText,
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
    this.selectedRange,
    this.onRangeSelected,
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
    this.cellBackgroundColorBuilder,
    this.allowRowReordering = false,
    this.onRowReordered,
  });

  /// Column descriptors.
  final List<FxGridColumn> columns;

  /// Row descriptors.
  final List<FxGridRow> rows;

  /// Set of selected cell descriptors.
  final Set<({String rowId, String columnId})> selectedCells;

  /// Cell selection callback.
  final ValueChanged<Set<({String rowId, String columnId})>>? onCellsSelected;

  /// Optional rectangular selection range.
  final FxGridCellRange? selectedRange;

  /// Optional callback when a range is selected.
  final ValueChanged<FxGridCellRange?>? onRangeSelected;

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

  /// Callback to build conditional background color for a cell.
  final Color? Function(String rowId, String columnId, Object? value)?
  cellBackgroundColorBuilder;

  /// Whether manual drag-and-drop row reordering is allowed.
  final bool allowRowReordering;

  /// Callback triggered when a row is reordered.
  final void Function(int oldIndex, int newIndex)? onRowReordered;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxGrid',
      'xojo_desktop_class': 'DesktopGrid',
      'selectionMode': selectionMode.name,
      'state': state.name,
      'sortedColumnId': sortedColumnId,
      'sortAscending': sortAscending,
      'allowRowReordering': allowRowReordering,
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
  final Map<String, bool> _columnLineWrapOverrides = {};
  String? _editingRowId;
  String? _editingColumnId;
  TextEditingController? _editingController;
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;
  String? _activeColumnId;
  int? _draggedOverRowIndex;
  bool _isDragAbove = true;

  bool _getColumnLineWrap(FxGridColumn column) {
    return _columnLineWrapOverrides[column.id] ?? column.lineWrap;
  }

  final Map<({String rowId, String columnId}), BuildContext> _cellContexts = {};
  ({String rowId, String columnId})? _dragStartCell;
  ({String rowId, String columnId})? _lastDragEndCell;
  ({String rowId, String columnId})? _keyboardRangeAnchor;

  void _registerCell(String rowId, String columnId, BuildContext context) {
    _cellContexts[(rowId: rowId, columnId: columnId)] = context;
  }

  void _unregisterCell(String rowId, String columnId) {
    _cellContexts.remove((rowId: rowId, columnId: columnId));
  }

  ({String rowId, String columnId})? _findCellUnderPosition(
    Offset globalPosition,
  ) {
    for (final entry in _cellContexts.entries) {
      final context = entry.value;
      if (!context.mounted) continue;
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final localPos = renderBox.globalToLocal(globalPosition);
        if (renderBox.paintBounds.contains(localPos)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  Set<({String rowId, String columnId})> _calculateRangeSelection(
    ({String rowId, String columnId}) start,
    ({String rowId, String columnId}) end,
  ) {
    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final startRowIdx = widget.rows.indexWhere((r) => r.id == start.rowId);
    final endRowIdx = widget.rows.indexWhere((r) => r.id == end.rowId);
    final startColIdx = visibleColumns.indexWhere(
      (c) => c.id == start.columnId,
    );
    final endColIdx = visibleColumns.indexWhere((c) => c.id == end.columnId);

    if (startRowIdx == -1 ||
        endRowIdx == -1 ||
        startColIdx == -1 ||
        endColIdx == -1) {
      return {};
    }

    final minRow = startRowIdx < endRowIdx ? startRowIdx : endRowIdx;
    final maxRow = startRowIdx > endRowIdx ? startRowIdx : endRowIdx;
    final minCol = startColIdx < endColIdx ? startColIdx : endColIdx;
    final maxCol = startColIdx > endColIdx ? startColIdx : endColIdx;

    final selection = <({String rowId, String columnId})>{};
    for (var r = minRow; r <= maxRow; r++) {
      final row = widget.rows[r];
      if (row.enabled) {
        for (var c = minCol; c <= maxCol; c++) {
          selection.add((rowId: row.id, columnId: visibleColumns[c].id));
        }
      }
    }
    return selection;
  }

  bool _isCellInRange(String rowId, String columnId, FxGridCellRange range) {
    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final startRowIdx = widget.rows.indexWhere((r) => r.id == range.startRowId);
    final endRowIdx = widget.rows.indexWhere((r) => r.id == range.endRowId);
    final startColIdx = visibleColumns.indexWhere(
      (c) => c.id == range.startColumnId,
    );
    final endColIdx = visibleColumns.indexWhere(
      (c) => c.id == range.endColumnId,
    );

    if (startRowIdx == -1 ||
        endRowIdx == -1 ||
        startColIdx == -1 ||
        endColIdx == -1) {
      return false;
    }

    final rowIdx = widget.rows.indexWhere((r) => r.id == rowId);
    final colIdx = visibleColumns.indexWhere((c) => c.id == columnId);
    if (rowIdx == -1 || colIdx == -1) return false;

    final minRow = startRowIdx < endRowIdx ? startRowIdx : endRowIdx;
    final maxRow = startRowIdx > endRowIdx ? startRowIdx : endRowIdx;
    final minCol = startColIdx < endColIdx ? startColIdx : endColIdx;
    final maxCol = startColIdx > endColIdx ? startColIdx : endColIdx;

    return rowIdx >= minRow &&
        rowIdx <= maxRow &&
        colIdx >= minCol &&
        colIdx <= maxCol;
  }

  void _commitCellEdit(String rowId, String columnId, Object? newValue) {
    final row = widget.rows.firstWhere((r) => r.id == rowId);
    final oldValue = row.cells[columnId];
    if (oldValue == newValue) {
      return;
    }

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null && widget.onCellEdited != null) {
      final col = widget.columns.firstWhere((c) => c.id == columnId);
      final colLabel = col.caption ?? col.id;
      undoController.commit(
        FxUndoAction(
          label: fxDesktopLocalizationsOf(context).tableEditUndoLabel(colLabel),
          apply: () => widget.onCellEdited?.call(rowId, columnId, newValue),
          revert: () => widget.onCellEdited?.call(rowId, columnId, oldValue),
        ),
      );
    } else {
      widget.onCellEdited?.call(rowId, columnId, newValue);
    }
  }

  Future<void> _handleCopy() async {
    if (widget.selectedCells.isEmpty || widget.rows.isEmpty) return;

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    final selectedRowIndices = <int>{};
    final selectedColIndices = <int>{};
    for (final cell in widget.selectedCells) {
      final rIdx = widget.rows.indexWhere((r) => r.id == cell.rowId);
      final cIdx = visibleColumns.indexWhere((c) => c.id == cell.columnId);
      if (rIdx != -1) selectedRowIndices.add(rIdx);
      if (cIdx != -1) selectedColIndices.add(cIdx);
    }
    if (selectedRowIndices.isEmpty || selectedColIndices.isEmpty) return;

    final minRow = selectedRowIndices.reduce((a, b) => a < b ? a : b);
    final maxRow = selectedRowIndices.reduce((a, b) => a > b ? a : b);
    final minCol = selectedColIndices.reduce((a, b) => a < b ? a : b);
    final maxCol = selectedColIndices.reduce((a, b) => a > b ? a : b);

    final List<String> lines = [];
    for (var r = minRow; r <= maxRow; r++) {
      final row = widget.rows[r];
      final List<String> rowVals = [];
      for (var c = minCol; c <= maxCol; c++) {
        final col = visibleColumns[c];
        final isSelected = widget.selectedCells.any(
          (cell) => cell.rowId == row.id && cell.columnId == col.id,
        );
        if (isSelected) {
          rowVals.add(row.cells[col.id]?.toString() ?? '');
        } else {
          rowVals.add('');
        }
      }
      lines.add(rowVals.join('\t'));
    }
    final tsvString = lines.join('\n');
    await Clipboard.setData(ClipboardData(text: tsvString));
  }

  List<List<String>> _parseTsv(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final List<List<String>> result = [];
    for (final line in lines) {
      if (line.isEmpty && line == lines.last) {
        continue;
      }
      result.add(line.split('\t'));
    }
    return result;
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text == null || text.isEmpty) return;

    final grid = _parseTsv(text);
    if (grid.isEmpty) return;

    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    if (visibleColumns.isEmpty || widget.rows.isEmpty) return;

    int startRowIdx = 0;
    int startColIdx = 0;

    if (widget.selectedCells.isNotEmpty) {
      int minRow = widget.rows.length;
      int minCol = visibleColumns.length;

      for (final cell in widget.selectedCells) {
        final rIdx = widget.rows.indexWhere((r) => r.id == cell.rowId);
        final cIdx = visibleColumns.indexWhere((c) => c.id == cell.columnId);
        if (rIdx != -1 && rIdx < minRow) minRow = rIdx;
        if (cIdx != -1 && cIdx < minCol) minCol = cIdx;
      }
      if (minRow < widget.rows.length) startRowIdx = minRow;
      if (minCol < visibleColumns.length) startColIdx = minCol;
    }

    final actions = <FxUndoAction>[];

    for (var r = 0; r < grid.length; r++) {
      final targetRowIdx = startRowIdx + r;
      if (targetRowIdx >= widget.rows.length) break;

      final row = widget.rows[targetRowIdx];
      if (!row.enabled) continue;

      final rowVals = grid[r];
      for (var c = 0; c < rowVals.length; c++) {
        final targetColIdx = startColIdx + c;
        if (targetColIdx >= visibleColumns.length) break;

        final col = visibleColumns[targetColIdx];
        if (!col.editable) continue;

        final rawValue = rowVals[c];
        final oldValue = row.cells[col.id];

        Object? newValue;
        if (col.type is FxBooleanCellType) {
          final valLower = rawValue.trim().toLowerCase();
          newValue = valLower == 'true' || valLower == '1' || valLower == 'yes';
        } else {
          newValue = rawValue;
        }

        if (oldValue != newValue) {
          final colLabel = col.caption ?? col.id;
          actions.add(
            FxUndoAction(
              label: fxDesktopLocalizationsOf(
                context,
              ).tableEditUndoLabel(colLabel),
              apply: () => widget.onCellEdited?.call(row.id, col.id, newValue),
              revert: () => widget.onCellEdited?.call(row.id, col.id, oldValue),
            ),
          );
        }
      }
    }

    if (actions.isEmpty) return;

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null) {
      undoController.commitBatch(
        fxDesktopLocalizationsOf(context).tablePasteValuesUndoLabel,
        actions,
      );
    } else {
      for (final action in actions) {
        action.apply();
      }
    }
  }

  void _startEditing(String rowId, String columnId, Object? currentValue) {
    final col = widget.columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => widget.columns.first,
    );
    final String initialText;
    if (col.type is FxLookupCellType) {
      initialText = (col.type as FxLookupCellType).provider.getDisplayValue(
        currentValue,
      );
    } else {
      initialText = currentValue?.toString() ?? '';
    }
    setState(() {
      _editingRowId = rowId;
      _editingColumnId = columnId;
      _editingController = TextEditingController(text: initialText);
    });
  }

  void _commitEdit(String rowId, String columnId, String newValue) {
    _commitCellEdit(rowId, columnId, newValue);
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
    _commitCellEdit(rowId, columnId, newValue);

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
    _verticalController = ScrollController()..addListener(_cancelEdit);
    _horizontalController = ScrollController()..addListener(_cancelEdit);
  }

  @override
  void didUpdateWidget(FxGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _focusNode).removeListener(_onFocusChanged);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
    for (final col in widget.columns) {
      final oldCol = oldWidget.columns.firstWhere(
        (c) => c.id == col.id,
        orElse: () => col,
      );
      if (oldCol.lineWrap != col.lineWrap) {
        _columnLineWrapOverrides.remove(col.id);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _editingController?.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleCellTap(String rowId, String columnId) {
    setState(() {
      _activeColumnId = columnId;
    });
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
    } else if (widget.selectionMode == FxGridSelectionMode.range) {
      _keyboardRangeAnchor = (rowId: rowId, columnId: columnId);
      widget.onCellsSelected!({(rowId: rowId, columnId: columnId)});
      widget.onRangeSelected?.call(
        FxGridCellRange(
          startRowId: rowId,
          startColumnId: columnId,
          endRowId: rowId,
          endColumnId: columnId,
        ),
      );
    }
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_editingRowId != null) {
      return KeyEventResult.ignored;
    }

    final hasModifier =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.keyC && hasModifier) {
      _handleCopy();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyV && hasModifier) {
      _handlePaste();
      return KeyEventResult.handled;
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

    setState(() {
      _activeColumnId = targetCol.id;
    });

    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    if (widget.selectionMode == FxGridSelectionMode.cell) {
      widget.onCellsSelected!({(rowId: targetRow.id, columnId: targetCol.id)});
    } else if (widget.selectionMode == FxGridSelectionMode.row) {
      final nextSelection = <({String rowId, String columnId})>{};
      for (final col in visibleColumns) {
        nextSelection.add((rowId: targetRow.id, columnId: col.id));
      }
      widget.onCellsSelected!(nextSelection);
    } else if (widget.selectionMode == FxGridSelectionMode.range) {
      if (isShiftPressed) {
        _keyboardRangeAnchor ??= widget.selectedCells.isNotEmpty
            ? widget.selectedCells.first
            : (rowId: targetRow.id, columnId: targetCol.id);
        final range = _calculateRangeSelection(_keyboardRangeAnchor!, (
          rowId: targetRow.id,
          columnId: targetCol.id,
        ));
        widget.onCellsSelected?.call(range);
        widget.onRangeSelected?.call(
          FxGridCellRange(
            startRowId: _keyboardRangeAnchor!.rowId,
            startColumnId: _keyboardRangeAnchor!.columnId,
            endRowId: targetRow.id,
            endColumnId: targetCol.id,
          ),
        );
      } else {
        _keyboardRangeAnchor = (rowId: targetRow.id, columnId: targetCol.id);
        widget.onCellsSelected?.call({_keyboardRangeAnchor!});
        widget.onRangeSelected?.call(
          FxGridCellRange(
            startRowId: _keyboardRangeAnchor!.rowId,
            startColumnId: _keyboardRangeAnchor!.columnId,
            endRowId: _keyboardRangeAnchor!.rowId,
            endColumnId: _keyboardRangeAnchor!.columnId,
          ),
        );
      }
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
              fxDesktopLocalizationsOf(context).tableNoRecords,
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
                    widget.errorText ??
                        fxDesktopLocalizationsOf(context).tableLoadError,
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

  double _getRowHeight(
    FxGridRow row,
    List<FxGridColumn> visibleColumns,
    double totalWidth,
  ) {
    if (row.height != null) {
      return row.height!;
    }
    double maxCellHeight = widget.rowHeight;
    final defaultStyle = DefaultTextStyle.of(context).style;
    final cellStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.normal),
    );

    for (final col in visibleColumns) {
      if (_getColumnLineWrap(col)) {
        final rawValue = row.cells[col.id];
        if (rawValue != null &&
            rawValue is! bool &&
            !_isImplicitCheckbox(col, rawValue)) {
          final text = rawValue.toString();
          final colWidth = _getColumnWidth(col, totalWidth);
          final textWidth = (colWidth - 16.0).clamp(0.0, double.infinity);

          final textPainter = TextPainter(
            text: TextSpan(
              children: col.supportStyledText
                  ? _parseStyledText(text, cellStyle)
                  : [TextSpan(text: text, style: cellStyle)],
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: textWidth);
          final cellHeight = textPainter.height + 10.0;
          if (cellHeight > maxCellHeight) {
            maxCellHeight = cellHeight;
          }
        }
      }
    }
    return maxCellHeight;
  }

  void _autoFitColumn(FxGridColumn column, double totalWidth) {
    double maxNeededWidth = 0.0;
    final defaultStyle = DefaultTextStyle.of(context).style;

    final captionText = column.caption ?? column.id;
    final headerStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.w600),
    );
    final headerPainter = TextPainter(
      text: TextSpan(text: captionText, style: headerStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    double headerWidth = headerPainter.width + 16.0;
    if (column.sortable) {
      headerWidth += 20.0;
    }
    maxNeededWidth = headerWidth;

    final cellStyle = defaultStyle.merge(
      const TextStyle(fontWeight: FontWeight.normal),
    );
    for (final row in widget.rows) {
      final rawValue = row.cells[column.id];
      if (column.type is FxBooleanCellType ||
          _isImplicitCheckbox(column, rawValue)) {
        const double checkboxWidth = 40.0;
        if (checkboxWidth > maxNeededWidth) {
          maxNeededWidth = checkboxWidth;
        }
      } else {
        final text = rawValue?.toString() ?? '';
        final cellPainter = TextPainter(
          text: TextSpan(text: text, style: cellStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final cellWidth = cellPainter.width + 16.0;
        if (cellWidth > maxNeededWidth) {
          maxNeededWidth = cellWidth;
        }
      }
    }

    final newWidth = (maxNeededWidth + 4.0).clamp(column.minWidth, 1000.0);
    final capWidth = totalWidth * 0.5;

    final double targetWidth;
    final bool targetWrap;
    if (newWidth > capWidth) {
      targetWidth = capWidth.clamp(column.minWidth, 1000.0);
      targetWrap = true;
    } else {
      targetWidth = newWidth;
      targetWrap = false;
    }

    final oldWidth = _getColumnWidth(column, totalWidth);
    final oldWrap = _getColumnLineWrap(column);

    final undoController = FxUndoScope.maybeOf(context);
    if (undoController != null) {
      undoController.commit(
        FxUndoAction(
          label: fxDesktopLocalizationsOf(
            context,
          ).tableAutoFitUndoLabel(captionText),
          apply: () {
            setState(() {
              _columnWidths[column.id] = targetWidth;
              _columnLineWrapOverrides[column.id] = targetWrap;
            });
            widget.onColumnResized?.call(column.id, targetWidth);
          },
          revert: () {
            setState(() {
              _columnWidths[column.id] = oldWidth;
              _columnLineWrapOverrides[column.id] = oldWrap;
            });
            widget.onColumnResized?.call(column.id, oldWidth);
          },
        ),
      );
    } else {
      setState(() {
        _columnWidths[column.id] = targetWidth;
        _columnLineWrapOverrides[column.id] = targetWrap;
      });
      widget.onColumnResized?.call(column.id, targetWidth);
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
    if (widget.allowRowReordering) {
      visibleColumns.insert(
        0,
        const FxGridColumn(
          id: '__reorder_handle__',
          caption: '',
          width: FxColumnWidth.fixed(30),
          minWidth: 30,
          visible: true,
          editable: false,
        ),
      );
    }

    final activeCell = widget.selectedCells.isEmpty
        ? null
        : widget.selectedCells.last;
    final activeRowIndex = activeCell == null
        ? -1
        : widget.rows.indexWhere((r) => r.id == activeCell.rowId);
    final activeColId = _activeColumnId ?? activeCell?.columnId;
    final activeColIndex = activeColId == null
        ? -1
        : visibleColumns.indexWhere((c) => c.id == activeColId);

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
              child: Scrollbar(
                controller: _verticalController,
                interactive: true,
                thumbVisibility: true,
                notificationPredicate: (notification) =>
                    notification.depth == 0 &&
                    notification.metrics.axis == Axis.vertical,
                child: Scrollbar(
                  controller: _horizontalController,
                  interactive: true,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.depth == 0 &&
                      notification.metrics.axis == Axis.horizontal,
                  child: table.TableView.builder(
                    pinnedRowCount: widget.showHeaders ? 1 : 0,
                    columnCount: visibleColumns.length,
                    rowCount: widget.rows.length + rowOffset,
                    verticalDetails: ScrollableDetails.vertical(
                      controller: _verticalController,
                    ),
                    horizontalDetails: ScrollableDetails.horizontal(
                      controller: _horizontalController,
                    ),
                    columnBuilder: (index) {
                      final column = visibleColumns[index];
                      final isActive =
                          activeColIndex != -1 && index == activeColIndex;
                      return table.TableSpan(
                        extent: _getColumnExtent(column, totalWidth),
                        foregroundDecoration: _borderDecoration(
                          theme: theme,
                          showGridLines: widget.showGridLines,
                          isActive: isActive,
                          isColumn: true,
                        ),
                      );
                    },
                    rowBuilder: (index) {
                      final isHeader = widget.showHeaders && index == 0;
                      final dataRow = isHeader
                          ? null
                          : widget.rows[index - rowOffset];
                      final isActive =
                          !isHeader &&
                          activeRowIndex != -1 &&
                          (index - rowOffset) == activeRowIndex;
                      final isDragTarget =
                          widget.allowRowReordering &&
                          _draggedOverRowIndex == (index - rowOffset);
                      return table.TableSpan(
                        extent: table.FixedTableSpanExtent(
                          isHeader
                              ? widget.headerHeight
                              : _getRowHeight(
                                  dataRow!,
                                  visibleColumns,
                                  totalWidth,
                                ),
                        ),
                        backgroundDecoration: table.TableSpanDecoration(
                          color: isHeader
                              ? theme.headerBackground
                              : index.isEven
                              ? theme.alternatingRowBackground
                              : Theme.of(context).colorScheme.surface,
                        ),
                        foregroundDecoration: _borderDecoration(
                          theme: theme,
                          showGridLines: widget.showGridLines,
                          isActive: isActive,
                          isColumn: false,
                          isDragTarget: isDragTarget,
                          isDragAbove: _isDragAbove,
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
                            alignment: _getResolvedAlignment(
                              column,
                              widget.rows,
                            ),
                            sortable:
                                column.sortable &&
                                column.id != '__reorder_handle__',
                            sorted: sorted,
                            ascending: widget.sortAscending,
                            onSort: column.id == '__reorder_handle__'
                                ? null
                                : () {
                                    widget.onSortChanged?.call(
                                      column.id,
                                      sorted ? !widget.sortAscending : true,
                                    );
                                  },
                            onResize: column.id == '__reorder_handle__'
                                ? null
                                : (delta) {
                                    final currentWidth = _getColumnWidth(
                                      column,
                                      totalWidth,
                                    );
                                    final newWidth = (currentWidth + delta)
                                        .clamp(column.minWidth, 1000.0);
                                    setState(() {
                                      _columnWidths[column.id] = newWidth;
                                    });
                                    widget.onColumnResized?.call(
                                      column.id,
                                      newWidth,
                                    );
                                  },
                            onDoubleResize: column.id == '__reorder_handle__'
                                ? null
                                : () {
                                    _autoFitColumn(column, totalWidth);
                                  },
                          ),
                        );
                      }
                      final row = widget.rows[vicinity.row - rowOffset];
                      final isDataRow = widget.showHeaders
                          ? vicinity.row > 0
                          : vicinity.row >= 0;
                      final dataRowIndex = vicinity.row - rowOffset;
                      final value = row.cells[column.id];
                      final inRange =
                          widget.selectionMode == FxGridSelectionMode.range &&
                          widget.selectedRange != null &&
                          _isCellInRange(
                            row.id,
                            column.id,
                            widget.selectedRange!,
                          );
                      final selected =
                          inRange ||
                          widget.selectedCells.any(
                            (cell) =>
                                cell.rowId == row.id &&
                                cell.columnId == column.id,
                          );
                      final hovered =
                          _hoveredCell != null &&
                          _hoveredCell!.row == vicinity.row &&
                          _hoveredCell!.column == vicinity.column;
                      final isEditing =
                          _editingRowId == row.id &&
                          _editingColumnId == column.id;

                      Widget cellChild;

                      if (column.id == '__reorder_handle__') {
                        cellChild = Center(
                          child: Draggable<int>(
                            data: vicinity.row - rowOffset,
                            feedback: Material(
                              elevation: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.selectionBackground.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  fxDesktopLocalizationsOf(
                                    context,
                                  ).tableMovingRowFeedback(
                                    vicinity.row - rowOffset + 1,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: const Opacity(
                              opacity: 0.3,
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      } else if (isEditing) {
                        if (column.type is FxChoiceCellType) {
                          final options =
                              (column.type as FxChoiceCellType).options;
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
                                  _commitEdit(
                                    row.id,
                                    column.id,
                                    newValue ?? '',
                                  );
                                },
                              ),
                            ),
                          );
                        } else if (column.type is FxLookupCellType) {
                          cellChild = FxLookupComboBox(
                            provider:
                                (column.type as FxLookupCellType).provider,
                            initialValue: value,
                            onCommit: (newValue) {
                              _commitCellEdit(row.id, column.id, newValue);
                              _cancelEdit();
                            },
                            onCancel: _cancelEdit,
                          );
                        } else {
                          final List<TextInputFormatter> formatters = [];
                          if (column.inputMask != null) {
                            formatters.add(
                              FxMaskTextInputFormatter(column.inputMask!),
                            );
                          }
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
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.tab) {
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _editingController,
                                      autofocus: true,
                                      style: const TextStyle(fontSize: 13),
                                      inputFormatters: formatters.isNotEmpty
                                          ? formatters
                                          : null,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onSubmitted: (newValue) {
                                        _commitEdit(
                                          row.id,
                                          column.id,
                                          newValue,
                                        );
                                      },
                                    ),
                                  ),
                                  if (column.hasActionButton)
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 16,
                                        icon: Icon(
                                          column.actionIcon ?? Icons.more_horiz,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          column.onActionPressed?.call(
                                            row.id,
                                            column.id,
                                            _editingController!.text,
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        final customBgColor = widget.cellBackgroundColorBuilder
                            ?.call(row.id, column.id, value);
                        final cellBgColor = _getHighlightCellColor(
                          context: context,
                          theme: theme,
                          isSelected: selected,
                          isHovered: hovered,
                          rowIndex: vicinity.row - rowOffset,
                          colIndex: vicinity.column,
                          activeRowIndex: activeRowIndex,
                          activeColIndex: activeColIndex,
                          customBgColor: customBgColor,
                          primaryColor: Theme.of(context).colorScheme.primary,
                        );
                        if (column.cellRenderer != null) {
                          final customChild = column.cellRenderer!(
                            context,
                            row.id,
                            column.id,
                            value,
                            selected,
                            hovered,
                          );
                          cellChild = GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: row.enabled
                                ? () => _handleCellTap(row.id, column.id)
                                : null,
                            onDoubleTap: (row.enabled && column.editable)
                                ? () => _startEditing(row.id, column.id, value)
                                : null,
                            child: ColoredBox(
                              color: cellBgColor,
                              child: customChild,
                            ),
                          );
                        } else {
                          final isCheckbox =
                              column.type is FxBooleanCellType ||
                              _isImplicitCheckbox(column, value);
                          if (isCheckbox) {
                            final bool val =
                                (value == true ||
                                value?.toString().toLowerCase().trim() ==
                                    'true');
                            cellChild = GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: row.enabled
                                  ? () => _handleCellTap(row.id, column.id)
                                  : null,
                              child: ColoredBox(
                                color: cellBgColor,
                                child: Center(
                                  child: Checkbox(
                                    value: val,
                                    onChanged: (row.enabled && column.editable)
                                        ? (newValue) {
                                            Object? committedValue = newValue;
                                            if (value is String) {
                                              committedValue = newValue
                                                  .toString();
                                            }
                                            _commitCellEdit(
                                              row.id,
                                              column.id,
                                              committedValue,
                                            );
                                            _handleCellTap(row.id, column.id);
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final String displayText;
                            if (column.type is FxLookupCellType) {
                              displayText = (column.type as FxLookupCellType)
                                  .provider
                                  .getDisplayValue(value);
                            } else {
                              displayText = value?.toString() ?? '';
                            }
                            cellChild = GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: row.enabled
                                  ? () => _handleCellTap(row.id, column.id)
                                  : null,
                              onDoubleTap: (row.enabled && column.editable)
                                  ? () =>
                                        _startEditing(row.id, column.id, value)
                                  : null,
                              child: ColoredBox(
                                color: cellBgColor,
                                child: _CellText(
                                  text: displayText,
                                  alignment: _getResolvedAlignment(
                                    column,
                                    widget.rows,
                                  ),
                                  enabled: row.enabled,
                                  isSelected: selected,
                                  lineWrap: _getColumnLineWrap(column),
                                  supportStyledText: column.supportStyledText,
                                ),
                              ),
                            );
                          }
                        }
                      }

                      if (widget.allowRowReordering && isDataRow) {
                        final childToDrag = cellChild;
                        cellChild = DragTarget<int>(
                          onWillAcceptWithDetails: (details) {
                            return details.data != dataRowIndex;
                          },
                          onAcceptWithDetails: (details) {
                            final draggedIndex = details.data;
                            setState(() {
                              _draggedOverRowIndex = null;
                            });
                            widget.onRowReordered?.call(
                              draggedIndex,
                              dataRowIndex,
                            );
                          },
                          onMove: (details) {
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final localPosition = renderBox.globalToLocal(
                                details.offset,
                              );
                              final isAbove =
                                  localPosition.dy <
                                  (renderBox.size.height / 2);
                              if (_draggedOverRowIndex != dataRowIndex ||
                                  _isDragAbove != isAbove) {
                                setState(() {
                                  _draggedOverRowIndex = dataRowIndex;
                                  _isDragAbove = isAbove;
                                });
                              }
                            }
                          },
                          onLeave: (data) {
                            setState(() {
                              _draggedOverRowIndex = null;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return childToDrag;
                          },
                        );
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

                      // Apply percentage progress bar overlay (only if not editing)
                      if (!isEditing) {
                        final pct = _parsePercentage(value);
                        if (pct != null) {
                          cellChild = Stack(
                            children: [
                              cellChild,
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 5,
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: pct / 100.0,
                                    child: Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(180),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }

                      if (row.enabled &&
                          widget.selectionMode == FxGridSelectionMode.range) {
                        cellChild = Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (event) {
                            _dragStartCell = (
                              rowId: row.id,
                              columnId: column.id,
                            );
                            _lastDragEndCell = _dragStartCell;
                            _keyboardRangeAnchor = _dragStartCell;
                            widget.onCellsSelected?.call({_dragStartCell!});
                            widget.onRangeSelected?.call(
                              FxGridCellRange(
                                startRowId: _dragStartCell!.rowId,
                                startColumnId: _dragStartCell!.columnId,
                                endRowId: _dragStartCell!.rowId,
                                endColumnId: _dragStartCell!.columnId,
                              ),
                            );
                          },
                          onPointerMove: (event) {
                            if (_dragStartCell == null) return;
                            final cell = _findCellUnderPosition(event.position);
                            if (cell != null && cell != _lastDragEndCell) {
                              _lastDragEndCell = cell;
                              final rangeCells = _calculateRangeSelection(
                                _dragStartCell!,
                                cell,
                              );
                              widget.onCellsSelected?.call(rangeCells);
                              widget.onRangeSelected?.call(
                                FxGridCellRange(
                                  startRowId: _dragStartCell!.rowId,
                                  startColumnId: _dragStartCell!.columnId,
                                  endRowId: cell.rowId,
                                  endColumnId: cell.columnId,
                                ),
                              );
                            }
                          },
                          onPointerUp: (event) {
                            _dragStartCell = null;
                            _lastDragEndCell = null;
                          },
                          child: cellChild,
                        );
                      }

                      final cellWrapper = _GridCellWrapper(
                        rowId: row.id,
                        columnId: column.id,
                        gridState: this,
                        child: cellChild,
                      );

                      final cellVal = row.cells[column.id];
                      final String valueText;
                      if (column.type is FxBooleanCellType) {
                        valueText = (cellVal == true)
                            ? fxDesktopLocalizationsOf(
                                context,
                              ).tableBooleanChecked
                            : fxDesktopLocalizationsOf(
                                context,
                              ).tableBooleanUnchecked;
                      } else {
                        valueText = cellVal?.toString() ?? '';
                      }

                      final errorMsg =
                          widget.validationErrors?[row.id]?[column.id];
                      final String errorSuffix = errorMsg != null
                          ? ', ${fxDesktopLocalizationsOf(context).tableValidationErrorSuffix(errorMsg)}'
                          : '';
                      final colLabel = column.caption ?? column.id;

                      final cellSemantics = Semantics(
                        selected: selected,
                        enabled: row.enabled,
                        label: fxDesktopLocalizationsOf(context)
                            .tableCellSemantics(
                              vicinity.row,
                              colLabel,
                              '$valueText$errorSuffix',
                            ),
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
                          child: cellWrapper,
                        ),
                      );

                      return table.TableViewCell(child: cellSemantics);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Color _getHighlightCellColor({
  required BuildContext context,
  required FxTheme theme,
  required bool isSelected,
  required bool isHovered,
  required int rowIndex,
  required int colIndex,
  required int activeRowIndex,
  required int activeColIndex,
  required Color? customBgColor,
  required Color primaryColor,
}) {
  if (isSelected) {
    if (customBgColor != null) {
      return Color.alphaBlend(
        customBgColor.withValues(alpha: 0.4),
        theme.selectionBackground,
      );
    }
    return theme.selectionBackground;
  }

  final Color baseColor;
  if (customBgColor != null) {
    baseColor = customBgColor;
  } else if (isHovered) {
    baseColor = Theme.of(context).hoverColor;
  } else if (rowIndex.isEven) {
    baseColor = theme.alternatingRowBackground;
  } else {
    baseColor = Theme.of(context).colorScheme.surface;
  }

  final isRowActive = activeRowIndex != -1 && rowIndex == activeRowIndex;
  final isColActive = activeColIndex != -1 && colIndex == activeColIndex;

  if (isRowActive || isColActive) {
    final hslBase = HSLColor.fromColor(baseColor);
    final hslPrimary = HSLColor.fromColor(primaryColor);

    double hue = hslBase.hue;
    double saturation = hslBase.saturation;
    double lightness = hslBase.lightness;

    if (saturation < 0.03) {
      hue = hslPrimary.hue;
      saturation = 0.08;
      if (lightness > 0.95) {
        lightness = 0.95;
      }
    }

    final newSaturation = (saturation + 0.20).clamp(0.0, 1.0);
    double newLightness = lightness;
    if (lightness > 0.9) {
      newLightness = (lightness - 0.03).clamp(0.0, 1.0);
    } else if (lightness < 0.2) {
      newLightness = (lightness + 0.03).clamp(0.0, 1.0);
    }

    return HSLColor.fromColor(baseColor)
        .withHue(hue)
        .withSaturation(newSaturation)
        .withLightness(newLightness)
        .toColor();
  }

  return baseColor;
}

table.TableSpanDecoration? _borderDecoration({
  required FxTheme theme,
  required bool showGridLines,
  required bool isActive,
  required bool isColumn,
  bool isDragTarget = false,
  bool isDragAbove = true,
}) {
  final defaultColor = theme.gridLineColor;

  BorderSide? leadingBorder;
  BorderSide? trailingBorder;

  if (showGridLines) {
    trailingBorder = BorderSide(color: defaultColor);
  }

  if (isDragTarget) {
    final highlightColor = theme.selectionBackground;
    final highlightBorder = BorderSide(color: highlightColor, width: 2.5);
    if (isDragAbove) {
      leadingBorder = highlightBorder;
    } else {
      trailingBorder = highlightBorder;
    }
  }

  if (leadingBorder != null || trailingBorder != null) {
    return table.TableSpanDecoration(
      border: table.TableSpanBorder(
        leading: leadingBorder ?? BorderSide.none,
        trailing: trailingBorder ?? BorderSide.none,
      ),
    );
  }

  return null;
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
    this.lineWrap = false,
    this.supportStyledText = false,
  });

  final String text;
  final FxCellAlignment alignment;
  final bool enabled;
  final bool isSelected;
  final bool lineWrap;
  final bool supportStyledText;

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

    final baseStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: textColor,
    );

    final Widget childWidget;
    if (supportStyledText) {
      childWidget = Text.rich(
        TextSpan(children: _parseStyledText(text, baseStyle)),
        maxLines: lineWrap ? null : 1,
        overflow: lineWrap ? null : TextOverflow.ellipsis,
        textAlign: textAlign,
      );
    } else {
      childWidget = Text(
        text,
        maxLines: lineWrap ? null : 1,
        overflow: lineWrap ? null : TextOverflow.ellipsis,
        textAlign: textAlign,
        style: baseStyle,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Align(
        alignment: switch (alignment) {
          FxCellAlignment.leading => Alignment.topLeft,
          FxCellAlignment.center => Alignment.topCenter,
          FxCellAlignment.trailing => Alignment.topRight,
        },
        child: childWidget,
      ),
    );
  }
}

List<InlineSpan> _parseStyledText(String text, TextStyle baseStyle) {
  if (!text.contains('<b>') &&
      !text.contains('<i>') &&
      !text.contains('<u>') &&
      !text.contains('</b>') &&
      !text.contains('</i>') &&
      !text.contains('</u>') &&
      !text.contains('**') &&
      !text.contains('*') &&
      !text.contains('~')) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final List<InlineSpan> spans = [];
  int index = 0;

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  TextStyle currentStyle() {
    var style = baseStyle;
    if (isBold) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }
    if (isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (isUnderline) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    return style;
  }

  while (index < text.length) {
    if (text.startsWith('<b>', index)) {
      isBold = true;
      index += 3;
    } else if (text.startsWith('</b>', index)) {
      isBold = false;
      index += 4;
    } else if (text.startsWith('<i>', index)) {
      isItalic = true;
      index += 3;
    } else if (text.startsWith('</i>', index)) {
      isItalic = false;
      index += 4;
    } else if (text.startsWith('<u>', index)) {
      isUnderline = true;
      index += 3;
    } else if (text.startsWith('</u>', index)) {
      isUnderline = false;
      index += 4;
    } else if (text.startsWith('**', index)) {
      isBold = !isBold;
      index += 2;
    } else if (text.startsWith('*', index)) {
      isItalic = !isItalic;
      index += 1;
    } else if (text.startsWith('~', index)) {
      isUnderline = !isUnderline;
      index += 1;
    } else {
      int nextTagIndex = text.length;
      final candidates = [
        '<b>',
        '</b>',
        '<i>',
        '</i>',
        '<u>',
        '</u>',
        '**',
        '*',
        '~',
      ];
      for (final candidate in candidates) {
        final pos = text.indexOf(candidate, index);
        if (pos != -1 && pos < nextTagIndex) {
          nextTagIndex = pos;
        }
      }
      final chunk = text.substring(index, nextTagIndex);
      if (chunk.isNotEmpty) {
        spans.add(TextSpan(text: chunk, style: currentStyle()));
      }
      index = nextTagIndex;
    }
  }

  return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
}

class _HeaderCell extends StatefulWidget {
  const _HeaderCell({
    required this.caption,
    required this.alignment,
    required this.sortable,
    required this.sorted,
    required this.ascending,
    this.onSort,
    this.onResize,
    this.onDoubleResize,
  });

  final String caption;
  final FxCellAlignment alignment;
  final bool sortable;
  final bool sorted;
  final bool ascending;
  final VoidCallback? onSort;
  final ValueChanged<double>? onResize;
  final VoidCallback? onDoubleResize;

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    // Chevron sort indicator
    Widget? sortIndicator;
    if (widget.sortable && widget.sorted) {
      sortIndicator = Icon(
        widget.ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface,
      );
    }

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.sortable ? widget.onSort : null,
      child: MouseRegion(
        cursor: widget.sortable ? SystemMouseCursors.click : MouseCursor.defer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: switch (widget.alignment) {
              FxCellAlignment.leading => MainAxisAlignment.start,
              FxCellAlignment.center => MainAxisAlignment.center,
              FxCellAlignment.trailing => MainAxisAlignment.end,
            },
            children: [
              Flexible(
                child: Text(
                  widget.caption,
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

    final sortAnnouncement = widget.sorted
        ? (widget.ascending ? ', sorted ascending' : ', sorted descending')
        : '';
    final labelText =
        '${widget.caption} column header${widget.sortable ? ", sortable" : ""}$sortAnnouncement';

    final Widget childWidget = widget.onResize == null
        ? Align(
            alignment: switch (widget.alignment) {
              FxCellAlignment.leading => Alignment.centerLeft,
              FxCellAlignment.center => Alignment.center,
              FxCellAlignment.trailing => Alignment.centerRight,
            },
            child: content,
          )
        : Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: switch (widget.alignment) {
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
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) {
                      final now = DateTime.now();
                      if (_lastTapTime != null &&
                          now.difference(_lastTapTime!) <
                              const Duration(milliseconds: 300)) {
                        widget.onDoubleResize?.call();
                      }
                      _lastTapTime = now;
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        widget.onResize?.call(details.primaryDelta ?? 0.0);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      label: labelText,
      button: widget.sortable,
      enabled: true,
      child: childWidget,
    );
  }
}

class _GridCellWrapper extends StatefulWidget {
  final String rowId;
  final String columnId;
  final Widget child;
  final _FxGridState gridState;

  const _GridCellWrapper({
    required this.rowId,
    required this.columnId,
    required this.child,
    required this.gridState,
  });

  @override
  State<_GridCellWrapper> createState() => _GridCellWrapperState();
}

class _GridCellWrapperState extends State<_GridCellWrapper> {
  @override
  void initState() {
    super.initState();
    widget.gridState._registerCell(widget.rowId, widget.columnId, context);
  }

  @override
  void didUpdateWidget(_GridCellWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gridState != widget.gridState ||
        oldWidget.rowId != widget.rowId ||
        oldWidget.columnId != widget.columnId) {
      oldWidget.gridState._unregisterCell(oldWidget.rowId, oldWidget.columnId);
      widget.gridState._registerCell(widget.rowId, widget.columnId, context);
    }
  }

  @override
  void dispose() {
    widget.gridState._unregisterCell(widget.rowId, widget.columnId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

bool _isNumericColumn(List<dynamic> rows, String columnId) {
  if (rows.isEmpty) return false;
  var hasValues = false;
  for (final row in rows) {
    final val = row.cells[columnId];
    if (val != null && val.toString().trim().isNotEmpty) {
      hasValues = true;
      final str = val.toString().trim();
      final cleanStr = str.endsWith('%')
          ? str.substring(0, str.length - 1).trim()
          : str;
      if (num.tryParse(cleanStr) == null) {
        return false;
      }
    }
  }
  return hasValues;
}

bool _isImplicitCheckbox(dynamic column, Object? value) {
  if (value == null) return false;
  final str = value.toString().trim().toLowerCase();
  return str == 'true' || str == 'false';
}

double? _parsePercentage(Object? value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.endsWith('%')) {
    final numStr = str.substring(0, str.length - 1).trim();
    final val = double.tryParse(numStr);
    if (val != null) {
      return val.clamp(0.0, 100.0);
    }
  }
  return null;
}

FxCellAlignment _getResolvedAlignment(dynamic column, List<dynamic> rows) {
  if (column.alignment == FxCellAlignment.leading) {
    if (_isNumericColumn(rows, column.id)) {
      return FxCellAlignment.trailing;
    }
  }
  return column.alignment;
}

/// A combo box dropdown cell editor hosted in Flutter's global Overlay.
class FxLookupComboBox<K> extends StatefulWidget {
  /// The lookup provider.
  final FxLookupProvider<K> provider;

  /// Initial key value.
  final Object? initialValue;

  /// Callback when a value is selected and committed.
  final void Function(K newValue) onCommit;

  /// Callback when editing is cancelled.
  final VoidCallback onCancel;

  /// Creates a lookup combo box.
  const FxLookupComboBox({
    super.key,
    required this.provider,
    required this.initialValue,
    required this.onCommit,
    required this.onCancel,
  });

  @override
  State<FxLookupComboBox<K>> createState() => _FxLookupComboBoxState<K>();
}

class _FxLookupComboBoxState<K> extends State<FxLookupComboBox<K>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<FxLookupItem<K>> _options = [];
  bool _isLoading = false;
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    final initialKey = widget.initialValue;
    if (initialKey is K) {
      _searchController.text = widget.provider.getDisplayValue(initialKey);
    }
    _loadOptions('');
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _commitActive();
        }
      });
    }
  }

  Future<void> _loadOptions(String query) async {
    setState(() => _isLoading = true);
    try {
      final opts = await widget.provider.getOptions(query);
      if (mounted) {
        setState(() {
          _options = opts;
          _highlightedIndex = 0;
          _isLoading = false;
        });
        _overlayEntry?.markNeedsBuild();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    final headers = widget.provider.getLookupHeaders();
    final isMultiColumn = headers.isNotEmpty;
    final overlayWidth = isMultiColumn
        ? (size.width * 2.5).clamp(350.0, 800.0)
        : size.width.clamp(200.0, 600.0);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: overlayWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          fxDesktopLocalizationsOf(
                            context,
                          ).lookupNoOptionsFound,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : isMultiColumn
                    ? _buildMultiColumnList(context, headers)
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          final option = _options[index];
                          final isHighlighted = index == _highlightedIndex;
                          return GestureDetector(
                            onTap: () {
                              widget.onCommit(option.key);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              color: isHighlighted
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Colors.transparent,
                              child: Text(
                                option.display,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildMultiColumnList(BuildContext context, List<String> headers) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              for (int h = 0; h < headers.length; h++) ...[
                if (h > 0) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headers[h],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Data rows
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              final isHighlighted = index == _highlightedIndex;
              final details = option.extraDetails ?? [option.display];
              return GestureDetector(
                onTap: () {
                  widget.onCommit(option.key);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (int d = 0; d < headers.length; d++) ...[
                        if (d > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            d < details.length ? details[d] : '',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _commitActive() {
    if (_options.isNotEmpty && _highlightedIndex < _options.length) {
      widget.onCommit(_options[_highlightedIndex].key);
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                if (_options.isNotEmpty) {
                  _highlightedIndex = (_highlightedIndex + 1) % _options.length;
                }
              });
              _overlayEntry?.markNeedsBuild();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                if (_options.isNotEmpty) {
                  _highlightedIndex =
                      (_highlightedIndex - 1 + _options.length) %
                      _options.length;
                }
              });
              _overlayEntry?.markNeedsBuild();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              _commitActive();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _hideOverlay();
              widget.onCancel();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    _loadOptions(val);
                    if (_overlayEntry == null) {
                      _showOverlay();
                    }
                  },
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// A [TextInputFormatter] that enforces a mask pattern on text input.
///
/// Mask characters:
/// * `#` — matches a digit (0–9)
/// * `A` — matches a letter (a–z, A–Z)
/// * `*` — matches any character
/// * Any other character is treated as a literal separator.
///
/// Example: `(###) ###-####` produces `(123) 456-7890`.
class FxMaskTextInputFormatter extends TextInputFormatter {
  /// Creates a mask input formatter with the given [mask] pattern.
  FxMaskTextInputFormatter(this.mask);

  /// The mask pattern string.
  final String mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract raw characters (non-separator chars) from the new value.
    final rawChars = <String>[];
    for (final ch in newValue.text.characters) {
      if (_isRawChar(ch)) {
        rawChars.add(ch);
      }
    }

    final buffer = StringBuffer();
    int rawIndex = 0;

    for (int i = 0; i < mask.length && rawIndex < rawChars.length; i++) {
      final maskChar = mask[i];
      if (maskChar == '#' || maskChar == 'A' || maskChar == '*') {
        final raw = rawChars[rawIndex];
        if (_matchesMask(maskChar, raw)) {
          buffer.write(raw);
          rawIndex++;
        } else {
          // Skip non-matching input characters.
          rawIndex++;
          i--; // retry this mask position with next raw char
        }
      } else {
        // Literal separator — insert it.
        buffer.write(maskChar);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Returns the raw (unmasked) value by stripping separator literals.
  String unmask(String maskedText) {
    final buffer = StringBuffer();
    int maskIdx = 0;
    for (int i = 0; i < maskedText.length && maskIdx < mask.length; i++) {
      final maskChar = mask[maskIdx];
      if (maskChar == '#' || maskChar == 'A' || maskChar == '*') {
        buffer.write(maskedText[i]);
      }
      maskIdx++;
    }
    return buffer.toString();
  }

  /// Applies the mask to a raw value string, returning the formatted output.
  String applyMask(String rawText) {
    final buffer = StringBuffer();
    int rawIndex = 0;
    for (int i = 0; i < mask.length && rawIndex < rawText.length; i++) {
      final maskChar = mask[i];
      if (maskChar == '#' || maskChar == 'A' || maskChar == '*') {
        buffer.write(rawText[rawIndex]);
        rawIndex++;
      } else {
        buffer.write(maskChar);
      }
    }
    return buffer.toString();
  }

  bool _isRawChar(String ch) {
    // A raw char is not a separator from our mask.
    // We identify separators as characters in the mask that aren't #, A, or *.
    return true; // Accept all chars; filtering happens during mask application.
  }

  static bool _matchesMask(String maskChar, String inputChar) {
    return switch (maskChar) {
      '#' => RegExp(r'[0-9]').hasMatch(inputChar),
      'A' => RegExp(r'[a-zA-Z]').hasMatch(inputChar),
      '*' => true,
      _ => false,
    };
  }
}
