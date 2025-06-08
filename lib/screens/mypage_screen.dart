import 'package:bible_app/screens/video_page.dart';
import 'package:flutter/material.dart';
import '../screens/friend_page.dart';
import '../screens/pray_page.dart';

class MyPageScreen extends StatelessWidget {
  final List<_MoreMenuItem> menuItems = [
    _MoreMenuItem("친구", Icons.people),
    _MoreMenuItem("오늘의 말씀", Icons.wb_sunny),
    _MoreMenuItem("기도", Icons.pan_tool_alt_rounded),
    _MoreMenuItem("동영상", Icons.ondemand_video),
    _MoreMenuItem("이벤트", Icons.location_on),
    _MoreMenuItem("배지", Icons.emoji_events),
    _MoreMenuItem("활동", Icons.bolt),
    _MoreMenuItem("소개", Icons.info_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item.icon, color: Colors.black87),
            title: Text(item.title),
            onTap: () {
              if (item.title == "친구") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FriendPage()), // ← 여기에 연결
                );
              } else if (item.title == "기도") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PrayPage()), // 추가
                );
              } else if (item.title == '동영상') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VideoPage()), // 추가
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceholderPage(title: item.title),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _MoreMenuItem {
  final String title;
  final IconData icon;
  _MoreMenuItem(this.title, this.icon);
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("'$title' 페이지 내용 준비 중...")),
    );
  }
}
