import 'package:flutter_test/flutter_test.dart';
import 'package:ribbon_toolbar_designer/main.dart';

void main() {
  testWidgets('shows the standalone ribbon designer', (tester) async {
    await tester.pumpWidget(const RibbonToolbarDesignerDemoApp());
    await tester.pump();

    expect(find.text('Ribbon Designer'), findsOneWidget);
  });
}
