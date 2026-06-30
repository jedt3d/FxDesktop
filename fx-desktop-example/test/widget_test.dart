import 'package:flutter_test/flutter_test.dart';
import 'package:fx_desktop_example/main.dart';

void main() {
  testWidgets('renders the FxDesktop gallery', (tester) async {
    await tester.pumpWidget(const FxDesktopExampleApp());

    expect(find.text('FxDesktop Component Harness'), findsOneWidget);
    expect(find.text('FxButton'), findsOneWidget);
    expect(find.text('FxFlexLayout'), findsOneWidget);
    expect(find.text('FxListBox'), findsOneWidget);
  });
}
