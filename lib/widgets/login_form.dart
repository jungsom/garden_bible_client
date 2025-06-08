import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'register_form.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;
  LoginForm({required this.onSuccess});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final accessToken = response.headers['authorization']?.split(' ').last;
        final cookie = response.headers['set-cookie'];
        final refreshToken =
            cookie
                ?.split(';')
                .firstWhere((c) => c.startsWith('refreshtoken='))
                ?.split('=')
                .last;

        if (accessToken != null)
          await storage.write(key: 'accessToken', value: accessToken);
        if (refreshToken != null)
          await storage.write(key: 'refreshToken', value: refreshToken);

        widget.onSuccess();
      } else {
        throw Exception('로그인 실패: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              AlertDialog(title: Text("회원가입"), content: RegisterForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: "이메일"),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: "비밀번호"),
          obscureText: true,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _login,
          child: isLoading ? CircularProgressIndicator() : Text("로그인"),
        ),
        TextButton(onPressed: _showRegisterDialog, child: Text("회원가입하시겠습니까?")),
      ],
    );
  }
}
