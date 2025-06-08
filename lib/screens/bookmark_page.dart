import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/bible_verse.dart';
import '../services/api_service.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final storage = FlutterSecureStorage();

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

  List<BibleVerse> bookmarkedVerses = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarksFromServer();
  }

  Future<void> _loadBookmarksFromServer() async {
    final token = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('http://localhost:8080/bookmark/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<BibleVerse> loadedVerses = [];

      for (var item in data) {
        final book = item['book'];
        final chapter = item['chapter'];
        final verseNum = item['verse'];

        final verses = await ApiService.fetchBibleChapter(book, chapter);
        final verse = verses.firstWhere(
          (v) => v.id.verse == verseNum,
          orElse:
              () => BibleVerse(
                id: BibleVerseId(book: book, chapter: chapter, verse: verseNum),
                content: '',
              ),
        );
        loadedVerses.add(verse);
      }

      setState(() {
        bookmarkedVerses = loadedVerses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('북마크한 말씀')),
      body:
          bookmarkedVerses.isEmpty
              ? Center(
                child: Text(
                  '📖 북마크한 말씀이 없습니다.\n말씀을 길게 누르면 북마크할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookmarkedVerses.length,
                itemBuilder: (context, index) {
                  final verse = bookmarkedVerses[index];
                  final bookName = books[verse.id.book - 1];

                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$bookName ${verse.id.chapter}:${verse.id.verse}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                verse.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () async {
                            await ApiService.toggleBookmark(
                              verse.id.book,
                              verse.id.chapter,
                              verse.id.verse,
                            );
                            setState(() {
                              bookmarkedVerses.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
