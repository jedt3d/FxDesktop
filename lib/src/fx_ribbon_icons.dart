import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'fx_ribbon_models.dart';

/// Supported runtime icon source kinds.
enum FxRibbonIconKind {
  /// Runtime Material [IconData].
  materialIcon,

  /// SVG loaded from Flutter assets.
  svgAsset,

  /// Embedded SVG markup or SVG data URL.
  svgString,

  /// PNG loaded from Flutter assets.
  pngAsset,

  /// Embedded PNG bytes.
  pngBytes,

  /// Runtime image provider escape hatch.
  imageProvider,
}

/// Runtime icon source for ribbon rendering.
@immutable
class FxRibbonIconSource {
  const FxRibbonIconSource._({
    required this.kind,
    this.icon,
    this.assetName,
    this.package,
    this.svgString,
    this.pngBytes,
    this.imageProvider,
  });

  /// Creates a Material icon source.
  const FxRibbonIconSource.material(IconData icon)
    : this._(kind: FxRibbonIconKind.materialIcon, icon: icon);

  /// Creates an SVG asset source.
  const FxRibbonIconSource.svgAsset(String assetName, {String? package})
    : this._(
        kind: FxRibbonIconKind.svgAsset,
        assetName: assetName,
        package: package,
      );

  /// Creates an embedded SVG source.
  const FxRibbonIconSource.svgString(String svgString)
    : this._(kind: FxRibbonIconKind.svgString, svgString: svgString);

  /// Creates a PNG asset source.
  const FxRibbonIconSource.pngAsset(String assetName, {String? package})
    : this._(
        kind: FxRibbonIconKind.pngAsset,
        assetName: assetName,
        package: package,
      );

  /// Creates embedded PNG bytes.
  const FxRibbonIconSource.pngBytes(Uint8List pngBytes)
    : this._(kind: FxRibbonIconKind.pngBytes, pngBytes: pngBytes);

  /// Creates an image provider source.
  const FxRibbonIconSource.imageProvider(ImageProvider imageProvider)
    : this._(
        kind: FxRibbonIconKind.imageProvider,
        imageProvider: imageProvider,
      );

  /// Creates a runtime icon source from an embedded bundle asset.
  factory FxRibbonIconSource.fromEmbedded(FxRibbonEmbeddedIcon icon) {
    return switch (icon.kind) {
      FxRibbonEmbeddedIconKind.svg => FxRibbonIconSource.svgString(
        _decodeSvgData(icon.data),
      ),
      FxRibbonEmbeddedIconKind.png => FxRibbonIconSource.pngBytes(
        _decodePngData(icon.data),
      ),
    };
  }

  /// Source kind.
  final FxRibbonIconKind kind;

  /// Material icon data.
  final IconData? icon;

  /// Asset name for asset-backed sources.
  final String? assetName;

  /// Optional package name for asset-backed sources.
  final String? package;

  /// SVG markup.
  final String? svgString;

  /// PNG bytes.
  final Uint8List? pngBytes;

  /// Image provider.
  final ImageProvider? imageProvider;
}

/// Immutable icon registry keyed by ribbon `iconKey`.
@immutable
class FxRibbonIconRegistry {
  const FxRibbonIconRegistry._(this._entries);

  /// Empty icon registry.
  const FxRibbonIconRegistry.empty() : _entries = const {};

  /// Creates a registry from icon entries.
  factory FxRibbonIconRegistry({
    required Map<String, FxRibbonIconSource> entries,
  }) {
    return FxRibbonIconRegistry._(
      Map<String, FxRibbonIconSource>.unmodifiable(entries),
    );
  }

  /// Creates a registry from a definition's embedded icon bundle.
  factory FxRibbonIconRegistry.fromEmbedded(
    Map<String, FxRibbonEmbeddedIcon> icons,
  ) {
    return FxRibbonIconRegistry(
      entries: {
        for (final entry in icons.entries)
          entry.key: FxRibbonIconSource.fromEmbedded(entry.value),
      },
    );
  }

  final Map<String, FxRibbonIconSource> _entries;

  /// Looks up an icon source.
  FxRibbonIconSource? operator [](String? key) {
    if (key == null) {
      return null;
    }
    return _entries[key];
  }

  /// Whether the registry has [key].
  bool containsKey(String key) => _entries.containsKey(key);

  /// Registered icon keys.
  Iterable<String> get keys => _entries.keys;

  /// Number of entries.
  int get length => _entries.length;

  /// Returns a merged registry where [other] wins key conflicts.
  FxRibbonIconRegistry merge(FxRibbonIconRegistry other) {
    return FxRibbonIconRegistry(entries: {..._entries, ...other._entries});
  }

  /// Stable map for diagnostics.
  Map<String, Object?> toTemplateMap() {
    return {'keys': keys.toList()..sort(), 'length': length};
  }
}

/// Renders a ribbon icon source.
class FxRibbonIconView extends StatelessWidget {
  /// Creates a ribbon icon renderer.
  const FxRibbonIconView({
    super.key,
    required this.source,
    required this.size,
    required this.label,
    this.enabled = true,
    this.placeholderColor,
  });

  /// Runtime source, or `null` for a deterministic placeholder.
  final FxRibbonIconSource? source;

  /// Icon box size.
  final double size;

  /// Label used to derive placeholder letter and semantics.
  final String label;

  /// Whether enabled colors are used.
  final bool enabled;

  /// Optional placeholder color.
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final iconSource = source;
    final opacity = enabled ? 1.0 : 0.45;
    final Widget child = switch (iconSource?.kind) {
      FxRibbonIconKind.materialIcon => Icon(
        iconSource!.icon,
        size: size,
        color: foreground,
      ),
      FxRibbonIconKind.svgAsset => SvgPicture.asset(
        iconSource!.assetName!,
        package: iconSource.package,
        width: size,
        height: size,
      ),
      FxRibbonIconKind.svgString => SvgPicture.string(
        iconSource!.svgString!,
        width: size,
        height: size,
      ),
      FxRibbonIconKind.pngAsset => Image.asset(
        iconSource!.assetName!,
        package: iconSource.package,
        width: size,
        height: size,
        fit: BoxFit.contain,
        opacity: AlwaysStoppedAnimation(opacity),
      ),
      FxRibbonIconKind.pngBytes => Image.memory(
        iconSource!.pngBytes!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        opacity: AlwaysStoppedAnimation(opacity),
      ),
      FxRibbonIconKind.imageProvider => Image(
        image: iconSource!.imageProvider!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        opacity: AlwaysStoppedAnimation(opacity),
      ),
      null => _RibbonIconPlaceholder(
        label: label,
        size: size,
        enabled: enabled,
        color: placeholderColor,
      ),
    };

    return Opacity(
      opacity: opacity,
      child: SizedBox.square(
        dimension: size,
        child: Center(child: child),
      ),
    );
  }
}

class _RibbonIconPlaceholder extends StatelessWidget {
  const _RibbonIconPlaceholder({
    required this.label,
    required this.size,
    required this.enabled,
    this.color,
  });

  final String label;
  final double size;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = enabled
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final background = color ?? colorScheme.secondaryContainer;
    final text = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled ? background : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size * 0.48,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

String _decodeSvgData(String data) {
  if (data.trimLeft().startsWith('<svg')) {
    return data;
  }
  if (data.startsWith('data:')) {
    return UriData.parse(data).contentAsString();
  }
  return data;
}

Uint8List _decodePngData(String data) {
  if (data.startsWith('data:')) {
    return UriData.parse(data).contentAsBytes();
  }
  return base64Decode(data);
}
