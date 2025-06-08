import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  Future<Map<String, String>> fetchTodayVerse() async {
    final int day = DateTime.now().day;
    final int psalmChapter = (day % 150) + 1;

    final response = await http.get(
      Uri.parse('http://localhost:8080/bible?book=19&chapter=$psalmChapter'),
    );

    if (response.statusCode == 200) {
      final verses = jsonDecode(response.body);
      final index = DateTime.now().day % verses.length;
      final verse = verses[index];

      return {
        'text': verse['content'],
        'ref': "(시편 ${verse['id']['chapter']}:${verse['id']['verse']})",
      };
    } else {
      throw Exception("말씀을 불러올 수 없습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());
    final String weather = "24°C, 맑음"; // 목데이터

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "$date",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12),

          /// 날씨 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _sharedCardDecoration(),
            child: Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange, size: 32),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "오늘의 날씨",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(weather, style: TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          /// 오늘의 말씀 카드
          FutureBuilder<Map<String, String>>(
            future: fetchTodayVerse(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Text("말씀을 불러올 수 없습니다");
              }

              final verseText = snapshot.data!['text']!;
              final verseRef = snapshot.data!['ref']!;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: _sharedCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          "오늘의 말씀",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(text: verseText),
                          TextSpan(
                            text: '\n$verseRef',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration _sharedCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }
}
