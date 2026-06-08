import 'dart:async';

/// A container representing an option within a lookup selection list.
class FxLookupItem<K> {
  /// The raw database / foreign-key value.
  final K key;

  /// The human-readable string displayed in the UI.
  final String display;

  /// Additional column values for multi-column dropdowns.
  final List<String>? extraDetails;

  /// Creates a lookup item.
  const FxLookupItem(this.key, this.display, [this.extraDetails]);
}

/// A contract for resolving raw keys (IDs) to display values and retrieving selection options.
abstract class FxLookupProvider<K> {
  /// Creates a lookup provider.
  const FxLookupProvider();

  /// Maps a raw database Key/ID back to a human-readable display string.
  String getDisplayValue(K key);

  /// Fetches options for selection, supporting search query filtering.
  FutureOr<List<FxLookupItem<K>>> getOptions(String query);

  /// Returns the headers for a multi-column dropdown, if supported.
  List<String> getLookupHeaders() => const [];

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

/// A database-style multi-column lookup provider.
class FxDbLookupProvider<K> extends FxLookupProvider<K> {
  /// The headers of the lookup columns.
  final List<String> headers;

  /// The map of keys to a list of strings representing the row values.
  final Map<K, List<String>> recordMap;

  /// Index of the column within the list of values that contains the main display value.
  final int displayColumnIndex;

  /// Creates a database-style lookup provider.
  const FxDbLookupProvider({
    required this.headers,
    required this.recordMap,
    this.displayColumnIndex = 0,
  });

  @override
  String getDisplayValue(K key) {
    final record = recordMap[key];
    if (record == null || record.isEmpty) return key.toString();
    if (displayColumnIndex < record.length) {
      return record[displayColumnIndex];
    }
    return record.first;
  }

  @override
  FutureOr<List<FxLookupItem<K>>> getOptions(String query) {
    final results = <FxLookupItem<K>>[];
    final lowercaseQuery = query.toLowerCase();
    for (final entry in recordMap.entries) {
      final record = entry.value;
      final matches =
          query.isEmpty ||
          record.any((col) => col.toLowerCase().contains(lowercaseQuery));
      if (matches) {
        final display = displayColumnIndex < record.length
            ? record[displayColumnIndex]
            : (record.isNotEmpty ? record.first : '');
        results.add(FxLookupItem(entry.key, display, record));
      }
    }
    return results;
  }

  @override
  List<String> getLookupHeaders() => headers;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'db',
      'headers': headers,
      'recordMap': recordMap.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'displayColumnIndex': displayColumnIndex,
    };
  }
}
