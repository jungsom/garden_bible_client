import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/bible_verse.dart';

class ApiService {
  static final storage = FlutterSecureStorage();
  static final baseUrl = 'http://localhost:8080';

  /// ✅ 성경 구절 조회
  static Future<List<BibleVerse>> fetchBibleChapter(
    int book,
    int chapter,
  ) async {
    final url = Uri.parse('$baseUrl/bible?book=$book&chapter=$chapter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => BibleVerse.fromJson(e)).toList();
    } else {
      throw Exception('성경 구절을 불러오지 못했습니다');
    }
  }

  static Future<String?> fetchUsername() async {
    final token = await storage.read(key: 'accessToken');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchVideos() async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=PLezNmjF2Hxb1a5AObDqogTk5zIkwK0-pF&maxResults=10&key=AIzaSyBLTgL-7y2q2Ka3IHtA0mPBNQVoROTnZCQ',
      ),
    );

    print('📡 status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List items = data['items'];
      final List<Map<String, dynamic>> videos = [];

      for (var item in items) {
        final snippet = item['snippet'];
        // private 영상은 썸네일이 없음 → 필터링
        if (snippet['title'] == 'Private video') continue;
        if (snippet['thumbnails'] == null) continue;

        videos.add({
          'title': snippet['title'],
          'description': snippet['description'],
          'thumbnail': snippet['thumbnails']['medium']['url'],
          'videoId': snippet['resourceId']['videoId'],
        });
      }

      return videos;
    } else {
      throw Exception('유튜브 영상 요청 실패: ${response.statusCode}');
    }
  }
}
