import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PrayPage extends StatefulWidget {
  @override
  _PrayPageState createState() => _PrayPageState();
}

class _PrayPageState extends State<PrayPage> {
  final storage = FlutterSecureStorage();
  List<dynamic> myPrayers = [];
  List<dynamic> friendPrayers = [];
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
    fetchMyPrayers();
    fetchFriendPrayers();
  }

  Future<void> _checkLoginState() async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  Future<void> fetchMyPrayers() async {
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('http://localhost:8080/pray/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        myPrayers = jsonDecode(response.body);
      });
    }
  }

  Future<void> fetchFriendPrayers() async {
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('http://localhost:8080/pray/friends'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        friendPrayers = jsonDecode(response.body);
      });
    }
  }

  Future<void> submitPrayer(String content) async {
    final token = await storage.read(key: 'accessToken');
    final response = await http.post(
      Uri.parse('http://localhost:8080/pray'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 200) {
      fetchMyPrayers();
    }
  }

  Future<void> deletePrayer(int id) async {
    final token = await storage.read(key: 'accessToken');
    final response = await http.delete(
      Uri.parse('http://localhost:8080/pray/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      fetchMyPrayers();
    }
  }

  void showPrayerInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('기도문 작성'),
            content: TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '응원의 기도나 메시지를 적어보세요',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("취소"),
              ),
              ElevatedButton(
                onPressed: () {
                  final content = controller.text.trim();
                  if (content.isNotEmpty) {
                    submitPrayer(content);
                  }
                  Navigator.pop(context);
                },
                child: Text("작성"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text("친구 관리")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("로그인이 필요한 기능입니다.", style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 이전 화면으로 돌아가기
                },
                child: Text("로그인하러 가기"),
              ),
            ],
          ),
        ),
      );
    }

    final myList = myPrayers.toList();
    final friendsList = friendPrayers.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("기도 방명록"),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment),
            onPressed: showPrayerInputDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("🙋 나의 기도", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (myPrayers.isNotEmpty)
              ...myList.map((p) => _buildPrayerCard(p, deletable: true))
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  "아직 등록한 기도가 없어요.\n당신의 첫 기도를 들려주세요 🙏",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            SizedBox(height: 24),

            Text("💌 너의 기도", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (friendPrayers.isNotEmpty)
              ...friendsList.map((p) => _buildPrayerCard(p))
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  "아직 친구들의 기도가 없어요.\n기도를 나누어보세요 💬",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> item, {bool deletable = false}) {
    final content = item['content'] ?? '';
    final createdAt = item['createdAt'] ?? '';
    final formattedTime =
        createdAt.isNotEmpty
            ? DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(createdAt))
            : '알 수 없음';
    final username = item['author']['username'] ?? '';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(content),
        subtitle: Text(formattedTime + " " + username),
        trailing:
            deletable
                ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deletePrayer(item['id']),
                )
                : null,
      ),
    );
  }
}
