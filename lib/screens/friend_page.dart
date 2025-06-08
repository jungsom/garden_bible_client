import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/bible_verse.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FriendPage extends StatefulWidget {
  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final codeController = TextEditingController();
  List<dynamic> requests = [];
  List<dynamic> accepted = [];
  bool isLoggedIn = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchRequested();
    fetchAccepted();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    if (token != null) {
      final name = await ApiService.fetchUsername();
      setState(() {
        isLoggedIn = true;
        userName = name ?? '';
      });
      fetchRequested();
      fetchAccepted();
    }
  }

  Future<void> fetchRequested() async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('http://localhost:8080/friends/respond'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() => requests = jsonDecode(response.body));
    }
  }

  Future<void> fetchAccepted() async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('http://localhost:8080/friends/follow'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() => accepted = jsonDecode(response.body));
    }
  }

  Future<void> sendFriendRequest() async {
    final code = codeController.text;
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    final userResponse = await http.get(
      Uri.parse('http://localhost:8080/friends/invite/$code'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (userResponse.statusCode == 200) {
      final user = jsonDecode(userResponse.body);
      final shouldSend = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('친구 신청'),
              content: Text('${user["username"]}님께 친구 신청 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("신청"),
                ),
              ],
            ),
      );

      if (shouldSend == true) {
        final response = await http.post(
          Uri.parse('http://localhost:8080/friends/request/${user["id"]}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('친구 신청 완료')));
        fetchRequested(); // 갱신
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('코드로 사용자 찾기 실패')));
    }
  }

  Future<void> respondToRequest(int id, bool accept) async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    final url =
        accept
            ? 'http://localhost:8080/friends/accept/$id'
            : 'http://localhost:8080/friends/refuse/$id';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchRequested();
    fetchAccepted();
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
    return Scaffold(
      appBar: AppBar(title: Text('친구 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: "초대 코드 입력",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendFriendRequest,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text("받은 친구 요청", style: TextStyle(fontWeight: FontWeight.bold)),
            ...requests.map(
              (f) => Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        f['fromUser']['username'],
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => respondToRequest(f['id'], true),
                          child: Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => respondToRequest(f['id'], false),
                          child: Icon(Icons.clear, size: 20, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text("내 친구", style: TextStyle(fontWeight: FontWeight.bold)),
            ...accepted.map(
              (f) => Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        f['username'],
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}