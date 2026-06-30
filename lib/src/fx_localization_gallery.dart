import 'package:flutter/material.dart';

import 'fx_choice_controls.dart';
import 'fx_components.dart';
import 'fx_datetime_controls.dart';
import 'fx_form_inputs.dart';
import 'fx_localizations.dart';
import 'fx_navigation_containers.dart';
import 'fx_navigation_controls.dart';
import 'fx_tables.dart';
import 'fx_utility_controls.dart';
import 'l10n/fx_desktop_localizations.dart';

/// One-window localization gallery for FxDesktop component-owned text.
class FxLocalizationGallery extends StatefulWidget {
  /// Creates the localization gallery.
  const FxLocalizationGallery({
    super.key,
    this.initialLocale = const Locale('en'),
    this.locales = FxDesktopLocalizations.supportedLocales,
  });

  /// Locale shown when the gallery first builds.
  final Locale initialLocale;

  /// Locales offered by the gallery language switcher.
  final List<Locale> locales;

  @override
  State<FxLocalizationGallery> createState() => _FxLocalizationGalleryState();
}

class _FxLocalizationGalleryState extends State<FxLocalizationGallery> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  @override
  void didUpdateWidget(FxLocalizationGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocale != widget.initialLocale &&
        widget.initialLocale != _locale) {
      _locale = widget.initialLocale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
      delegates: FxDesktopLocalizations.localizationsDelegates,
      child: Builder(
        builder: (context) {
          final localizations = fxDesktopLocalizationsOf(context);
          final direction = Directionality.of(context);

          return ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 1024,
                    maxWidth: 1280,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GalleryHeader(
                        localizations: localizations,
                        direction: direction,
                        locale: _locale,
                        locales: widget.locales,
                        onLocaleChanged: (locale) {
                          setState(() => _locale = locale);
                        },
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _GallerySection(
                            title: localizations.galleryFormSection,
                            width: 398,
                            child: _FormControlsPanel(
                              localizations: localizations,
                            ),
                          ),
                          _GallerySection(
                            title: localizations.galleryChoiceSection,
                            width: 398,
                            child: _ChoiceControlsPanel(
                              localizations: localizations,
                            ),
                          ),
                          _GallerySection(
                            title: localizations.galleryNavigationSection,
                            width: 398,
                            child: _NavigationPanel(
                              localizations: localizations,
                            ),
                          ),
                          _GallerySection(
                            title: localizations.galleryDateTimeColorSection,
                            width: 398,
                            child: _DateColorPanel(
                              localizations: localizations,
                            ),
                          ),
                          _GallerySection(
                            title: localizations.galleryTableSection,
                            width: 620,
                            child: _TablePanel(localizations: localizations),
                          ),
                          _GallerySection(
                            title: localizations.galleryStateSection,
                            width: 576,
                            child: _StatePanel(),
                          ),
                          _GallerySection(
                            title: localizations.galleryPoSection,
                            width: 620,
                            child: _PoPanel(localizations: localizations),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.localizations,
    required this.direction,
    required this.locale,
    required this.locales,
    required this.onLocaleChanged,
  });

  final FxDesktopLocalizations localizations;
  final TextDirection direction;
  final Locale locale;
  final List<Locale> locales;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.galleryTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.gallerySubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  Text(
                    '${localizations.galleryLocaleLabel}: ${locale.toLanguageTag()}',
                  ),
                  Text(
                    '${localizations.galleryDirectionLabel}: ${direction.name}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: FxSegmentedButton<Locale>(
            value: locale,
            onChanged: onLocaleChanged,
            options: [
              for (final item in locales)
                FxSegmentedOption<Locale>(
                  value: item,
                  label: _languageLabel(localizations, item),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _languageLabel(FxDesktopLocalizations localizations, Locale locale) {
    return switch (locale.languageCode) {
      'th' => localizations.galleryLanguageThai,
      'ja' => localizations.galleryLanguageJapanese,
      'ne' => localizations.galleryLanguageNepali,
      _ => localizations.galleryLanguageEnglish,
    };
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.title,
    required this.child,
    required this.width,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _FormControlsPanel extends StatelessWidget {
  const _FormControlsPanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FxTextField(
          label: localizations.galleryCustomerLabel,
          hintText: localizations.galleryCustomerHint,
          value: localizations.galleryCustomerHint,
          onChanged: (_) {},
          reserveSupportingTextSpace: true,
        ),
        const SizedBox(height: 10),
        FxPopupMenu(
          label: localizations.galleryStatusLabel,
          options: const [],
          onChanged: (_) {},
          reserveSupportingTextSpace: true,
        ),
        const SizedBox(height: 4),
        FxComboBox(
          label: localizations.galleryPriorityLabel,
          options: [
            localizations.galleryOpenStatus,
            localizations.galleryClosedStatus,
          ],
          value: localizations.galleryOpenStatus,
          onChanged: (_) {},
          onCommit: (_) {},
        ),
        const SizedBox(height: 4),
        FxCheckBox(
          label: localizations.galleryEnabledLabel,
          value: true,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _ChoiceControlsPanel extends StatelessWidget {
  const _ChoiceControlsPanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FxRadioGroup<String>(
          orientation: FxChoiceOrientation.horizontal,
          value: 'selected',
          onChanged: (_) {},
          options: [
            FxRadioOption(
              value: 'selected',
              label: localizations.gallerySelectedLabel,
            ),
            FxRadioOption(
              value: 'open',
              label: localizations.galleryOpenStatus,
            ),
          ],
        ),
        const SizedBox(height: 10),
        FxSegmentedButton<String>(
          value: 'compact',
          onChanged: (_) {},
          options: [
            FxSegmentedOption(
              value: 'compact',
              label: localizations.galleryCompactLabel,
            ),
            FxSegmentedOption(
              value: 'detailed',
              label: localizations.galleryDetailedLabel,
            ),
          ],
        ),
        const SizedBox(height: 10),
        FxSlider(value: 64, valueLabel: '64%', onChanged: (_) {}),
      ],
    );
  }
}

class _NavigationPanel extends StatelessWidget {
  const _NavigationPanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FxTabPanel(
          tabs: [
            localizations.gallerySummaryTab,
            localizations.galleryAuditTab,
          ],
          selectedIndex: 0,
          onChanged: (_) {},
          children: [
            FxDisclosureTriangle(
              expanded: true,
              title: localizations.gallerySummaryTab,
              onChanged: (_) {},
              child: Text(localizations.galleryPoStatus),
            ),
            Text(localizations.galleryAuditTab),
          ],
        ),
        const SizedBox(height: 12),
        const FxSeparator(),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: FxProgressBar(value: 72)),
            SizedBox(width: 12),
            FxProgressWheel(size: 22),
          ],
        ),
      ],
    );
  }
}

class _DateColorPanel extends StatelessWidget {
  const _DateColorPanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FxDateTimePicker(
          label: localizations.galleryStartDateLabel,
          value: null,
          onChanged: (_) {},
          reserveSupportingTextSpace: true,
        ),
        const SizedBox(height: 10),
        FxColorPicker(
          label: localizations.galleryAccentColorLabel,
          value: null,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _TablePanel extends StatelessWidget {
  const _TablePanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return FxListBox(
      height: 190,
      selectedRowIds: const {'order-2'},
      onSelectionChanged: (_) {},
      columns: [
        FxListBoxColumn(
          id: 'order',
          caption: localizations.galleryOrderColumn,
          width: const FxColumnWidth.fixed(120),
        ),
        FxListBoxColumn(
          id: 'owner',
          caption: localizations.galleryOwnerColumn,
          width: const FxColumnWidth.fixed(180),
        ),
        FxListBoxColumn(
          id: 'state',
          caption: localizations.galleryStateColumn,
          width: const FxColumnWidth.fixed(140),
          type: FxCellType.choice([
            localizations.galleryOpenStatus,
            localizations.galleryClosedStatus,
          ]),
        ),
      ],
      rows: [
        FxListBoxRow(
          id: 'order-1',
          cells: {
            'order': '1001',
            'owner': localizations.galleryCustomerLabel,
            'state': localizations.galleryOpenStatus,
          },
        ),
        FxListBoxRow(
          id: 'order-2',
          cells: {
            'order': '1002',
            'owner': localizations.galleryPriorityLabel,
            'state': localizations.galleryClosedStatus,
          },
        ),
      ],
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FxGrid(
          height: 88,
          state: FxTableState.empty,
          columns: [FxGridColumn(id: 'state')],
          rows: [],
        ),
        const SizedBox(height: 10),
        const FxListBox(
          height: 112,
          state: FxTableState.error,
          columns: [FxListBoxColumn(id: 'state', caption: 'State')],
          rows: [],
        ),
      ],
    );
  }
}

class _PoPanel extends StatelessWidget {
  const _PoPanel({required this.localizations});

  final FxDesktopLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 13, height: 1.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.galleryPoStatus),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              Text(
                'grid.context_menu.copy_selection: ${localizations.gridContextMenuCopySelection}',
              ),
              Text(
                'designer.edit_menu.copy_item: ${localizations.designerEditMenuCopyItem}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
