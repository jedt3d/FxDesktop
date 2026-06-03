import 'package:flutter/material.dart';
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
class FxListBox extends StatelessWidget {
  /// Creates an FxDesktop list box.
  const FxListBox({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedRowId,
    this.onSelectionChanged,
    this.height = 260,
    this.headerHeight = 30,
    this.rowHeight = 28,
    this.showGridLines = true,
  });

  /// Column descriptors.
  final List<FxListBoxColumn> columns;

  /// Row descriptors.
  final List<FxListBoxRow> rows;

  /// Currently selected row id.
  final String? selectedRowId;

  /// Selection callback.
  final ValueChanged<String?>? onSelectionChanged;

  /// Preferred list box height.
  final double height;

  /// Header row height.
  final double headerHeight;

  /// Default row height.
  final double rowHeight;

  /// Whether to draw row/column separators.
  final bool showGridLines;

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxListBox',
      'xojo_desktop_class': 'DesktopListBox',
      'xojo_web_class': 'WebListBox',
      'columns': [for (final column in columns) column.toJson()],
      'rows': [for (final row in rows) row.toJson()],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = FxTheme.of(context);
    _validateColumns(columns);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: theme.gridLineColor),
      ),
      child: SizedBox(
        height: height,
        child: table.TableView.builder(
          pinnedRowCount: 1,
          columnCount: columns.length,
          rowCount: rows.length + 1,
          columnBuilder: (index) {
            return table.TableSpan(
              extent: table.FixedTableSpanExtent(columns[index].width),
              foregroundDecoration: _borderDecoration(theme, showGridLines),
            );
          },
          rowBuilder: (index) {
            final isHeader = index == 0;
            final row = isHeader ? null : rows[index - 1];
            final isSelected = row?.id == selectedRowId;
            return table.TableSpan(
              extent: table.FixedTableSpanExtent(
                isHeader ? headerHeight : (row?.height ?? rowHeight),
              ),
              backgroundDecoration: table.TableSpanDecoration(
                color: isHeader
                    ? theme.headerBackground
                    : isSelected
                    ? theme.selectionBackground
                    : index.isEven
                    ? theme.alternatingRowBackground
                    : Theme.of(context).colorScheme.surface,
              ),
              foregroundDecoration: _borderDecoration(theme, showGridLines),
            );
          },
          cellBuilder: (context, vicinity) {
            final column = columns[vicinity.column];
            if (vicinity.row == 0) {
              return table.TableViewCell(
                child: _CellText(
                  text: column.caption,
                  alignment: column.alignment,
                  isHeader: true,
                ),
              );
            }
            final row = rows[vicinity.row - 1];
            final value = row.cells[column.id];
            return table.TableViewCell(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: row.enabled
                    ? () => onSelectionChanged?.call(row.id)
                    : null,
                child: _CellText(
                  text: value?.toString() ?? '',
                  alignment: column.alignment,
                  enabled: row.enabled,
                ),
              ),
            );
          },
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
  const FxGridRow({required this.id, required this.cells, this.height});

  /// Stable row id.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, Object?> cells;

  /// Optional row height.
  final double? height;

  /// Converts this row to JSON.
  Map<String, Object?> toJson() {
    return {'id': id, 'cells': cells, 'height': height};
  }
}

/// A desktop data/cell grid comparable to Xojo's DesktopGrid.
class FxGrid extends StatelessWidget {
  /// Creates an FxDesktop data grid.
  const FxGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedCell,
    this.onCellSelected,
    this.height = 260,
    this.headerHeight = 30,
    this.rowHeight = 28,
    this.showHeaders = true,
    this.showGridLines = true,
  });

  /// Column descriptors.
  final List<FxGridColumn> columns;

  /// Row descriptors.
  final List<FxGridRow> rows;

  /// Selected cell as `(rowId, columnId)`.
  final ({String rowId, String columnId})? selectedCell;

  /// Cell selection callback.
  final void Function(String rowId, String columnId)? onCellSelected;

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

  /// Stable map for AI/generator use.
  Map<String, Object?> toTemplateMap() {
    return {
      'component': 'FxGrid',
      'xojo_desktop_class': 'DesktopGrid',
      'columns': [for (final column in columns) column.toJson()],
      'rows': [for (final row in rows) row.toJson()],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = FxTheme.of(context);
    _validateGridColumns(columns);
    final rowOffset = showHeaders ? 1 : 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: theme.gridLineColor),
      ),
      child: SizedBox(
        height: height,
        child: table.TableView.builder(
          pinnedRowCount: showHeaders ? 1 : 0,
          columnCount: columns.length,
          rowCount: rows.length + rowOffset,
          columnBuilder: (index) {
            return table.TableSpan(
              extent: table.FixedTableSpanExtent(columns[index].width),
              foregroundDecoration: _borderDecoration(theme, showGridLines),
            );
          },
          rowBuilder: (index) {
            final isHeader = showHeaders && index == 0;
            final dataRow = isHeader ? null : rows[index - rowOffset];
            return table.TableSpan(
              extent: table.FixedTableSpanExtent(
                isHeader ? headerHeight : (dataRow?.height ?? rowHeight),
              ),
              backgroundDecoration: table.TableSpanDecoration(
                color: isHeader
                    ? theme.headerBackground
                    : index.isEven
                    ? theme.alternatingRowBackground
                    : Theme.of(context).colorScheme.surface,
              ),
              foregroundDecoration: _borderDecoration(theme, showGridLines),
            );
          },
          cellBuilder: (context, vicinity) {
            final column = columns[vicinity.column];
            if (showHeaders && vicinity.row == 0) {
              return table.TableViewCell(
                child: _CellText(
                  text: column.caption ?? column.id,
                  alignment: column.alignment,
                  isHeader: true,
                ),
              );
            }
            final row = rows[vicinity.row - rowOffset];
            final selected =
                selectedCell?.rowId == row.id &&
                selectedCell?.columnId == column.id;
            return table.TableViewCell(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onCellSelected?.call(row.id, column.id),
                child: ColoredBox(
                  color: selected
                      ? theme.selectionBackground
                      : Colors.transparent,
                  child: _CellText(
                    text: row.cells[column.id]?.toString() ?? '',
                    alignment: column.alignment,
                  ),
                ),
              ),
            );
          },
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
  });

  final String text;
  final FxCellAlignment alignment;
  final bool isHeader;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textAlign = switch (alignment) {
      FxCellAlignment.leading => TextAlign.start,
      FxCellAlignment.center => TextAlign.center,
      FxCellAlignment.trailing => TextAlign.end,
    };
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
            color: enabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
