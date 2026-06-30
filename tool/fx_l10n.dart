import 'dart:convert';
import 'dart:io';

const _templateLocale = 'en';
const _supportedLocales = ['en', 'th', 'ja', 'ne'];
const _arbDir = 'lib/l10n';
const _templateArbPath = '$_arbDir/fx_desktop_en.arb';

void main(List<String> args) {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    _printUsage();
    return;
  }

  final command = args.first;
  final options = _parseOptions(args.skip(1).toList());
  switch (command) {
    case 'audit':
      _audit();
    case 'export-pot':
      _exportPot(
        output: options['output'] ?? 'doc/localization/fx_desktop.pot',
      );
    case 'export-po':
      final locale = options['locale'];
      if (locale == null) {
        _usageError('export-po requires --locale.');
      }
      _exportPo(
        locale: locale!,
        output:
            options['output'] ??
            'doc/localization/po-import-example-$locale.po',
      );
    case 'import-po':
      final locale = options['locale'];
      final input = options['input'];
      if (locale == null || input == null) {
        _usageError('import-po requires --input and --locale.');
      }
      _importPo(
        input: input!,
        locale: locale!,
        output: options['output'] ?? '$_arbDir/fx_desktop_$locale.arb',
      );
    default:
      _usageError('Unknown command: $command');
  }
}

void _printUsage() {
  stdout.writeln('''
FxDesktop localization tooling.

Commands:
  dart run tool/fx_l10n.dart audit
  dart run tool/fx_l10n.dart export-pot --output doc/localization/fx_desktop.pot
  dart run tool/fx_l10n.dart export-po --locale th --output doc/localization/po-import-example-th.po
  dart run tool/fx_l10n.dart import-po --input doc/localization/po-import-example-th.po --locale th --output lib/l10n/fx_desktop_th.arb
''');
}

void _usageError(String message) {
  stderr.writeln(message);
  _printUsage();
  exit(64);
}

Map<String, String> _parseOptions(List<String> args) {
  final options = <String, String>{};
  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    if (!arg.startsWith('--')) {
      _usageError('Unexpected positional argument: $arg');
    }
    final eqIndex = arg.indexOf('=');
    if (eqIndex != -1) {
      options[arg.substring(2, eqIndex)] = arg.substring(eqIndex + 1);
      continue;
    }
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      _usageError('Missing value for $arg');
    }
    options[arg.substring(2)] = args[index + 1];
    index += 1;
  }
  return options;
}

void _audit() {
  final failures = <String>[];
  final warnings = <String>[];
  final template = _readArb(File(_templateArbPath));
  final templateKeys = _messageKeys(template).toSet();
  final contexts = <String, String>{};

  for (final key in templateKeys) {
    final context = _contextFor(template, key);
    if (context == null || context.isEmpty) {
      failures.add('Missing PO context metadata for $key.');
      continue;
    }
    final previous = contexts[context];
    if (previous != null) {
      failures.add('Duplicate PO context "$context" for $previous and $key.');
    }
    contexts[context] = key;
  }

  for (final locale in _supportedLocales) {
    final file = File('$_arbDir/fx_desktop_$locale.arb');
    if (!file.existsSync()) {
      failures.add('Missing ARB file: ${file.path}.');
      continue;
    }
    final arb = _readArb(file);
    final keys = _messageKeys(arb).toSet();
    for (final key in templateKeys.difference(keys)) {
      failures.add('${file.path} is missing $key.');
    }
    for (final key in keys.difference(templateKeys)) {
      failures.add('${file.path} has unknown key $key.');
    }
    for (final key in templateKeys.intersection(keys)) {
      final expected = _placeholders(template[key] as String);
      final actual = _placeholders(arb[key] as String);
      if (!_sameSet(expected, actual)) {
        failures.add(
          '${file.path} placeholder mismatch for $key: '
          'expected ${expected.join(', ')}, found ${actual.join(', ')}.',
        );
      }
    }
  }

  for (final locale in ['th', 'ja', 'ne']) {
    final fixture = File('doc/localization/po-import-example-$locale.po');
    if (!fixture.existsSync()) {
      warnings.add('PO fixture not found yet: ${fixture.path}.');
      continue;
    }
    _auditPoFixture(
      fixture: fixture,
      template: template,
      contextToKey: contexts,
      warnings: warnings,
      failures: failures,
    );
  }

  for (final warning in warnings) {
    stderr.writeln('warning: $warning');
  }
  if (failures.isNotEmpty) {
    stderr.writeln('FxDesktop localization audit failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exit(1);
  }

  stdout.writeln(
    'FxDesktop localization audit passed: '
    '${templateKeys.length} keys, ${_supportedLocales.length} locales.',
  );
}

void _exportPot({required String output}) {
  final template = _readArb(File(_templateArbPath));
  final entries = _messageKeys(template)
      .map(
        (key) => _PoExportEntry(
          key: key,
          context: _contextFor(template, key) ?? key,
          description: _descriptionFor(template, key),
          msgid: template[key] as String,
          msgstr: '',
        ),
      )
      .toList();
  _writePo(File(output), language: '', entries: entries);
}

void _exportPo({required String locale, required String output}) {
  if (!_supportedLocales.contains(locale)) {
    _usageError('Unsupported locale "$locale". Supported: $_supportedLocales');
  }
  final template = _readArb(File(_templateArbPath));
  final localized = _readArb(File('$_arbDir/fx_desktop_$locale.arb'));
  final entries = _messageKeys(template)
      .map(
        (key) => _PoExportEntry(
          key: key,
          context: _contextFor(template, key) ?? key,
          description: _descriptionFor(template, key),
          msgid: template[key] as String,
          msgstr: localized[key] as String? ?? '',
        ),
      )
      .toList();
  _writePo(File(output), language: locale, entries: entries);
}

void _importPo({
  required String input,
  required String locale,
  required String output,
}) {
  if (!_supportedLocales.contains(locale) || locale == _templateLocale) {
    _usageError(
      'import-po supports target locales ${_supportedLocales.where((l) => l != _templateLocale).join(', ')}.',
    );
  }

  final template = _readArb(File(_templateArbPath));
  final targetFile = File(output);
  final target = targetFile.existsSync()
      ? _readArb(targetFile)
      : <String, Object?>{'@@locale': locale};
  final contextToKey = {
    for (final key in _messageKeys(template))
      if (_contextFor(template, key) != null) _contextFor(template, key)!: key,
  };

  var updated = 0;
  for (final entry in _parsePo(File(input).readAsStringSync())) {
    final context = entry.msgctxt;
    if (context == null || context.isEmpty) {
      stderr.writeln('warning: skipping PO entry without msgctxt.');
      continue;
    }
    final key = contextToKey[context];
    if (key == null) {
      stderr.writeln(
        'warning: unknown PO context "$context"; leaving ARB unchanged.',
      );
      continue;
    }
    if (entry.msgstr.isEmpty) {
      stderr.writeln(
        'warning: untranslated PO entry "$context"; leaving $key unchanged.',
      );
      continue;
    }
    final expected = _placeholders(template[key] as String);
    final actual = _placeholders(entry.msgstr);
    if (!_sameSet(expected, actual)) {
      stderr.writeln(
        'warning: placeholder mismatch for "$context"; expected '
        '${expected.join(', ')}, found ${actual.join(', ')}. Leaving $key unchanged.',
      );
      continue;
    }
    target[key] = entry.msgstr;
    updated += 1;
  }

  target['@@locale'] = locale;
  targetFile.parent.createSync(recursive: true);
  targetFile.writeAsStringSync(
    '${_prettyJson(_orderedArb(target, template))}\n',
  );
  stdout.writeln('Imported $updated PO entries into ${targetFile.path}.');
}

void _auditPoFixture({
  required File fixture,
  required Map<String, Object?> template,
  required Map<String, String> contextToKey,
  required List<String> warnings,
  required List<String> failures,
}) {
  for (final entry in _parsePo(fixture.readAsStringSync())) {
    final context = entry.msgctxt;
    if (context == null || context.isEmpty) {
      warnings.add('${fixture.path} has an entry without msgctxt.');
      continue;
    }
    final key = contextToKey[context];
    if (key == null) {
      failures.add('${fixture.path} has unknown context "$context".');
      continue;
    }
    if (entry.msgstr.isEmpty) {
      warnings.add('${fixture.path} leaves "$context" untranslated.');
    }
    final expected = _placeholders(template[key] as String);
    final actual = _placeholders(entry.msgstr);
    if (entry.msgstr.isNotEmpty && !_sameSet(expected, actual)) {
      failures.add(
        '${fixture.path} placeholder mismatch for "$context": '
        'expected ${expected.join(', ')}, found ${actual.join(', ')}.',
      );
    }
  }
}

Map<String, Object?> _readArb(File file) {
  if (!file.existsSync()) {
    stderr.writeln('Missing ARB file: ${file.path}');
    exit(66);
  }
  return (jsonDecode(file.readAsStringSync()) as Map).cast<String, Object?>();
}

Iterable<String> _messageKeys(Map<String, Object?> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toList()..sort();
}

String? _contextFor(Map<String, Object?> arb, String key) {
  final metadata = arb['@$key'];
  if (metadata is! Map) return null;
  return metadata['context'] as String?;
}

String _descriptionFor(Map<String, Object?> arb, String key) {
  final metadata = arb['@$key'];
  if (metadata is! Map) return '';
  return metadata['description'] as String? ?? '';
}

Set<String> _placeholders(String message) {
  return RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)\}',
  ).allMatches(message).map((match) => match.group(1)!).toSet();
}

bool _sameSet(Set<String> a, Set<String> b) {
  return a.length == b.length && a.containsAll(b);
}

Map<String, Object?> _orderedArb(
  Map<String, Object?> target,
  Map<String, Object?> template,
) {
  final ordered = <String, Object?>{'@@locale': target['@@locale']};
  for (final key in _messageKeys(template)) {
    if (target.containsKey(key)) {
      ordered[key] = target[key];
    }
  }
  for (final key in target.keys.where((key) => !ordered.containsKey(key))) {
    ordered[key] = target[key];
  }
  return ordered;
}

String _prettyJson(Map<String, Object?> json) {
  return const JsonEncoder.withIndent('  ').convert(json);
}

void _writePo(
  File file, {
  required String language,
  required List<_PoExportEntry> entries,
}) {
  file.parent.createSync(recursive: true);
  final buffer = StringBuffer()
    ..writeln('msgid ""')
    ..writeln('msgstr ""')
    ..writeln('"Project-Id-Version: fx_desktop\\n"');
  if (language.isNotEmpty) {
    buffer.writeln('"Language: $language\\n"');
  }
  buffer
    ..writeln('"Content-Type: text/plain; charset=UTF-8\\n"')
    ..writeln();

  for (final entry in entries) {
    buffer
      ..writeln('#. ARB key: ${entry.key}')
      ..writeln('#. Description: ${entry.description}')
      ..writeln('msgctxt ${_quotePo(entry.context)}')
      ..writeln('msgid ${_quotePo(entry.msgid)}')
      ..writeln('msgstr ${_quotePo(entry.msgstr)}')
      ..writeln();
  }

  file.writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${entries.length} entries to ${file.path}.');
}

String _quotePo(String value) {
  return '"${_escapePo(value)}"';
}

String _escapePo(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n');
}

String _unescapePo(String value) {
  final buffer = StringBuffer();
  for (var index = 0; index < value.length; index += 1) {
    final char = value[index];
    if (char != r'\') {
      buffer.write(char);
      continue;
    }
    if (index + 1 >= value.length) {
      buffer.write(char);
      continue;
    }
    final escaped = value[++index];
    switch (escaped) {
      case 'n':
        buffer.write('\n');
      case 't':
        buffer.write('\t');
      case '"':
        buffer.write('"');
      case r'\':
        buffer.write(r'\');
      default:
        buffer.write(escaped);
    }
  }
  return buffer.toString();
}

List<_PoEntry> _parsePo(String source) {
  final entries = <_PoEntry>[];
  String? currentField;
  var current = _MutablePoEntry();

  void flush() {
    if (current.hasMessage) {
      entries.add(current.toEntry());
    }
    current = _MutablePoEntry();
    currentField = null;
  }

  for (final rawLine in const LineSplitter().convert(source)) {
    final line = rawLine.trimRight();
    if (line.isEmpty) {
      flush();
      continue;
    }
    if (line.startsWith('#')) {
      continue;
    }
    if (line.startsWith('msgctxt ')) {
      currentField = 'msgctxt';
      current.msgctxt = _parsePoString(line.substring('msgctxt '.length));
      continue;
    }
    if (line.startsWith('msgid ')) {
      currentField = 'msgid';
      current.msgid = _parsePoString(line.substring('msgid '.length));
      continue;
    }
    if (line.startsWith('msgstr ')) {
      currentField = 'msgstr';
      current.msgstr = _parsePoString(line.substring('msgstr '.length));
      continue;
    }
    if (line.startsWith('"') && currentField != null) {
      final value = _parsePoString(line);
      switch (currentField) {
        case 'msgctxt':
          current.msgctxt = (current.msgctxt ?? '') + value;
        case 'msgid':
          current.msgid = (current.msgid ?? '') + value;
        case 'msgstr':
          current.msgstr = (current.msgstr ?? '') + value;
      }
      continue;
    }
  }
  flush();

  return entries
      .where((entry) => !(entry.msgctxt == null && entry.msgid.isEmpty))
      .toList();
}

String _parsePoString(String token) {
  final trimmed = token.trim();
  if (!trimmed.startsWith('"') || !trimmed.endsWith('"')) {
    _usageError('Invalid PO string: $token');
  }
  return _unescapePo(trimmed.substring(1, trimmed.length - 1));
}

class _PoExportEntry {
  const _PoExportEntry({
    required this.key,
    required this.context,
    required this.description,
    required this.msgid,
    required this.msgstr,
  });

  final String key;
  final String context;
  final String description;
  final String msgid;
  final String msgstr;
}

class _PoEntry {
  const _PoEntry({this.msgctxt, required this.msgid, required this.msgstr});

  final String? msgctxt;
  final String msgid;
  final String msgstr;
}

class _MutablePoEntry {
  String? msgctxt;
  String? msgid;
  String? msgstr;

  bool get hasMessage => msgid != null || msgstr != null || msgctxt != null;

  _PoEntry toEntry() {
    return _PoEntry(msgctxt: msgctxt, msgid: msgid ?? '', msgstr: msgstr ?? '');
  }
}
