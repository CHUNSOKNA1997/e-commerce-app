import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/main.dart';
import 'package:e_commerce_app/services/api_client.dart';

void main() {
  testWidgets('app boots into onboarding flow', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: ApiClient()));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
  });
}
