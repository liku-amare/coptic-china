import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class BibleDatabase {
  static final BibleDatabase _instance = BibleDatabase._internal();
  static Database? _database;

  factory BibleDatabase() => _instance;

  BibleDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'bible.sqlite');

    // Copy from assets if it doesn't exist
    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/db/bible.sqlite');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes);
    }

    return openDatabase(path);
  }

  // Example: Get books for a given language
  Future<List<Map<String, dynamic>>> getBooks({int languageId = 1}) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT book_commons.id, books.book_name, book_commons.book_common_testament
      FROM books
      JOIN book_commons ON books.book_common_id = book_commons.id
      WHERE books.language_id = ?
      ORDER BY book_commons.id
    ''',
      [languageId],
    );
  }

  // Example: Get chapters for a book
  Future<List<int>> getChapters(int bookCommonId, int languageId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT verse_chapter FROM verses
      WHERE book_common_id = ? AND language_id = ?
      ORDER BY verse_chapter
    ''',
      [bookCommonId, languageId],
    );

    return result.map((row) => row['verse_chapter'] as int).toList();
  }

  // Example: Get verses of a chapter
  Future<List<Map<String, dynamic>>> getVerses(
    int bookCommonId,
    int chapter,
    int languageId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT verse_number, verse FROM verses
      WHERE book_common_id = ? AND verse_chapter = ? AND language_id = ?
      ORDER BY verse_number
    ''',
      [bookCommonId, chapter, languageId],
    );
  }

  Future<List<Map<String, dynamic>>> getDailyReadings(
    int copticMonth,
    int copticDay,
    int languageId,
  ) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT rc.reading_name, bc.book_name, dr.from_chapter, dr.to_chapter,dr.from_verse, dr.to_verse, v.verse_chapter, v.verse_number, v.verse
        FROM daily_readings dr INNER JOIN readings rc ON dr.reading_common_id = rc.reading_common_id INNER JOIN books bc ON dr.common_book_id = bc.book_common_id INNER JOIN verses v ON v.book_common_id = dr.common_book_id AND ((v.verse_chapter = dr.from_chapter AND v.verse_number >= dr.from_verse AND ((dr.to_chapter = dr.from_chapter AND v.verse_number <= dr.to_verse) OR (dr.to_chapter > dr.from_chapter))) OR (v.verse_chapter > dr.from_chapter AND v.verse_chapter < dr.to_chapter) OR (v.verse_chapter > dr.from_chapter AND v.verse_chapter = dr.to_chapter AND v.verse_number <= dr.to_verse))
        WHERE dr.coptic_month_common_id = ? AND dr.day = ? AND v.language_id = ? AND bc.language_id = ? AND rc.language_id = ?
        ORDER BY dr.reading_common_id, v.verse_chapter, v.verse_number
      ''',
        [copticMonth, copticDay, languageId, languageId, languageId],
      );
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> search(
    String query,
    int languageId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT b.book_common_id, b.book_name, v.verse_chapter, v.verse_number, v.verse
      FROM verses v
      JOIN books b ON v.book_common_id = b.book_common_id
      WHERE v.verse LIKE ? AND v.language_id = ? AND b.language_id = ?
      ORDER BY b.book_common_id, v.verse_chapter, v.verse_number
    ''',
      ['%$query%', languageId, languageId],
    );
  }
}
