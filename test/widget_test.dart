import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_app/main.dart';
import 'package:ai_chat_app/models/chat_config.dart';
import 'package:ai_chat_app/models/conversation.dart';
import 'package:ai_chat_app/models/tag_item.dart';
import 'package:ai_chat_app/models/vendor_profile.dart';

void main() {
  testWidgets('Login success with admin/admin', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        initialTags: <TagItem>[],
        initialConfigs: <String, ChatConfig>{},
        initialActiveVendor: null,
        initialVendors: <VendorProfile>[],
        initialConversations: <Conversation>[],
        initialNextConvId: 1,
        initialNextMsgId: 1,
      ),
    );

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
