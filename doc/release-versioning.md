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
- `AGENT.md` when the phase changes agent workflow, validation, screenshots, or
  release discipline
- the active Flutter desktop skill when the phase teaches a reusable Flutter
  macOS build, validation, screenshot, signing, or release lesson
- release notes or milestone documentation
- example app documentation when the demo changes
- generated API docs when publishing or archiving release documentation

All version references in the repository should describe the same release.

## Milestone 2 Phase Versions

Milestone 2 uses the `0.2.x` release line:

- Phase 2.1: `v0.2.1`
- Phase 2.2: `v0.2.2`
- Phase 2.3: `v0.2.3`
- Phase 2.4: `v0.2.4`
- Phase 2.5: `v0.2.5`
- Phase 2.6: `v0.2.6`

Each phase release must include the demo harness updates, screenshots, quality
checks, version bump, documentation/process-surface updates, tag, and GitHub
Release for that phase.

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
- `AGENT.md`, `CHANGELOG.md`, README, and the active Flutter desktop skill have
  been reviewed and updated or explicitly marked as no-change in the PR
- the example app has been checked when UI changes are included
- phase screenshots have been captured when UI changes are included
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

Milestone 2 implementation phases are not small documentation-only updates, so
each Phase 2.1 through 2.6 release should create a GitHub Release and attach the
phase screenshots.

## Milestone 3 Release Versions

Milestone 3 uses the `0.3.x` release line. The original implementation phases
were consolidated into the `v0.3.0` baseline and then refined through smaller
follow-up releases:

- `v0.3.0`: Milestone 3 ListBox/Grid depth baseline.
- `v0.3.1`: interactive `listbox_demo` gallery and scrollbar polish.
- `v0.3.2`: Excel-style sizing, wrapping, implicit rendering, and progress overlays.
- `v0.3.3`: capped auto-fit resizing, wrapping synchronization, and undoable layout changes.
- `v0.3.4`: range slider, row reordering, crosshair visualization, and inline styled cells.
- `v0.3.5`: lookup providers, custom cell renderers, and hosted combobox overlays.
- `v0.3.6`: multi-column lookups, input masks, cell action buttons, and active row/column background highlighting.

Future `0.3.x` documentation-only reconciliation work should not change
`pubspec.yaml`, README install versions, or tags. A version bump is required
only when implementation, public API, generated documentation, or release
artifacts change in a way that should be published.

## Pub.dev

Before publishing to pub.dev:

- run `dart run tool/agent_harness.dart`
- confirm `flutter pub publish --dry-run` has 0 warnings
- confirm the package version has not already been published
- confirm the README install snippet matches `pubspec.yaml`
- confirm public API docs and examples match the release behavior
