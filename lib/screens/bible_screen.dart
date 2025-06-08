import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/bible_verse.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BibleScreen extends StatefulWidget {
  @override
  _BibleScreenState createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  int selectedBookIndex = 0; // 0부터 시작 (book=1로 보낼 것)
  int selectedChapter = 1;

  final List<String> books = [
    '창세기',
    '출애굽기',
    '레위기',
    '민수기',
    '신명기',
    '여호수아',
    '사사기',
    '룻기',
    '사무엘상',
    '사무엘하',
    '열왕기상',
    '열왕기하',
    '역대상',
    '역대하',
    '에스라',
    '느헤미야',
    '에스더',
    '욥기',
    '시편',
    '잠언',
    '전도서',
    '아가',
    '이사야',
    '예레미야',
    '예레미야애가',
    '에스겔',
    '다니엘',
    '호세아',
    '요엘',
    '아모스',
    '오바댜',
    '요나',
    '미가',
    '나훔',
    '하박국',
    '스바냐',
    '학개',
    '스가랴',
    '말라기',
    '마태복음',
    '마가복음',
    '누가복음',
    '요한복음',
    '사도행전',
    '로마서',
    '고린도전서',
    '고린도후서',
    '갈라디아서',
    '에베소서',
    '빌립보서',
    '골로새서',
    '데살로니가전서',
    '데살로니가후서',
    '디모데전서',
    '디모데후서',
    '디도서',
    '빌레몬서',
    '히브리서',
    '야고보서',
    '베드로전서',
    '베드로후서',
    '요한일서',
    '요한이서',
    '요한삼서',
    '유다서',
    '요한계시록',
  ];
  late Future<List<BibleVerse>> _versesFuture;

  @override
  void initState() {
    super.initState();
    _versesFuture = ApiService.fetchBibleChapter(
      selectedBookIndex + 1,
      selectedChapter,
    );
  }

  void _loadVerses() {
    final bookId = selectedBookIndex + 1;
    _versesFuture = ApiService.fetchBibleChapter(bookId, selectedChapter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedBookIndex,
                  items: List.generate(books.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(books[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedBookIndex = value;
                        selectedChapter = 1;
                        _loadVerses();
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedChapter,
                  items: List.generate(10, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}장'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedChapter = value;
                        _loadVerses();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(72, 255, 197, 197),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "${books[selectedBookIndex]} $selectedChapter장",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<BibleVerse>>(
            future: _versesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('해당 장의 말씀이 없습니다.'));
              }

              final verses = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1} ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            verses[index].content,
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
