import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class PrayPage extends StatefulWidget {
  @override
  _PrayPageState createState() => _PrayPageState();
}

class _PrayPageState extends State<PrayPage> {
  final storage = FlutterSecureStorage();
  List<dynamic> myPrayers = [];
  List<dynamic> friendPrayers = [];

  @override
  void initState() {
    super.initState();
    fetchMyPrayers();
    fetchFriendPrayers();
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
            if (myPrayers.isNotEmpty) ...[
              Text("🙋 나의 기도", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...myList.map((p) => _buildPrayerCard(p, deletable: true)),
              SizedBox(height: 24),
            ],
            Text("💌 응원의 메시지", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...friendsList.map((p) => _buildPrayerCard(p)),
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
