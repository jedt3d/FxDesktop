/// Internal helpers shared by FxDesktop inputs that use [InputDecoration].
const fxReservedSupportingText = ' ';

/// Returns the helper text that should be passed to an input decoration.
String? fxEffectiveHelperText({
  required String? helpText,
  required String? errorText,
  required bool reserveSupportingTextSpace,
  bool hasCounter = false,
}) {
  if (helpText != null || errorText != null) {
    return helpText;
  }
  if (reserveSupportingTextSpace && !hasCounter) {
    return fxReservedSupportingText;
  }
  return null;
}
