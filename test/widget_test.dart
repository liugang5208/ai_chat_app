import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_app/main.dart';

void main() {
  testWidgets('Login success with admin/admin', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('登录'), findsOneWidget);
    expect(find.text('登录成功'), findsNothing);

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('对话'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
  });
}
