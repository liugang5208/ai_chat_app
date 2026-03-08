import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/conversation.dart';
import '../chat/chat_page.dart';
import '../../utils/date_utils.dart';

class MyFavoritesPage extends StatelessWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Conversation> items = AppStateScope.of(
      context,
    ).favoriteConversations();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的收藏',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Conversation item = items[index];
          return ListTile(
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                  item.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF8A93A6)),
                ),
                const SizedBox(height: 8),
                Text(
                  friendlyDate(item.updatedAt),
                  style: const TextStyle(color: Color(0xFFB0B5C2)),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(conversationId: item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
