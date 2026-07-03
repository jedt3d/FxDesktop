import 'package:flutter/material.dart';
import 'package:fx_desktop/fx_desktop.dart';

void main() {
  runApp(const RibbonToolbarDesignerDemoApp());
}

class RibbonToolbarDesignerDemoApp extends StatelessWidget {
  const RibbonToolbarDesignerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FxDesktop Ribbon Designer',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: FxDesktopLocalizations.supportedLocales,
      localizationsDelegates: FxDesktopLocalizations.localizationsDelegates,
      theme: FxThemeData.light(),
      darkTheme: FxThemeData.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: FxRibbonDesigner(
              initialDefinition: FxRibbonSamples.explorer(),
              locale: const Locale('en'),
            ),
          ),
        ),
      ),
    );
  }
}
