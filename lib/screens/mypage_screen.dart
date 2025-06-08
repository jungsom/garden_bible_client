import 'package:bible_app/screens/bookmark_page.dart';
import 'package:bible_app/screens/video_page.dart';
import 'package:flutter/material.dart';
import '../screens/friend_page.dart';
import '../screens/pray_page.dart';
import '../screens/bookmark_page.dart';

class MyPageScreen extends StatelessWidget {
  final List<_MoreMenuItem> menuItems = [
    _MoreMenuItem("친구", Icons.people),
    _MoreMenuItem("기도", Icons.pan_tool_alt_rounded),
    _MoreMenuItem("북마크", Icons.bookmark),
    _MoreMenuItem("동영상", Icons.ondemand_video),
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
              } else if (item.title == '소개') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _buildIntroPage(context),
                  ), // 소개용 페이지로 분기
                );
              } else if (item.title == '북마크') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookmarkPage()), // 추가
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

  Widget _buildIntroPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('소개')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "📖 정원 바이블 소개\n\n"
                "정원 바이블은 말씀 묵상과 기도를 위한 가벼운 성경 앱입니다.\n"
                "성경을 쉽고 가볍게 읽고, 나만의 기도문을 작성하며,\n"
                "친구와 함께 신앙을 나누고 응원할 수 있는 기능을 제공합니다.\n",
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
              SizedBox(height: 24),
              Text(
                "📚 성경 저작권 안내\n\n"
                "이 앱은 「개역한글판 성경」을 사용하고 있으며,\n"
                "저작권은 ⓒ 대한성서공회에 있습니다.\n"
                "해당 본문은 비영리적 개인 사용 및 묵상 목적으로만 제공되며,\n"
                "무단 복제 및 상업적 사용을 금합니다.",
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
              SizedBox(height: 24),
              Text(
                "✉️ 문의: ning414523@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
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
