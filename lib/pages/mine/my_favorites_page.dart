import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../utils/date_utils.dart';

class MyFavoritesPage extends StatelessWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FavoriteEntry> items = AppStateScope.of(
      context,
    ).favoriteEntries();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的收藏',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                '暂无收藏内容',
                style: TextStyle(color: Color(0xFF9FA6B6), fontSize: 15),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final FavoriteEntry item = items[index];
                return ListTile(
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
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
                        friendlyDate(item.createdAt),
                        style: const TextStyle(color: Color(0xFFB0B5C2)),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showDetailDialog(context, item);
                  },
                );
              },
            ),
    );
  }

  Future<void> _showDetailDialog(
    BuildContext context,
    FavoriteEntry item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      item.detail,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF4E5667),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
