import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/bible_screen.dart';
import '../screens/home_screen.dart';
import '../screens/mypage_screen.dart';
import '../widgets/login_form.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String userName = '';

  final List<Widget> _screens = [HomeScreen(), BibleScreen(), MyPageScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("로그인"),
            content: LoginForm(
              onSuccess: () async {
                Navigator.pop(context);
                await _loadLoginState();
              },
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final token = await FlutterSecureStorage().read(key: 'accessToken');
    if (token != null) {
      final name = await ApiService.fetchUsername(); // 실제 이름 불러오기
      setState(() {
        isLoggedIn = true;
        userName = name ?? '사용자'; // 없으면 기본값
      });
    }
  }

  void _logout() async {
    await FlutterSecureStorage().delete(key: 'accessToken');
    await FlutterSecureStorage().delete(key: 'refreshToken');
    setState(() {
      isLoggedIn = false;
      userName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garden Bible ♥'),
        backgroundColor: const Color.fromARGB(232, 255, 197, 197),
        actions: [
          if (!isLoggedIn)
            TextButton(
              onPressed: () => _showLoginDialog(context),
              child: Text('로그인', style: TextStyle(color: Colors.white)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: 6),
                  Text(userName, style: TextStyle(color: Colors.white)),
                  SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '성경'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
