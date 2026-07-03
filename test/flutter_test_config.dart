import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Runs once before the whole test suite.
///
/// The FxDesktop theme resolves fonts through google_fonts. Tests must never
/// reach out to the network: disable runtime fetching so google_fonts falls
/// back to the ambient test font instead of throwing on a failed http fetch.
/// This keeps widget and golden tests deterministic and offline.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
