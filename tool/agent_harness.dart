import 'dart:io';

Future<void> main() async {
  final failures = <String>[];

  await _run('dart', ['format', '--set-exit-if-changed', '.'], failures);
  await _run('flutter', ['analyze'], failures);
  await _run('flutter', ['test'], failures);
  await _run('flutter', ['pub', 'run', 'dartdoc'], failures);
  await _run('flutter', ['pub', 'publish', '--dry-run'], failures);
  await _run('flutter', ['pub', 'get'], failures, workingDirectory: 'example');
  await _run('flutter', ['analyze'], failures, workingDirectory: 'example');
  await _run('flutter', ['test'], failures, workingDirectory: 'example');

  _checkNoMachineLocalPaths(failures);
  _checkPublicApiDoesNotLeakDependencies(failures);

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
      'C:'
      r'\\'
      'Users'
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

Iterable<File> _trackedTextFiles() sync* {
  final roots = [
    'AGENT.md',
    'CHANGELOG.md',
    'README.md',
    'analysis_options.yaml',
    'doc',
    'example',
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
