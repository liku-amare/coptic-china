import 'package:coptic_reader/database/bible_database_helper.dart';
import 'package:flutter/material.dart';

class VersePage extends StatefulWidget {
  final int bookId;
  final int chapter;
  final String bookName;
  final int languageId;
  final int? highlightVerse;
  // final List<Map<String, dynamic>> verses;

  const VersePage({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.bookName,
    required this.languageId,
    this.highlightVerse,
    // required this.verses,
  });

  @override
  _VersePageState createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  List<Map<String, dynamic>> verses = [];
  List<int> chapters = [];
  late int _currentChapter;
  String pageTitle = "";
  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadChapters();
    _loadVerses(_currentChapter);
  }

  void _loadChapters() async {
    final db = BibleDatabase();
    final result = await db.getChapters(widget.bookId, widget.languageId);
    if (mounted) {
      setState(() {
        chapters = result;
      });
    }
  }

  void _loadVerses(int chapter) async {
    final db = BibleDatabase();
    final result = await db.getVerses(
      widget.bookId,
      chapter,
      widget.languageId,
    );
    if (mounted) {
      setState(() {
        verses = result;
        _currentChapter = chapter;
        pageTitle = "${widget.bookName} $_currentChapter";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ListTile(
              title: Text('Chapter $chapter'),
              selected: _currentChapter == chapter,
              onTap: () {
                _loadVerses(chapter);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verse = verses[index];
          final verseNumber = verse['verse_number'];
          final verseText = verse['verse'];

          return Container(
            color:
                widget.highlightVerse == verseNumber &&
                        _currentChapter == widget.chapter
                    ? Colors.grey
                    : null,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse number
                Text(
                  '$verseNumber.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10), // Indentation
                // Verse text
                Expanded(
                  child: Text(verseText, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
