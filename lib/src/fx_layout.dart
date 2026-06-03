import 'package:flexiblebox/flexiblebox_flutter.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart' as lg;

/// Generation target for Xojo template maps.
enum FxXojoTarget {
  /// Xojo Desktop target.
  desktop,

  /// Xojo Web target.
  web,
}

/// Serializable layout type.
enum FxLayoutKind {
  /// CSS Flexbox-like layout.
  flex,

  /// CSS Grid-like layout.
  grid,
}

/// Flex direction shared by Flutter Desktop and Web/WASM.
enum FxFlexDirection {
  /// Horizontal left-to-right flow.
  row,

  /// Horizontal reverse flow.
  rowReverse,

  /// Vertical top-to-bottom flow.
  column,

  /// Vertical reverse flow.
  columnReverse,
}

/// Flex wrapping behavior.
enum FxFlexWrap {
  /// No wrapping.
  none,

  /// Wrap to additional lines.
  wrap,

  /// Wrap in reverse line order.
  wrapReverse,
}

/// Main-axis distribution for flex layouts.
enum FxJustifyContent {
  /// Pack items at the start.
  start,

  /// Pack items at the end.
  end,

  /// Center items.
  center,

  /// Distribute space between items.
  spaceBetween,

  /// Distribute space around items.
  spaceAround,

  /// Distribute space evenly.
  spaceEvenly,
}

/// Cross-axis alignment for flex layouts.
enum FxAlignItems {
  /// Align items to the start.
  start,

  /// Align items to the end.
  end,

  /// Center items.
  center,

  /// Stretch items to fill the cross axis.
  stretch,
}

/// Overflow strategy for layout widgets.
enum FxLayoutOverflow {
  /// Clip overflow without scrolling.
  hidden,

  /// Allow visible overflow.
  visible,

  /// Clip and allow scrolling.
  scroll,

  /// Clip overflow.
  clip,
}

/// A CSS Grid-like track size used by [FxGridLayout].
class FxTrackSize {
  /// Creates a fixed pixel track.
  const FxTrackSize.fixed(this.value) : type = FxTrackSizeType.fixed;

  /// Creates a flexible fraction track.
  const FxTrackSize.flex(this.value) : type = FxTrackSizeType.flex;

  /// Creates an auto-sized track.
  const FxTrackSize.auto() : type = FxTrackSizeType.auto, value = null;

  /// Creates an intrinsic content-sized track.
  const FxTrackSize.intrinsic()
    : type = FxTrackSizeType.intrinsic,
      value = null;

  /// Track size type.
  final FxTrackSizeType type;

  /// Pixel or fraction value, depending on [type].
  final double? value;

  /// Restores a track size from JSON.
  factory FxTrackSize.fromJson(Map<String, Object?> json) {
    final type = FxTrackSizeType.values.byName(json['type'] as String);
    final value = (json['value'] as num?)?.toDouble();
    return switch (type) {
      FxTrackSizeType.fixed => FxTrackSize.fixed(value ?? 0),
      FxTrackSizeType.flex => FxTrackSize.flex(value ?? 1),
      FxTrackSizeType.auto => const FxTrackSize.auto(),
      FxTrackSizeType.intrinsic => const FxTrackSize.intrinsic(),
    };
  }

  /// Converts this track to JSON.
  Map<String, Object?> toJson() => {'type': type.name, 'value': value};
}

/// Grid track type.
enum FxTrackSizeType {
  /// Fixed pixel track.
  fixed,

  /// Flexible fraction track.
  flex,

  /// Auto-sized track.
  auto,

  /// Intrinsic content-sized track.
  intrinsic,
}

/// Serializable child metadata for flex layouts.
class FxFlexItemSpec {
  /// Creates a flex item spec.
  const FxFlexItemSpec({
    required this.id,
    this.grow = 0,
    this.shrink = 0,
    this.basis,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignSelf,
  });

  /// Stable child id.
  final String id;

  /// Flex grow factor.
  final double grow;

  /// Flex shrink factor.
  final double shrink;

  /// Preferred main-axis basis in logical pixels.
  final double? basis;

  /// Minimum width.
  final double? minWidth;

  /// Maximum width.
  final double? maxWidth;

  /// Minimum height.
  final double? minHeight;

  /// Maximum height.
  final double? maxHeight;

  /// Optional item-level cross-axis alignment.
  final FxAlignItems? alignSelf;

  /// Restores a flex item spec from JSON.
  factory FxFlexItemSpec.fromJson(Map<String, Object?> json) {
    return FxFlexItemSpec(
      id: json['id'] as String,
      grow: (json['grow'] as num?)?.toDouble() ?? 0,
      shrink: (json['shrink'] as num?)?.toDouble() ?? 0,
      basis: (json['basis'] as num?)?.toDouble(),
      minWidth: (json['minWidth'] as num?)?.toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble(),
      minHeight: (json['minHeight'] as num?)?.toDouble(),
      maxHeight: (json['maxHeight'] as num?)?.toDouble(),
      alignSelf: json['alignSelf'] == null
          ? null
          : FxAlignItems.values.byName(json['alignSelf'] as String),
    );
  }

  /// Converts this spec to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'grow': grow,
      'shrink': shrink,
      'basis': basis,
      'minWidth': minWidth,
      'maxWidth': maxWidth,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'alignSelf': alignSelf?.name,
    };
  }
}

/// Serializable placement metadata for grid layouts.
class FxGridPlacementSpec {
  /// Creates a grid placement spec.
  const FxGridPlacementSpec({
    required this.id,
    this.area,
    this.rowStart,
    this.columnStart,
    this.rowSpan = 1,
    this.columnSpan = 1,
  });

  /// Stable child id.
  final String id;

  /// Named grid area.
  final String? area;

  /// Zero-based row start.
  final int? rowStart;

  /// Zero-based column start.
  final int? columnStart;

  /// Number of rows to span.
  final int rowSpan;

  /// Number of columns to span.
  final int columnSpan;

  /// Restores a placement spec from JSON.
  factory FxGridPlacementSpec.fromJson(Map<String, Object?> json) {
    return FxGridPlacementSpec(
      id: json['id'] as String,
      area: json['area'] as String?,
      rowStart: json['rowStart'] as int?,
      columnStart: json['columnStart'] as int?,
      rowSpan: json['rowSpan'] as int? ?? 1,
      columnSpan: json['columnSpan'] as int? ?? 1,
    );
  }

  /// Converts this spec to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'area': area,
      'rowStart': rowStart,
      'columnStart': columnStart,
      'rowSpan': rowSpan,
      'columnSpan': columnSpan,
    };
  }
}

/// Serializable layout description for AI agents, JinjaX, and Xojo generation.
class FxLayoutSpec {
  /// Creates a flex layout spec.
  const FxLayoutSpec.flex({
    required this.id,
    this.direction = FxFlexDirection.row,
    this.wrap = FxFlexWrap.none,
    this.justify = FxJustifyContent.start,
    this.align = FxAlignItems.start,
    this.gap = 0,
    this.padding = 0,
    this.flexChildren = const [],
  }) : kind = FxLayoutKind.flex,
       columns = const [],
       rows = const [],
       areas = null,
       gridChildren = const [];

  /// Creates a grid layout spec.
  const FxLayoutSpec.grid({
    required this.id,
    this.columns = const [],
    this.rows = const [],
    this.areas,
    this.gap = 0,
    this.gridChildren = const [],
  }) : kind = FxLayoutKind.grid,
       direction = FxFlexDirection.row,
       wrap = FxFlexWrap.none,
       justify = FxJustifyContent.start,
       align = FxAlignItems.start,
       padding = 0,
       flexChildren = const [];

  /// Stable layout id.
  final String id;

  /// Layout kind.
  final FxLayoutKind kind;

  /// Flex direction.
  final FxFlexDirection direction;

  /// Flex wrapping.
  final FxFlexWrap wrap;

  /// Flex main-axis distribution.
  final FxJustifyContent justify;

  /// Flex cross-axis alignment.
  final FxAlignItems align;

  /// Shared row/column gap in logical pixels.
  final double gap;

  /// Shared padding in logical pixels.
  final double padding;

  /// Flex child metadata.
  final List<FxFlexItemSpec> flexChildren;

  /// Grid columns.
  final List<FxTrackSize> columns;

  /// Grid rows.
  final List<FxTrackSize> rows;

  /// CSS Grid-style template areas string.
  final String? areas;

  /// Grid child placement metadata.
  final List<FxGridPlacementSpec> gridChildren;

  /// Restores a layout spec from JSON.
  factory FxLayoutSpec.fromJson(Map<String, Object?> json) {
    final kind = FxLayoutKind.values.byName(json['kind'] as String);
    if (kind == FxLayoutKind.flex) {
      return FxLayoutSpec.flex(
        id: json['id'] as String,
        direction: FxFlexDirection.values.byName(
          json['direction'] as String? ?? FxFlexDirection.row.name,
        ),
        wrap: FxFlexWrap.values.byName(
          json['wrap'] as String? ?? FxFlexWrap.none.name,
        ),
        justify: FxJustifyContent.values.byName(
          json['justify'] as String? ?? FxJustifyContent.start.name,
        ),
        align: FxAlignItems.values.byName(
          json['align'] as String? ?? FxAlignItems.start.name,
        ),
        gap: (json['gap'] as num?)?.toDouble() ?? 0,
        padding: (json['padding'] as num?)?.toDouble() ?? 0,
        flexChildren: [
          for (final child in json['flexChildren'] as List<Object?>? ?? [])
            FxFlexItemSpec.fromJson(child! as Map<String, Object?>),
        ],
      );
    }
    return FxLayoutSpec.grid(
      id: json['id'] as String,
      columns: [
        for (final track in json['columns'] as List<Object?>? ?? [])
          FxTrackSize.fromJson(track! as Map<String, Object?>),
      ],
      rows: [
        for (final track in json['rows'] as List<Object?>? ?? [])
          FxTrackSize.fromJson(track! as Map<String, Object?>),
      ],
      areas: json['areas'] as String?,
      gap: (json['gap'] as num?)?.toDouble() ?? 0,
      gridChildren: [
        for (final child in json['gridChildren'] as List<Object?>? ?? [])
          FxGridPlacementSpec.fromJson(child! as Map<String, Object?>),
      ],
    );
  }

  /// Converts this layout spec to JSON.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'direction': direction.name,
      'wrap': wrap.name,
      'justify': justify.name,
      'align': align.name,
      'gap': gap,
      'padding': padding,
      'flexChildren': [for (final child in flexChildren) child.toJson()],
      'columns': [for (final column in columns) column.toJson()],
      'rows': [for (final row in rows) row.toJson()],
      'areas': areas,
      'gridChildren': [for (final child in gridChildren) child.toJson()],
    };
  }

  /// Stable context map for JinjaX templates and Xojo generator adapters.
  Map<String, Object?> toTemplateMap({
    FxXojoTarget target = FxXojoTarget.desktop,
  }) {
    return {
      ...toJson(),
      'target': target.name,
      'xojo_manager_class': switch ((kind, target)) {
        (FxLayoutKind.flex, FxXojoTarget.desktop) => 'DesktopFlexLayoutManager',
        (FxLayoutKind.flex, FxXojoTarget.web) => 'WebFlexLayoutManager',
        (FxLayoutKind.grid, _) => 'FxGridLayoutManager',
      },
      'xojo_setup_event': target == FxXojoTarget.desktop ? 'Opening' : 'Shown',
      'uses_apply_layout': true,
    };
  }
}

/// Non-visual manager/adapter for flex layout specs.
class FxFlexLayoutManager {
  /// Creates a flex layout manager.
  const FxFlexLayoutManager({required this.spec});

  /// Managed spec.
  final FxLayoutSpec spec;

  /// Converts the spec to a JinjaX/Xojo template map.
  Map<String, Object?> toTemplateMap({
    FxXojoTarget target = FxXojoTarget.desktop,
  }) {
    if (spec.kind != FxLayoutKind.flex) {
      throw ArgumentError.value(spec.kind, 'spec.kind', 'Expected flex spec.');
    }
    return spec.toTemplateMap(target: target);
  }
}

/// Non-visual manager/adapter for grid layout specs.
class FxGridLayoutManager {
  /// Creates a grid layout manager.
  const FxGridLayoutManager({required this.spec});

  /// Managed spec.
  final FxLayoutSpec spec;

  /// Converts the spec to a JinjaX/Xojo template map.
  Map<String, Object?> toTemplateMap({
    FxXojoTarget target = FxXojoTarget.desktop,
  }) {
    if (spec.kind != FxLayoutKind.grid) {
      throw ArgumentError.value(spec.kind, 'spec.kind', 'Expected grid spec.');
    }
    return spec.toTemplateMap(target: target);
  }
}

/// Child metadata wrapper for [FxFlexLayout].
class FxFlexItem extends StatelessWidget {
  /// Creates a flex item wrapper.
  const FxFlexItem({
    super.key,
    required this.child,
    this.grow = 0,
    this.shrink = 0,
    this.basis,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignSelf,
  });

  /// Child widget.
  final Widget child;

  /// Flex grow factor.
  final double grow;

  /// Flex shrink factor.
  final double shrink;

  /// Preferred main-axis basis. In widget mode this maps to width.
  final double? basis;

  /// Explicit width.
  final double? width;

  /// Explicit height.
  final double? height;

  /// Minimum width.
  final double? minWidth;

  /// Maximum width.
  final double? maxWidth;

  /// Minimum height.
  final double? minHeight;

  /// Maximum height.
  final double? maxHeight;

  /// Item-level cross-axis alignment.
  final FxAlignItems? alignSelf;

  @override
  Widget build(BuildContext context) {
    return fb.FlexItem(
      flexGrow: grow,
      flexShrink: shrink,
      width: _size(width ?? basis),
      height: _size(height),
      minWidth: _size(minWidth),
      maxWidth: _size(maxWidth),
      minHeight: _size(minHeight),
      maxHeight: _size(maxHeight),
      alignSelf: alignSelf == null ? null : _align(alignSelf!),
      child: child,
    );
  }
}

/// CSS Flexbox-like layout widget for desktop/Web-WASM UI.
class FxFlexLayout extends StatelessWidget {
  /// Creates a flex layout.
  const FxFlexLayout({
    super.key,
    this.direction = FxFlexDirection.row,
    this.wrap = FxFlexWrap.none,
    this.justify = FxJustifyContent.start,
    this.align = FxAlignItems.start,
    this.alignContent = FxJustifyContent.start,
    this.gap = 0,
    this.rowGap,
    this.columnGap,
    this.padding = EdgeInsets.zero,
    this.overflow = FxLayoutOverflow.hidden,
    this.children = const [],
  });

  /// Main-axis direction.
  final FxFlexDirection direction;

  /// Wrapping behavior.
  final FxFlexWrap wrap;

  /// Main-axis distribution.
  final FxJustifyContent justify;

  /// Cross-axis alignment.
  final FxAlignItems align;

  /// Wrapped-line distribution.
  final FxJustifyContent alignContent;

  /// Shared gap when row/column-specific gaps are not supplied.
  final double gap;

  /// Row gap.
  final double? rowGap;

  /// Column gap.
  final double? columnGap;

  /// Container padding.
  final EdgeInsetsGeometry padding;

  /// Overflow behavior.
  final FxLayoutOverflow overflow;

  /// Child widgets. Use [FxFlexItem] to set grow/shrink metadata.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding.resolve(Directionality.of(context));
    return fb.FlexBox(
      direction: _direction(direction),
      wrap: _wrap(wrap),
      justifyContent: _justify(justify),
      alignItems: _align(align),
      alignContent: _content(alignContent),
      rowGap: fb.SpacingUnit.fixed(rowGap ?? gap),
      columnGap: fb.SpacingUnit.fixed(columnGap ?? gap),
      padding: fb.EdgeSpacing.only(
        left: fb.SpacingUnit.fixed(resolvedPadding.left),
        top: fb.SpacingUnit.fixed(resolvedPadding.top),
        right: fb.SpacingUnit.fixed(resolvedPadding.right),
        bottom: fb.SpacingUnit.fixed(resolvedPadding.bottom),
      ),
      horizontalOverflow: _overflow(overflow),
      verticalOverflow: _overflow(overflow),
      children: children,
    );
  }
}

/// A reusable named CSS Grid-like area.
class FxGridArea {
  /// Creates a named grid area.
  const FxGridArea(this.name);

  /// Area name.
  final String name;

  /// Places [child] inside this named area.
  Widget containing(Widget child) {
    return lg.NamedAreaGridPlacement(areaName: name, child: child);
  }

  /// Converts this area to JSON.
  Map<String, Object?> toJson() => {'name': name};
}

/// Explicit placement wrapper for [FxGridLayout] children.
class FxGridPlacement extends StatelessWidget {
  /// Creates an explicit grid placement.
  const FxGridPlacement({
    super.key,
    required this.child,
    this.rowStart,
    this.columnStart,
    this.rowSpan = 1,
    this.columnSpan = 1,
  });

  /// Child widget.
  final Widget child;

  /// Zero-based row start.
  final int? rowStart;

  /// Zero-based column start.
  final int? columnStart;

  /// Row span.
  final int rowSpan;

  /// Column span.
  final int columnSpan;

  @override
  Widget build(BuildContext context) {
    return lg.GridPlacement(
      rowStart: rowStart,
      columnStart: columnStart,
      rowSpan: rowSpan,
      columnSpan: columnSpan,
      child: child,
    );
  }
}

/// CSS Grid-like layout widget for desktop/Web-WASM UI.
class FxGridLayout extends StatelessWidget {
  /// Creates a grid layout.
  const FxGridLayout({
    super.key,
    required this.columns,
    required this.rows,
    this.areas,
    this.rowGap = 0,
    this.columnGap = 0,
    this.children = const [],
  });

  /// Column track sizes.
  final List<FxTrackSize> columns;

  /// Row track sizes.
  final List<FxTrackSize> rows;

  /// CSS Grid-style template areas string.
  final String? areas;

  /// Row gap.
  final double rowGap;

  /// Column gap.
  final double columnGap;

  /// Grid children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return lg.LayoutGrid(
      areas: areas,
      columnSizes: [for (final column in columns) _track(column)],
      rowSizes: [for (final row in rows) _track(row)],
      rowGap: rowGap,
      columnGap: columnGap,
      children: children,
    );
  }
}

fb.FlexDirection _direction(FxFlexDirection value) {
  return switch (value) {
    FxFlexDirection.row => fb.FlexDirection.row,
    FxFlexDirection.rowReverse => fb.FlexDirection.rowReverse,
    FxFlexDirection.column => fb.FlexDirection.column,
    FxFlexDirection.columnReverse => fb.FlexDirection.columnReverse,
  };
}

fb.FlexWrap _wrap(FxFlexWrap value) {
  return switch (value) {
    FxFlexWrap.none => fb.FlexWrap.none,
    FxFlexWrap.wrap => fb.FlexWrap.wrap,
    FxFlexWrap.wrapReverse => fb.FlexWrap.wrapReverse,
  };
}

fb.BoxAlignmentBase _justify(FxJustifyContent value) {
  return switch (value) {
    FxJustifyContent.start => fb.BoxAlignmentBase.start,
    FxJustifyContent.end => fb.BoxAlignmentBase.end,
    FxJustifyContent.center => fb.BoxAlignmentBase.center,
    FxJustifyContent.spaceBetween => fb.BoxAlignmentBase.spaceBetween,
    FxJustifyContent.spaceAround => fb.BoxAlignmentBase.spaceAround,
    FxJustifyContent.spaceEvenly => fb.BoxAlignmentBase.spaceEvenly,
  };
}

fb.BoxAlignmentContent _content(FxJustifyContent value) {
  return switch (value) {
    FxJustifyContent.start => fb.BoxAlignmentContent.start,
    FxJustifyContent.end => fb.BoxAlignmentContent.end,
    FxJustifyContent.center => fb.BoxAlignmentContent.center,
    FxJustifyContent.spaceBetween => fb.BoxAlignmentContent.spaceBetween,
    FxJustifyContent.spaceAround => fb.BoxAlignmentContent.spaceAround,
    FxJustifyContent.spaceEvenly => fb.BoxAlignmentContent.spaceEvenly,
  };
}

fb.BoxAlignmentGeometry _align(FxAlignItems value) {
  return switch (value) {
    FxAlignItems.start => fb.BoxAlignmentGeometry.start,
    FxAlignItems.end => fb.BoxAlignmentGeometry.end,
    FxAlignItems.center => fb.BoxAlignmentGeometry.center,
    FxAlignItems.stretch => fb.BoxAlignmentGeometry.stretch,
  };
}

fb.LayoutOverflow _overflow(FxLayoutOverflow value) {
  return switch (value) {
    FxLayoutOverflow.hidden => fb.LayoutOverflow.hidden,
    FxLayoutOverflow.visible => fb.LayoutOverflow.visible,
    FxLayoutOverflow.scroll => fb.LayoutOverflow.scroll,
    FxLayoutOverflow.clip => fb.LayoutOverflow.clip,
  };
}

fb.SizeUnit? _size(double? value) {
  return value == null ? null : fb.SizeUnit.fixed(value);
}

lg.TrackSize _track(FxTrackSize track) {
  return switch (track.type) {
    FxTrackSizeType.fixed => lg.fixed(track.value ?? 0),
    FxTrackSizeType.flex => lg.flex(track.value ?? 1),
    FxTrackSizeType.auto => lg.auto,
    FxTrackSizeType.intrinsic => lg.intrinsic(),
  };
}
