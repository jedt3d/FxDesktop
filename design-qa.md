# Design QA

## Ribbon Toolbar v0.5.1

Visual truth:

- `doc/screenshots-ribbon-references/home_tab.png`
- `doc/screenshots-ribbon-references/share_tab.png`
- `doc/screenshots-ribbon-references/view_atb.png`

Implementation evidence:

- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-explorer.png`
- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-home.png`
- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-share.png`
- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-view.png`
- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-toolbar-menu-en.png`
- `doc/screenshots/v0.5.1/ribbon/fxdesktop-ribbon-designer-ja.png`

Viewport:

- Toolbar screenshots: 1280 px wide.
- Designer screenshot: 1360 px wide.

Checks:

- The prior uneven card-like ribbon groups were replaced by flat command bands
  with group dividers.
- Home, Share, and View tabs render as separate release states.
- Row commands use aligned columns and fixed row sizing.
- Dropdown behavior is represented by the Options menu screenshot.
- Embedded SVG icons keep their intended colors.
- The designer can load, preview, validate, and export the expanded Explorer
  sample.

Final result: passed for the v0.5.1 release candidate.
