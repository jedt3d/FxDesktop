import 'dart:io';

const _demoPackageDirs = [
  'fx-desktop-example',
  'example-listbox-demo',
  'ribbon-toolbar-designer',
];

const _webDemoPackageDirs = ['fx-desktop-example', 'ribbon-toolbar-designer'];

Future<void> main(List<String> args) async {
  final updateApi = args.contains('--update-api');

  if (updateApi) {
    stdout.writeln('Updating public API signature...');
    final signatures = _generateApiSignature();
    final signatureFile = File('doc/api/public_api_signature.txt');
    signatureFile.parent.createSync(recursive: true);
    signatureFile.writeAsStringSync('${signatures.join('\n')}\n');
    stdout.writeln(
      'Public API signature successfully updated and saved to ${signatureFile.path}',
    );
    return;
  }

  final failures = <String>[];

  await _run('dart', ['format', '--set-exit-if-changed', '.'], failures);
  for (final demoDir in _demoPackageDirs) {
    await _run('flutter', ['pub', 'get'], failures, workingDirectory: demoDir);
  }
  await _run('flutter', ['analyze'], failures);
  await _run('flutter', ['test', '--coverage'], failures);
  await _run('dart', ['run', 'tool/check_release_sync.dart'], failures);
  await _run('flutter', ['pub', 'run', 'dartdoc'], failures);
  await _run('flutter', ['pub', 'publish', '--dry-run'], failures);
  for (final demoDir in _demoPackageDirs) {
    await _run('flutter', ['analyze'], failures, workingDirectory: demoDir);
    await _run('flutter', ['test'], failures, workingDirectory: demoDir);
  }
  for (final demoDir in _webDemoPackageDirs) {
    await _run(
      'flutter',
      ['build', 'web', '--debug'],
      failures,
      workingDirectory: demoDir,
    );
  }

  _checkNoMachineLocalPaths(failures);
  _checkPublicApiDoesNotLeakDependencies(failures);
  _checkComponentRegistry(failures);
  _checkPublicApiSignature(failures);
  _checkTestCoverageThreshold(failures);

  if (failures.isNotEmpty) {
    stderr.writeln('\nFxDesktop agent harness failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('\nFxDesktop agent harness passed.');
}

Future<void> _run(
  String executable,
  List<String> arguments,
  List<String> failures, {
  String? workingDirectory,
}) async {
  final label = [
    if (workingDirectory != null) '(cd $workingDirectory &&',
    executable,
    ...arguments,
    if (workingDirectory != null) ')',
  ].join(' ');
  stdout.writeln('\n> $label');
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    failures.add(label);
  }
}

void _checkNoMachineLocalPaths(List<String> failures) {
  final forbiddenPatterns = [
    RegExp(
      '/'
      'Users'
      '/',
    ),
    RegExp(
      r'C:'
      r'\\'
      r'Users'
      r'\\',
    ),
    RegExp(
      '/'
      'Volumes'
      '/',
    ),
  ];
  for (final file in _trackedTextFiles()) {
    final text = file.readAsStringSync();
    if (forbiddenPatterns.any((pattern) => pattern.hasMatch(text))) {
      failures.add('machine-local path found in ${file.path}');
    }
  }
}

void _checkPublicApiDoesNotLeakDependencies(List<String> failures) {
  final publicFiles = [
    File('lib/fx_desktop.dart'),
    ...Directory(
      'lib/src',
    ).listSync().whereType<File>().where((file) => file.path.endsWith('.dart')),
  ];
  final leakPattern = RegExp(
    r'^\s*(?:export|show)\s+.*(?:flexiblebox|flutter_layout_grid|two_dimensional_scrollables)',
    multiLine: true,
  );
  for (final file in publicFiles) {
    final text = file.readAsStringSync();
    if (leakPattern.hasMatch(text)) {
      failures.add('dependency type/export leak found in ${file.path}');
    }
  }
}

void _checkComponentRegistry(List<String> failures) {
  final ignored = {'FxFlexItem', 'FxGridPlacement'};

  final componentsFile = File('lib/src/fx_components.dart');
  if (!componentsFile.existsSync()) {
    failures.add('Could not find lib/src/fx_components.dart');
    return;
  }
  final componentsContent = componentsFile.readAsStringSync();
  final nameRegex = RegExp(r"name:\s*['\x22](Fx\w+)['\x22]");
  final registeredNames = nameRegex
      .allMatches(componentsContent)
      .map((m) => m.group(1)!)
      .toSet();

  final widgetClassRegex = RegExp(
    r'class\s+(Fx\w+)(?:<[^>]+>)?\s+extends\s+(?:StatelessWidget|StatefulWidget)',
  );

  final srcDir = Directory('lib/src');
  final foundWidgets = <String>{};
  for (final entity in srcDir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      for (final match in widgetClassRegex.allMatches(content)) {
        final className = match.group(1)!;
        if (!ignored.contains(className)) {
          foundWidgets.add(className);
        }
      }
    }
  }

  for (final widget in foundWidgets) {
    if (!registeredNames.contains(widget)) {
      failures.add(
        'Public widget $widget is defined but not registered in fxComponentRegistry (in lib/src/fx_components.dart)',
      );
    }
  }
}

void _checkPublicApiSignature(List<String> failures) {
  final signatureFile = File('doc/api/public_api_signature.txt');
  if (!signatureFile.existsSync()) {
    failures.add(
      'Public API signature file not found at ${signatureFile.path}. '
      'Run the harness with the --update-api flag to generate it: '
      'dart run tool/agent_harness.dart --update-api',
    );
    return;
  }

  final expected = signatureFile.readAsStringSync();
  final actual = '${_generateApiSignature().join('\n')}\n';

  if (expected != actual) {
    failures.add(
      'Public API signature mismatch detected! This means a public class, '
      'constructor, or member signature has changed. If this change was intentional, '
      'run the harness with the --update-api flag to regenerate the signature: '
      'dart run tool/agent_harness.dart --update-api\n\n'
      'Differences (Expected vs Actual):\n'
      '${_findDiff(expected, actual)}',
    );
  }
}

void _checkTestCoverageThreshold(List<String> failures) {
  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    failures.add(
      'Coverage file coverage/lcov.info not found. Make sure tests run with --coverage.',
    );
    return;
  }

  var totalLF = 0;
  var totalLH = 0;
  for (final line in lcovFile.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      totalLF += int.parse(line.substring(3).trim());
    } else if (line.startsWith('LH:')) {
      totalLH += int.parse(line.substring(3).trim());
    }
  }

  if (totalLF == 0) {
    failures.add('No coverage lines found in coverage/lcov.info');
    return;
  }

  final coverage = (totalLH / totalLF) * 100;
  stdout.writeln(
    'Measured test coverage: ${coverage.toStringAsFixed(2)}% ($totalLH/$totalLF lines)',
  );

  const threshold = 85.0;
  if (coverage < threshold) {
    failures.add(
      'Test coverage is ${coverage.toStringAsFixed(2)}%, which is below the threshold of $threshold%.',
    );
  }
}

List<String> _generateApiSignature() {
  final signatures = <String>[];
  final exportRegex = RegExp(r"export\s+'([^']+)';");
  final entryFile = File('lib/fx_desktop.dart');
  if (!entryFile.existsSync()) return [];

  final entryContent = entryFile.readAsStringSync();
  final exportedFiles = exportRegex
      .allMatches(entryContent)
      .map((m) => m.group(1)!)
      .toList();

  for (final relPath in exportedFiles) {
    final file = File('lib/$relPath');
    if (!file.existsSync()) continue;
    final lines = file.readAsLinesSync();

    String? currentClass;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty ||
          line.startsWith('//') ||
          line.startsWith('/*') ||
          line.startsWith('*')) {
        continue;
      }

      // Top-level class
      if (line.startsWith('class ') && !line.startsWith('class _')) {
        final classNameMatch = RegExp(
          r'class\s+([A-Za-z0-9_<>]+)',
        ).firstMatch(line);
        if (classNameMatch != null) {
          currentClass = classNameMatch.group(1);
          var decl = line.replaceAll('{', '').trim();
          signatures.add('class $decl');
        }
      }
      // Top-level enum
      else if (line.startsWith('enum ') && !line.startsWith('enum _')) {
        currentClass = null;
        var decl = line.replaceAll('{', '').trim();
        signatures.add('enum $decl');
      }
      // Class constructor/members
      else if (currentClass != null &&
          lines[i].startsWith('  ') &&
          !lines[i].startsWith('   ')) {
        final memberLine = lines[i].trim();
        if (memberLine.startsWith('const ') ||
            memberLine.startsWith('factory ') ||
            memberLine.startsWith(currentClass.split('<')[0])) {
          var decl = memberLine.replaceAll('{', '').replaceAll(';', '').trim();
          if (decl.endsWith(')') || decl.contains(':')) {
            final closeParen = decl.indexOf(')');
            if (closeParen != -1) {
              decl = decl.substring(0, closeParen + 1);
            }
          }
          signatures.add('  $currentClass constructor $decl');
        } else if ((memberLine.startsWith('final ') ||
                memberLine.startsWith('late ') ||
                memberLine.startsWith('static ') ||
                _isMethodOrField(memberLine)) &&
            !memberLine.contains('_') &&
            !memberLine.startsWith('@')) {
          var decl = memberLine.replaceAll('{', '').replaceAll(';', '').trim();
          if (decl.contains('=>')) {
            decl = decl.split('=>')[0].trim();
          }
          signatures.add('  $currentClass member $decl');
        }
      }
      // Reset class context if top-level brace closed or another class starts
      if (lines[i].startsWith('}') && currentClass != null) {
        currentClass = null;
      }
    }
  }
  signatures.sort();
  return signatures;
}

bool _isMethodOrField(String line) {
  if (line.contains('(') && line.contains(')')) return true;
  if (line.startsWith('get ') || line.startsWith('set ')) return true;
  return false;
}

String _findDiff(String expected, String actual) {
  final expectedLines = expected.split('\n');
  final actualLines = actual.split('\n');
  final diff = <String>[];

  final maxLines = expectedLines.length > actualLines.length
      ? expectedLines.length
      : actualLines.length;

  for (var i = 0; i < maxLines; i++) {
    final exp = i < expectedLines.length ? expectedLines[i] : null;
    final act = i < actualLines.length ? actualLines[i] : null;

    if (exp != act) {
      if (exp != null) diff.add('- [Expected] $exp');
      if (act != null) diff.add('+ [Actual]   $act');
    }
  }

  // Limit output to first 10 differences to keep it readable
  if (diff.length > 20) {
    return '${diff.take(20).join('\n')}\n... (truncated)';
  }
  return diff.join('\n');
}

Iterable<File> _trackedTextFiles() sync* {
  final roots = [
    'AGENT.md',
    'CHANGELOG.md',
    'README.md',
    'analysis_options.yaml',
    'doc',
    ..._demoPackageDirs,
    'lib',
    'pubspec.yaml',
    'templates',
    'test',
    'tool',
    '.github',
  ];
  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root) == FileSystemEntityType.file
        ? File(root)
        : Directory(root);
    if (entity is File) {
      yield entity;
      continue;
    }
    if (entity is Directory && entity.existsSync()) {
      for (final child in entity.listSync(recursive: true)) {
        if (child is File &&
            !_isIgnoredPath(child.path) &&
            _isTextFile(child.path)) {
          yield child;
        }
      }
    }
  }
}

bool _isTextFile(String path) {
  return path.endsWith('.dart') ||
      path.endsWith('.md') ||
      path.endsWith('.yaml') ||
      path.endsWith('.yml') ||
      path.endsWith('.json') ||
      path.endsWith('.jinja');
}

bool _isIgnoredPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/.dart_tool/') ||
      normalized.contains('/build/') ||
      normalized.contains('/doc/api/') ||
      normalized.contains('/.git/') ||
      normalized.contains('/.idea/');
}
