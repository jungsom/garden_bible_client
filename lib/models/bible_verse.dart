// models/bible_verse.dart

class BibleVerseId {
  final int book;
  final int chapter;
  final int verse;

  BibleVerseId({
    required this.book,
    required this.chapter,
    required this.verse,
  });

  factory BibleVerseId.fromJson(Map<String, dynamic> json) {
    return BibleVerseId(
      book: json['book'] as int,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
    );
  }
}

class BibleVerse {
  final BibleVerseId id;
  final String content;

  BibleVerse({required this.id, required this.content});

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: BibleVerseId.fromJson(json['id']),
      content: json['content'] ?? '본문 없음',
    );
  }
}
