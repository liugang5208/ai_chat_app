import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/conversation.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppState app = AppStateScope.of(context);
    final List<Conversation> items = app.conversationsSorted(query: _query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('对话'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D2330),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final Conversation c = app.createConversation();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(conversationId: c.id),
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFF4C84FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                onChanged: (String value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1D2330)),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C9D5),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC4C9D5),
                    size: 22,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 22,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  fillColor: const Color(0xFFF6F7FB),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    color: Color(0xFFF5F6F8),
                    indent: 90,
                  ),
              itemBuilder: (BuildContext context, int index) {
                final Conversation item = items[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatPage(conversationId: item.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F1FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/chat${index % 4}.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color(0xFF1D2330),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8E95A6),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
