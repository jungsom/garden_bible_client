import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('회원가입 완료')));
      } else {
        throw Exception('회원가입 실패: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 실패: $e')));
    } finally {
      setState(() => isLoading = false);
    }
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
          controller: _usernameController,
          decoration: InputDecoration(labelText: "이름"),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: "비밀번호"),
          obscureText: true,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _register,
          child: isLoading ? CircularProgressIndicator() : Text("회원가입"),
        ),
      ],
    );
  }
}
