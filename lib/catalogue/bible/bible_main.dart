import 'package:flutter/material.dart';
import '../../database/bible_database_helper.dart';
import '../../catalogue/bible/chapter_page.dart';
import '../../widgets/settings.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  List<Map<String, dynamic>> books = [];
  int currentLanguage = AppSettings.getCachedLangId();
  Map<int, String> bible_names = {
    1: 'الكتاب المقدس',
    2: 'Bible',
    3: '聖經',
    4: '圣经',
  };
  // final languageId = 2;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() async {
    final db = BibleDatabase();
    final result = await db.getBooks(languageId: currentLanguage); // English
    setState(() {
      books = result;
    });
  }

  // void _switchLanguage(int lang) {
  //   setState(() {
  //     currentLanguage = lang;
  //     _loadBooks();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> testament = [
      {'ot': 'العهد القديم', 'nt': 'العهد الجديد'},
      {'ot': 'Old Testament', 'nt': 'New Testament'},
      {'ot': '舊約', 'nt': '新約'},
      {'ot': '旧约', 'nt': '新约'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(bible_names[currentLanguage] ?? "Bible"),
        // actions: [
        //   PopupMenuButton<int>(
        //     onSelected: _switchLanguage,
        //     itemBuilder:
        //         (context) => [
        //           PopupMenuItem(value: 2, child: Text('English')),
        //           PopupMenuItem(value: 4, child: Text('中文简体')),
        //           PopupMenuItem(value: 3, child: Text('中文繁體')),
        //           PopupMenuItem(value: 1, child: Text('العربية')),
        //         ],
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(book['book_name'], style: TextStyle(fontSize: 18)),
                subtitle: Text(
                  testament[currentLanguage -
                          1][book['book_common_testament']] ??
                      'Old',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChapterPage(
                            bookId: index + 1,
                            languageId: currentLanguage,
                            bookName: book['book_name'],
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
