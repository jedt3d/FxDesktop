import 'dart:async';

/// A container representing an option within a lookup selection list.
class FxLookupItem<K> {
  /// The raw database / foreign-key value.
  final K key;

  /// The human-readable string displayed in the UI.
  final String display;

  /// Creates a lookup item.
  const FxLookupItem(this.key, this.display);
}

/// A contract for resolving raw keys (IDs) to display values and retrieving selection options.
abstract class FxLookupProvider<K> {
  /// Creates a lookup provider.
  const FxLookupProvider();

  /// Maps a raw database Key/ID back to a human-readable display string.
  String getDisplayValue(K key);

  /// Fetches options for selection, supporting search query filtering.
  FutureOr<List<FxLookupItem<K>>> getOptions(String query);

  /// Converts this lookup provider configuration to JSON.
  Map<String, Object?> toJson();
}

/// A standard static map-based lookup provider.
class FxMapLookupProvider<K> extends FxLookupProvider<K> {
  /// The static key-to-display value mapping.
  final Map<K, String> map;

  /// Creates a map lookup provider.
  const FxMapLookupProvider(this.map);

  @override
  String getDisplayValue(K key) => map[key] ?? key.toString();

  @override
  FutureOr<List<FxLookupItem<K>>> getOptions(String query) {
    final results = <FxLookupItem<K>>[];
    final lowercaseQuery = query.toLowerCase();
    for (final entry in map.entries) {
      if (query.isEmpty || entry.value.toLowerCase().contains(lowercaseQuery)) {
        results.add(FxLookupItem(entry.key, entry.value));
      }
    }
    return results;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'map',
      'map': map.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

/// A standard enum-based lookup provider.
class FxEnumLookupProvider<T extends Enum> extends FxLookupProvider<T> {
  /// The list of enum values (usually `MyEnum.values`).
  final List<T> values;

  /// Custom mapping from enum to display string. If null, falls back to `enum.name`.
  final Map<T, String>? labels;

  /// Creates an enum lookup provider.
  const FxEnumLookupProvider({required this.values, this.labels});

  @override
  String getDisplayValue(T key) {
    return labels?[key] ?? key.name;
  }

  @override
  FutureOr<List<FxLookupItem<T>>> getOptions(String query) {
    final results = <FxLookupItem<T>>[];
    final lowercaseQuery = query.toLowerCase();
    for (final val in values) {
      final label = getDisplayValue(val);
      if (query.isEmpty || label.toLowerCase().contains(lowercaseQuery)) {
        results.add(FxLookupItem(val, label));
      }
    }
    return results;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'enum',
      'values': values.map((e) => e.name).toList(),
      'labels': labels?.map((key, value) => MapEntry(key.name, value)),
    };
  }
}
