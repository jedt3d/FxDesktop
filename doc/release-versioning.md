# Release Versioning

FxDesktop uses semantic versioning for package releases and Git tags.

Planning-only work does not change the package version. Version bumps happen
only when implementation, documentation, tests, and demo coverage are ready to
be released.

## Version Surfaces

When a milestone is accepted for release, update these surfaces together:

- `pubspec.yaml` package version
- README install snippet
- `CHANGELOG.md`
- release notes or milestone documentation
- example app documentation when the demo changes
- generated API docs when publishing or archiving release documentation

All version references in the repository should describe the same release.

## Changelog Style

`CHANGELOG.md` is a communication document, not a compressed commit log.

Each release entry should explain:

- what changed
- why the change matters
- which user or developer workflow is affected
- what was added, changed, clarified, fixed, or validated
- any migration, versioning, or release notes that a human should know before
  reading the commits

Prefer short paragraphs and grouped bullets over raw commit summaries.

## Tagging

Use tags in this format:

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

Create the tag only after:

- the release commit is complete
- `dart run tool/agent_harness.dart` passes
- the example app has been checked when UI changes are included
- the changelog describes the release

Prefer tagging the branch that will be merged or has already been merged. Do
not tag exploratory branches.

## GitHub Releases

A GitHub Release is useful when the milestone has meaningful release notes,
screenshots, demo app changes, or a pub.dev publish candidate.

Create a GitHub Release when:

- the release has a version tag
- the changelog entry is ready to share
- screenshots or built demo artifacts help users understand the change
- CI and local harness checks pass

GitHub Releases are optional for small documentation-only updates.

## Pub.dev

Before publishing to pub.dev:

- run `dart run tool/agent_harness.dart`
- confirm `flutter pub publish --dry-run` has 0 warnings
- confirm the package version has not already been published
- confirm the README install snippet matches `pubspec.yaml`
- confirm public API docs and examples match the release behavior
