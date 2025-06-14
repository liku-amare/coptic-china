import 'package:coptic_reader/catalogue/bible/verse_page.dart';
import 'package:flutter/material.dart';
import '../../database/bible_database_helper.dart';
import '../../widgets/settings.dart';

class BibleNavigatorPage extends StatefulWidget {
  const BibleNavigatorPage({super.key});

  @override
  _BibleNavigatorPageState createState() => _BibleNavigatorPageState();
}

class _BibleNavigatorPageState extends State<BibleNavigatorPage> {
  List<Map<String, dynamic>> books = [];
  List<int> chapters = [];
  List<Map<String, dynamic>> searchResults = [];
  TextEditingController searchController = TextEditingController();
  int currentLanguage = AppSettings.getCachedLangId();
  final Map<int, String> bible_names = {
    1: 'الكتاب المقدس',
    2: 'Bible',
    3: '聖經',
    4: '圣经',
  };

  int selectedBook = -1;
  int selectedChapter = -1;
  String selectedBookName = '';

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

  void _loadChapters(int bookId) async {
    final db = BibleDatabase();
    final result = await db.getChapters(bookId, currentLanguage);
    setState(() {
      chapters = result;
    });
  }

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    final db = BibleDatabase();
    final result = await db.search(query, currentLanguage);
    setState(() {
      searchResults = result;
    });
  }

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
        title: Text(bible_names[currentLanguage] ?? 'Bible'),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _search('');
                  },
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child:
                searchController.text.isNotEmpty
                    ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          title: Text(
                            '${result['book_name']} ${result['verse_chapter']}:${result['verse_number']}',
                          ),
                          subtitle: Text(result['verse']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VersePage(
                                      bookId: result['book_common_id'],
                                      chapter: result['verse_chapter'],
                                      bookName: result['book_name'],
                                      languageId: currentLanguage,
                                      highlightVerse: result['verse_number'],
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    )
                    : Row(
                      children: [
                        // Book List
                        _buildColumn(
                          children:
                              books.map((book) {
                                final index = book['id'];
                                final isSelected = selectedBook == index;
                                return _buildTile(
                                  label: book['book_name'],
                                  sublabel:
                                      testament[currentLanguage -
                                          1][book['book_common_testament']] ??
                                      'Testament',
                                  isSelected: isSelected,
                                  onTap: () {
                                    _loadChapters(index);
                                    setState(() {
                                      selectedBook = index;
                                      selectedBookName = book['book_name'];
                                      selectedChapter = -1; // Reset chapter
                                    });
                                  },
                                );
                              }).toList(),
                        ),

                        // Chapter List
                        if (selectedBook != -1)
                          _buildColumn(
                            children: List.generate(chapters.length, (index) {
                              final chapter = index + 1;
                              final isSelected = selectedChapter == chapter;
                              return _buildTile(
                                label: '$chapter',
                                sublabel: 'none',
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    selectedChapter = chapter;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => VersePage(
                                              bookId: selectedBook,
                                              chapter: chapter,
                                              bookName: selectedBookName,
                                              languageId: currentLanguage,
                                            ),
                                      ),
                                    );
                                  });
                                },
                              );
                            }),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // Builds a single scrollable column with title and children
  Widget _buildColumn({required List<Widget> children}) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView(padding: EdgeInsets.all(8), children: children),
          ),
        ],
      ),
    );
  }

  /// Builds a decorated list item
  Widget _buildTile({
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (sublabel == 'none') {
      return Card(
        elevation: isSelected ? 6 : 2,
        color: isSelected ? Colors.deepPurple.shade200 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSelected
                  ? BorderSide(color: Colors.deepPurple.shade700, width: 1.5)
                  : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    } else {
      return Card(
        elevation: isSelected ? 6 : 2,
        color: isSelected ? Colors.deepPurple.shade200 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSelected
                  ? BorderSide(color: Colors.deepPurple.shade700, width: 1.5)
                  : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: ListTile(
              title: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                sublabel == 'none' ? '' : sublabel,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
