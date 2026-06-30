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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        useMaterial3: true,
        extensions: const [FxTheme()],
      ),
      home: Scaffold(
        backgroundColor: const Color(0xfff6f7f9),
        body: SafeArea(
          child: FxRibbonDesigner(
            initialDefinition: FxRibbonSamples.explorer(),
            locale: const Locale('en'),
          ),
        ),
      ),
    );
  }
}
