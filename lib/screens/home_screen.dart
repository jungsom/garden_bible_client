import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final String verseText = "내가 너희 주와 선생이 되어 너희 발을 씻어 주었으니 너희도 서로 발을 씻어 주어야 한다.";
  final String verseRef = "(요한복음 13:14 KLB)";
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
          Container(
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
