import 'dart:io';

const packageName = 'fx_desktop';

void main(List<String> args) {
  final failures = <String>[];
  final version = _readYamlScalar(File('pubspec.yaml'), 'version');

  if (version == null || version.isEmpty) {
    _fail(failures, 'Could not read version from pubspec.yaml.');
  } else {
    _checkPackageVersion(failures, version, args);
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Release sync check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Release sync check passed for $packageName $version.');
}

void _checkPackageVersion(
  List<String> failures,
  String version,
  List<String> args,
) {
  final expectedTag = 'v$version';
  final suppliedTag =
      _optionValue(args, '--tag') ??
      Platform.environment['RELEASE_TAG'] ??
      Platform.environment['GITHUB_REF_NAME'] ??
      _gitExactTag();
  final normalizedTag = suppliedTag?.replaceFirst('refs/tags/', '');

  if (normalizedTag == null || normalizedTag.isEmpty) {
    stdout.writeln(
      'No release tag supplied. Expected release tag for $packageName '
      '$version: $expectedTag',
    );
  } else if (normalizedTag != expectedTag) {
    _fail(
      failures,
      'Release tag "$normalizedTag" does not match pubspec.yaml version '
      '"$version". Expected "$expectedTag".',
    );
  }

  _expectMatch(
    failures,
    file: File('CHANGELOG.md'),
    pattern: RegExp(
      r'^## \[?' + RegExp.escape(version) + r'\]?\b',
      multiLine: true,
    ),
    message: 'CHANGELOG.md must contain a heading for $version.',
  );
  _expectText(
    failures,
    file: File('README.md'),
    text: 'fx_desktop: ^$version',
    message: 'README.md install snippet must match $version.',
  );
  _expectText(
    failures,
    file: File('README.md'),
    text: 'pub-$version',
    message: 'README.md pub badge must match $version.',
  );
  _expectText(
    failures,
    file: File('README.md'),
    text: 'release-v$version',
    message: 'README.md release badge must match $expectedTag.',
  );
  _expectMatch(
    failures,
    file: File('pubspec.yaml'),
    pattern: RegExp(r'^screenshots:\s*$', multiLine: true),
    message: 'pubspec.yaml must declare pub.dev screenshots.',
  );

  for (final path in [
    'doc/screenshots/v$version/fxdesktop-v$version-lookup-renderers.png',
    'doc/screenshots/v$version/fxdesktop-v$version-db-lookup-overlay.png',
    'doc/screenshots/v$version/fxdesktop-v$version-masked-action-editor.png',
  ]) {
    _checkScreenshot(failures, path);
  }
}

String? _optionValue(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == name && i + 1 < args.length) {
      return args[i + 1];
    }
    if (args[i].startsWith('$name=')) {
      return args[i].substring(name.length + 1);
    }
  }
  return null;
}

String? _readYamlScalar(File file, String key) {
  if (!file.existsSync()) return null;
  final prefix = '$key:';
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (!trimmed.startsWith(prefix)) continue;
    return trimmed
        .substring(prefix.length)
        .trim()
        .replaceAll(RegExp(r'''^['"]|['"]$'''), '');
  }
  return null;
}

String? _gitExactTag() {
  final result = Process.runSync('git', [
    'describe',
    '--tags',
    '--exact-match',
    'HEAD',
  ]);
  if (result.exitCode != 0) return null;
  return result.stdout.toString().trim();
}

void _checkScreenshot(List<String> failures, String path) {
  final screenshot = File(path);
  if (!screenshot.existsSync()) {
    _fail(failures, '$path is missing.');
    return;
  }
  if (screenshot.lengthSync() > 4 * 1024 * 1024) {
    _fail(failures, '$path exceeds the pub.dev 4 MB screenshot limit.');
  }
}

void _expectText(
  List<String> failures, {
  required File file,
  required String text,
  required String message,
}) {
  if (!file.existsSync()) {
    _fail(failures, '${file.path} is missing.');
    return;
  }
  if (!file.readAsStringSync().contains(text)) {
    _fail(failures, message);
  }
}

void _expectMatch(
  List<String> failures, {
  required File file,
  required RegExp pattern,
  required String message,
}) {
  if (!file.existsSync()) {
    _fail(failures, '${file.path} is missing.');
    return;
  }
  if (!pattern.hasMatch(file.readAsStringSync())) {
    _fail(failures, message);
  }
}

void _fail(List<String> failures, String message) {
  failures.add(message);
}
