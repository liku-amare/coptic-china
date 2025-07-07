import 'package:coptic_reader/database/bible_database_helper.dart';
import 'package:coptic_reader/widgets/settings.dart';
import 'package:coptic_reader/widgets/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  List<Map<String, dynamic>> verses2 = []; // Second language verses
  List<int> chapters = [];
  late int _currentChapter;
  String pageTitle = "";
  int secondaryLanguageId = 2; // Will be set from settings
  Set<int> selectedVerses = {}; // Track selected verses
  bool isSelectionMode = false; // Track if we're in selection mode
  bool showNavigationButtons = false; // Track if navigation buttons should be visible
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadSettings();
    _loadChapters();
    _loadVerses(_currentChapter);
    
    // Add scroll listener to show/hide navigation buttons
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButtons = _scrollController.offset > 100;
    if (showButtons != showNavigationButtons) {
      setState(() {
        showNavigationButtons = showButtons;
      });
    }
  }

  Future<void> _loadSettings() async {
    // Get the secondary language from user settings
    final language2Name = await AppSettings.getLanguage2();
    secondaryLanguageId = AppSettings.getLandIdFromCode(
      AppSettings.getLangCode(language2Name),
    );
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
    
    // Load verses for primary language
    final result = await db.getVerses(
      widget.bookId,
      chapter,
      widget.languageId,
    );
    
    // Load verses for secondary language
    final result2 = await db.getVerses(
      widget.bookId,
      chapter,
      secondaryLanguageId,
    );
    
    // Get book name in secondary language
    final bookName2 = await _getBookNameInLanguage2(widget.bookId);
    
    if (mounted) {
      setState(() {
        verses = result;
        verses2 = result2;
        _currentChapter = chapter;
        pageTitle = bookName2.isNotEmpty 
            ? "${widget.bookName} $bookName2 $_currentChapter"
            : "${widget.bookName} $_currentChapter";
      });
    }
  }

  Future<String> _getBookNameInLanguage2(int bookCommonId) async {
    final db = BibleDatabase();
    final books = await db.getBooks(languageId: secondaryLanguageId);
    final book2 = books.firstWhere(
      (book) => book['book_common_id'] == bookCommonId,
      orElse: () => {'book_name': ''},
    );
    return book2['book_name'] ?? '';
  }

  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: selectedVerses.isNotEmpty ? _copySelectedVerses : null,
              tooltip: 'Copy selected verses',
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAllVerses,
              tooltip: 'Select all verses',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode,
              tooltip: 'Exit selection mode',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _enterSelectionMode,
              tooltip: 'Select verses',
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ListTile(
              title: Text('${itemName('bible_chapters')} $chapter'),
              selected: _currentChapter == chapter,
              onTap: () {
                _loadVerses(chapter);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                final verseNumber = verse['verse_number'];
                final verseText = verse['verse'];
                
                // Get corresponding verse from second language
                final verse2 = index < verses2.length ? verses2[index] : null;
                final verseText2 = verse2?['verse'] ?? '';

                final isSelected = selectedVerses.contains(verseNumber);
                final isHighlighted = widget.highlightVerse == verseNumber &&
                    _currentChapter == widget.chapter;
                
                return Container(
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      if (isSelectionMode) {
                        _toggleVerseSelection(verseNumber);
                      } else {
                        _enterSelectionMode();
                        _toggleVerseSelection(verseNumber);
                      }
                    },
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleVerseSelection(verseNumber);
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selection indicator
                        if (isSelectionMode)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: 16,
                                  )
                                : null,
                          ),
                        // Verse number
                        Container(
                          width: 40,
                          child: Text(
                            '$verseNumber.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Primary language verse text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verseText,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (verseText2.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    verseText2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Navigation buttons overlay
          if (showNavigationButtons)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Chapter Button
                  if (_currentChapter > 1)
                    _buildNavigationButton(
                      icon: Icons.arrow_back_ios,
                      label: itemName('bible_previous'),
                      onTap: () => _navigateToChapter(_currentChapter - 1),
                    ),
                  // Spacer for more space between buttons
                  if (_currentChapter > 1 && _currentChapter < chapters.length)
                    const SizedBox(width: 40),
                  // Next Chapter Button
                  if (_currentChapter < chapters.length)
                    _buildNavigationButton(
                      icon: Icons.arrow_forward_ios,
                      label: itemName('bible_next'),
                      onTap: () => _navigateToChapter(_currentChapter + 1),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Selection mode methods
  void _enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
      selectedVerses.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedVerses.clear();
    });
  }

  void _toggleVerseSelection(int verseNumber) {
    setState(() {
      if (selectedVerses.contains(verseNumber)) {
        selectedVerses.remove(verseNumber);
      } else {
        selectedVerses.add(verseNumber);
      }
    });
  }

  void _selectAllVerses() {
    setState(() {
      selectedVerses.clear();
      for (var verse in verses) {
        selectedVerses.add(verse['verse_number']);
      }
    });
  }

  void _copySelectedVerses() async {
    if (selectedVerses.isEmpty) return;

    final sortedVerses = selectedVerses.toList()..sort();
    final StringBuffer buffer = StringBuffer();
    
    // Get book name in secondary language for copy
    final bookName2 = await _getBookNameInLanguage2(widget.bookId);
    final bookTitle = bookName2.isNotEmpty 
        ? '${widget.bookName} $bookName2 ${widget.chapter}'
        : '${widget.bookName} ${widget.chapter}';
    
    buffer.writeln(bookTitle);
    buffer.writeln('');

    for (int verseNumber in sortedVerses) {
      final verseIndex = verses.indexWhere((v) => v['verse_number'] == verseNumber);
      if (verseIndex != -1) {
        final verse = verses[verseIndex];
        final verse2 = verseIndex < verses2.length ? verses2[verseIndex] : null;
        
        buffer.writeln('${verseNumber}. ${verse['verse']}');
        if (verse2 != null && verse2['verse'].isNotEmpty) {
          buffer.writeln('   ${verse2['verse']}');
        }
        buffer.writeln('');
      }
    }

    final textToCopy = buffer.toString().trim();
    
    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: textToCopy));
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedVerses.length} ${itemName('auth_verses_copied')}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Navigation methods
  void _navigateToChapter(int chapter) {
    if (chapter >= 1 && chapter <= chapters.length) {
      _loadVerses(chapter);
      // Scroll to top when navigating to new chapter
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
