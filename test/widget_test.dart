import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_chat_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RealTimeChatApp());
    expect(find.byType(RealTimeChatApp), findsOneWidget);
  });
}
