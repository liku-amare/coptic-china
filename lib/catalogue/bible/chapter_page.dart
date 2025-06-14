import 'package:flutter/material.dart';
import '../../database/bible_database_helper.dart';
import '../../catalogue/bible/verse_page.dart';

class ChapterPage extends StatefulWidget {
  final int bookId;
  final int languageId;
  final String bookName;
  final int? highlightChapter;
  const ChapterPage({
    super.key,
    required this.bookId,
    required this.languageId,
    required this.bookName,
    this.highlightChapter,
  });

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  List<int> chapters = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadChapters();
  }

  void _loadChapters() async {
    final db = BibleDatabase();
    final result = await db.getChapters(widget.bookId, widget.languageId);
    setState(() {
      chapters = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookName)),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            title: Text(chapter.toString()),
            tileColor:
                widget.highlightChapter == chapter ? Colors.yellow : null,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (context) => VersePage(
              //           bookId: widget.bookId,
              //           chapter: index + 1,
              //           bookName: widget.bookName,
              //           languageId: widget.languageId,
              //         ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}
