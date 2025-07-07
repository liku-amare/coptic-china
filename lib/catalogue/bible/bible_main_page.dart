import 'package:coptic_reader/catalogue/bible/verse_page.dart';
import 'package:flutter/material.dart';
import '../../database/bible_database_helper.dart';
import '../../widgets/settings.dart';
import '../../main.dart';

class BibleNavigatorPage extends StatefulWidget {
  const BibleNavigatorPage({super.key});

  @override
  _BibleNavigatorPageState createState() => _BibleNavigatorPageState();
}

class _BibleNavigatorPageState extends State<BibleNavigatorPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> books2 = [];
  List<int> chapters = [];
  List<Map<String, dynamic>> searchResults = [];
  TextEditingController searchController = TextEditingController();
  int currentLanguage = AppSettings.getCachedLangId();
  int language1 = 2;
  int language2 = 1;
  final Map<int, String> bible_names = {
    1: 'الكتاب المقدس',
    2: 'Bible',
    3: '聖經',
    4: '圣经',
  };

  int selectedBook = -1;
  int selectedChapter = -1;
  String selectedBookName = '';
  late TabController _tabController;
  int _currentTabIndex = 0;
  final LanguageNotifier _languageNotifier = LanguageNotifier();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
        // Reset selections when switching tabs
        selectedBook = -1;
        selectedChapter = -1;
        selectedBookName = '';
        chapters.clear();
      });
    });
    _loadSettings();
    _loadBooks();
    
    // Listen to language changes
    _languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageNotifier.removeListener(_onLanguageChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      currentLanguage = AppSettings.getCachedLangId();
    });
    _loadBooks(); // Reload books with new language
  }

  Future<void> _loadSettings() async {
    language1 = AppSettings.getLandIdFromCode(
      AppSettings.getLangCode(await AppSettings.getLanguage1()),
    );
    language2 = AppSettings.getLandIdFromCode(
      AppSettings.getLangCode(await AppSettings.getLanguage2()),
    );
  }

  void _loadBooks() async {
    final db = BibleDatabase();
    final result = await db.getBooks(languageId: language1);
    final result2 = await db.getBooks(languageId: language2);
    setState(() {
      books = result;
      books2 = result2;
    });
  }

  void _loadChapters(int bookId) async {
    final db = BibleDatabase();
    final result = await db.getChapters(bookId, language1);
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
    final result = await db.search(query, language1);
    setState(() {
      searchResults = result;
    });
  }

  List<Map<String, dynamic>> getBooksByTestament(String testament) {
    return books.where((book) => book['book_common_testament'] == testament).toList();
  }

  String getBookNameInLanguage2(int bookCommonId) {
    try {
      // Find the book in the second language list
      final book2 = books2.firstWhere(
        (book) => book['book_common_id'] == bookCommonId,
        orElse: () => {'book_name': ''},
      );
      final bookName2 = book2['book_name'] ?? '';
      
      // Only return the second language name if it's different from the first language
      // This prevents showing the same name twice
      return getTranslatedBookName(bookName2);
    } catch (e) {
      return '';
    }
  }

  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  String getTranslatedBookName(String dbBookName) {
    // Map database book names to translation keys
    final Map<String, String> bookNameMapping = {
      // English names
      'Genesis': 'bible_genesis',
      'Exodus': 'bible_exodus',
      'Leviticus': 'bible_leviticus',
      'Numbers': 'bible_numbers',
      'Deuteronomy': 'bible_deuteronomy',
      'Joshua': 'bible_joshua',
      'Judges': 'bible_judges',
      'Ruth': 'bible_ruth',
      'Samuel 1': 'bible_1_samuel',
      'Samuel 2': 'bible_2_samuel',
      'Kings 1': 'bible_1_kings',
      'Kings 2': 'bible_2_kings',
      'Chronicles 1': 'bible_1_chronicles',
      'Chronicles 2': 'bible_2_chronicles',
      'Ezra': 'bible_ezra',
      'Nehemiah': 'bible_nehemiah',
      'Tobit': 'bible_tobit',
      'Judith': 'bible_judith',
      'Esther': 'bible_esther',
      'Job': 'bible_job',
      'Psalms': 'bible_psalms',
      'Proverbs': 'bible_proverbs',
      'Ecclesiastes': 'bible_ecclesiastes',
      'Song of Songs': 'bible_song_of_songs',
      'Song of Solomon': 'bible_song_of_songs',
      'Isaiah': 'bible_isaiah',
      'Jeremiah': 'bible_jeremiah',
      'Lamentations': 'bible_lamentations',
      'Ezekiel': 'bible_ezekiel',
      'Daniel': 'bible_daniel',
      'Hosea': 'bible_hosea',
      'Joel': 'bible_joel',
      'Amos': 'bible_amos',
      'Obadiah': 'bible_obadiah',
      'Jonah': 'bible_jonah',
      'Micah': 'bible_micah',
      'Nahum': 'bible_nahum',
      'Habakkuk': 'bible_habakkuk',
      'Zephaniah': 'bible_zephaniah',
      'Haggai': 'bible_haggai',
      'Zechariah': 'bible_zechariah',
      'Malachi': 'bible_malachi',
      'Matthew': 'bible_matthew',
      'Mathew': 'bible_matthew',
      'Mark': 'bible_mark',
      'Luke': 'bible_luke',
      'John': 'bible_john',
      'John 1': 'bible_john',
      'Acts': 'bible_acts',
      'Romans': 'bible_romans',
      'Corinthians 1': 'bible_1_corinthians',
      'Corinthians 2': 'bible_2_corinthians',
      'Galatians': 'bible_galatians',
      'Ephesians': 'bible_ephesians',
      'Philippians': 'bible_philippians',
      'Colossians': 'bible_colossians',
      'Thessalonians 1': 'bible_1_thessalonians',
      'Thessalonians 2': 'bible_2_thessalonians',
      'Timothy 1': 'bible_1_timothy',
      'Timothy 2': 'bible_2_timothy',
      'Titus': 'bible_titus',
      'Philemon': 'bible_philemon',
      'Hebrews': 'bible_hebrews',
      'James': 'bible_james',
      'Peter 1': 'bible_1_peter',
      'Peter 2': 'bible_2_peter',
      'John 1': 'bible_1_john',
      'John 2': 'bible_2_john',
      'John 3': 'bible_3_john',
      'Jude': 'bible_jude',
      'Revelation': 'bible_revelation',
      
      // Arabic names
      'تكوين': 'bible_genesis',
      'خروج': 'bible_exodus',
      'لاويين': 'bible_leviticus',
      'عدد': 'bible_numbers',
      'التثنية': 'bible_deuteronomy',
      'يشوع': 'bible_joshua',
      'قضاة': 'bible_judges',
      'راعوث': 'bible_ruth',
      'صموئيل 1': 'bible_1_samuel',
      'صمؤئيل الثانى': 'bible_2_samuel',
      'ملوك 1': 'bible_1_kings',
      'ملوك 2': 'bible_2_kings',
      'اخبار 1': 'bible_1_chronicles',
      'اخبار 2': 'bible_2_chronicles',
      'عزرا': 'bible_ezra',
      'نحميا': 'bible_nehemiah',
      'سفر طوبيا': 'bible_tobit',
      'سفر يهوديت': 'bible_judith',
      'سفر استير': 'bible_esther',
      'أيوب': 'bible_job',
      'المزامير': 'bible_psalms',
      'أمثال': 'bible_proverbs',
      'الجامعة': 'bible_ecclesiastes',
      'نشيد الانشاد': 'bible_song_of_songs',
      'سفر الحكمة': 'bible_wisdom',
      'سفر يشوع بن سيراخ': 'bible_sirach',
      'إشعياء': 'bible_isaiah',
      'ارميا': 'bible_jeremiah',
      'مراثى ارميا': 'bible_lamentations',
      'سفر باروخ': 'bible_baruch',
      'سفر حزقيال': 'bible_ezekiel',
      'دانيال': 'bible_daniel',
      'هوشع': 'bible_hosea',
      'يوئيل': 'bible_joel',
      'عاموس': 'bible_amos',
      'عوبديا': 'bible_obadiah',
      'يونان': 'bible_jonah',
      'ميخا': 'bible_micah',
      'ناحوم': 'bible_nahum',
      'حبقوق': 'bible_habakkuk',
      'صفنيا': 'bible_zephaniah',
      'حجى': 'bible_haggai',
      'زكريا': 'bible_zechariah',
      'ملاخي': 'bible_malachi',
      'المكابيين 1': 'bible_1_maccabees',
      'سفر المكابيين 2': 'bible_2_maccabees',
      'صلاة منسى الملك': 'bible_prayer_of_manasseh',
      'متي': 'bible_matthew',
      'مرقص': 'bible_mark',
      'لوقا': 'bible_luke',
      'يوحنا': 'bible_john',
      'اعمال الرسل': 'bible_acts',
      'روميه': 'bible_romans',
      'كورنثوس 1': 'bible_1_corinthians',
      'كورنثوس 2': 'bible_2_corinthians',
      'غلاطية': 'bible_galatians',
      'أفسس': 'bible_ephesians',
      'فيلبي': 'bible_philippians',
      'كولوسي': 'bible_colossians',
      'تَّسَالُونِيكِيِّي ١': 'bible_1_thessalonians',
      'تسالونيكي ٢': 'bible_2_thessalonians',
      'تيموثاوس 1': 'bible_1_timothy',
      'تيموثاوس 2': 'bible_2_timothy',
      'تيطس': 'bible_titus',
      'فليمون': 'bible_philemon',
      'عبرانيين': 'bible_hebrews',
      'يعقوب': 'bible_james',
      'بطرس ١': 'bible_1_peter',
      'بطرس ٢': 'bible_2_peter',
      'يوحنا ١': 'bible_1_john',
      'يوحنا ٢': 'bible_2_john',
      'يوحنا ٣': 'bible_3_john',
      'يهوذا': 'bible_jude',
      'رؤيا': 'bible_revelation',
      
      // Chinese names (Simplified)
      '创世记': 'bible_genesis',
      '创世记第': 'bible_genesis',
      '出埃及记': 'bible_exodus',
      '出埃及记第': 'bible_exodus',
      '利未记 第': 'bible_leviticus',
      '利未记第': 'bible_leviticus',
      '民数记': 'bible_numbers',
      '民数记第': 'bible_numbers',
      '申命记': 'bible_deuteronomy',
      '申命记第': 'bible_deuteronomy',
      '约书亚记': 'bible_joshua',
      '约书亚记第': 'bible_joshua',
      '士师记': 'bible_judges',
      '士师记第': 'bible_judges',
      '路得记 第': 'bible_ruth',
      '路得记第': 'bible_ruth',
      '撒母耳记上': 'bible_1_samuel',
      '撒母耳记上第': 'bible_1_samuel',
      '撒母耳记下': 'bible_2_samuel',
      '撒母耳记下第': 'bible_2_samuel',
      '列王纪上': 'bible_1_kings',
      '列王纪上第': 'bible_1_kings',
      '列王纪下': 'bible_2_kings',
      '列王纪下第': 'bible_2_kings',
      '历代志上': 'bible_1_chronicles',
      '历代志上第': 'bible_1_chronicles',
      '历代志下': 'bible_2_chronicles',
      '历代志下第': 'bible_2_chronicles',
      '以斯拉记': 'bible_ezra',
      '以斯拉记第': 'bible_ezra',
      '尼希米记': 'bible_nehemiah',
      '尼希米记第': 'bible_nehemiah',
      '艾斯德爾傳': 'bible_esther',
      '以斯帖记第': 'bible_esther',
      '约伯记': 'bible_job',
      '约伯记第': 'bible_job',
      '诗篇': 'bible_psalms',
      '箴言': 'bible_proverbs',
      '箴言第': 'bible_proverbs',
      '传道书': 'bible_ecclesiastes',
      '传道书第': 'bible_ecclesiastes',
      '雅歌': 'bible_song_of_songs',
      '以赛亚书': 'bible_isaiah',
      '以赛亚书第': 'bible_isaiah',
      '耶利米书': 'bible_jeremiah',
      '耶利米书第': 'bible_jeremiah',
      '耶利米哀歌 第': 'bible_lamentations',
      '耶利米哀歌第': 'bible_lamentations',
      '巴路克-第一章': 'bible_baruch',
      '以西结书': 'bible_ezekiel',
      '以西结书第': 'bible_ezekiel',
      '但以理书': 'bible_daniel',
      '但以理书第': 'bible_daniel',
      '何西阿书': 'bible_hosea',
      '何西阿书第': 'bible_hosea',
      '约珥书': 'bible_joel',
      '约珥书第': 'bible_joel',
      '阿摩司书': 'bible_amos',
      '阿摩司书第': 'bible_amos',
      '俄巴底亚书': 'bible_obadiah',
      '俄巴底亚书第': 'bible_obadiah',
      '约拿书': 'bible_jonah',
      '约拿书第': 'bible_jonah',
      '弥迦书': 'bible_micah',
      '弥迦书第': 'bible_micah',
      '那鸿书': 'bible_nahum',
      '那鸿书第': 'bible_nahum',
      '哈巴谷书': 'bible_habakkuk',
      '哈巴谷书第': 'bible_habakkuk',
      '西番雅书': 'bible_zephaniah',
      '西番雅书第': 'bible_zephaniah',
      '哈该书': 'bible_haggai',
      '哈该书第': 'bible_haggai',
      '撒迦利亚书': 'bible_zechariah',
      '撒迦利亚书第': 'bible_zechariah',
      '玛拉基书': 'bible_malachi',
      '玛拉基书第': 'bible_malachi',
      '玛拿西祷词': 'bible_prayer_of_manasseh',
      '玛拿西的祷告': 'bible_prayer_of_manasseh',
      '马太福音': 'bible_matthew',
      '马太福音第': 'bible_matthew',
      '马可福音': 'bible_mark',
      '马可福音第': 'bible_mark',
      '路加福音': 'bible_luke',
      '路加福音第': 'bible_luke',
      '约翰福音': 'bible_john',
      '约翰福音第': 'bible_john',
      '使徒行传': 'bible_acts',
      '使徒行传第': 'bible_acts',
      '罗马书': 'bible_romans',
      '罗马书第': 'bible_romans',
      '哥林多前书 1': 'bible_1_corinthians',
      '哥林多前书第': 'bible_1_corinthians',
      '哥林多后书': 'bible_2_corinthians',
      '哥林多后书第': 'bible_2_corinthians',
      '加拉太书': 'bible_galatians',
      '加拉太书第': 'bible_galatians',
      '以弗所书': 'bible_ephesians',
      '以弗所书第': 'bible_ephesians',
      '腓立比书': 'bible_philippians',
      '腓立比书第': 'bible_philippians',
      '歌罗西书': 'bible_colossians',
      '歌罗西书第': 'bible_colossians',
      '帖撒罗尼迦前书 1': 'bible_1_thessalonians',
      '帖撒罗尼迦前书第': 'bible_1_thessalonians',
      '帖撒罗尼迦后书 2': 'bible_2_thessalonians',
      '帖撒罗尼迦后书第': 'bible_2_thessalonians',
      '提摩太前书': 'bible_1_timothy',
      '提摩太前书第': 'bible_1_timothy',
      '提摩太后书': 'bible_2_timothy',
      '提摩太后书第': 'bible_2_timothy',
      '提多书': 'bible_titus',
      '提多书第': 'bible_titus',
      '腓利门书': 'bible_philemon',
      '腓利门书第': 'bible_philemon',
      '希伯来书': 'bible_hebrews',
      '希伯来书第': 'bible_hebrews',
      '雅各书': 'bible_james',
      '雅各书第': 'bible_james',
      '彼得前書': 'bible_1_peter',
      '彼得前书第': 'bible_1_peter',
      '彼得後書': 'bible_2_peter',
      '彼得后书第': 'bible_2_peter',
      '约翰一书 1': 'bible_1_john',
      '约翰一书第': 'bible_1_john',
      '约翰二书 2': 'bible_2_john',
      '约翰二书第': 'bible_2_john',
      '约翰三书 3': 'bible_3_john',
      '约翰三书第': 'bible_3_john',
      '犹大书': 'bible_jude',
      '犹大书第': 'bible_jude',
      '启示录': 'bible_revelation',
      '启示录第': 'bible_revelation',
      
      // Additional books
      'Wisdom of Solomon': 'bible_wisdom',
      'Sirach': 'bible_sirach',
      'Baruch': 'bible_baruch',
      'Maccabees 1': 'bible_1_maccabees',
      'Maccabees 2': 'bible_2_maccabees',
      'Prayer of Manasseh': 'bible_prayer_of_manasseh',
    };

    final translationKey = bookNameMapping[dbBookName];
    if (translationKey != null) {
      return itemName(translationKey);
    }
    
    // If no mapping found, return the original name
    return dbBookName;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> testament = [
      {'ot': itemName('bible_old_testament'), 'nt': itemName('bible_new_testament')},
      {'ot': itemName('bible_old_testament'), 'nt': itemName('bible_new_testament')},
      {'ot': itemName('bible_old_testament'), 'nt': itemName('bible_new_testament')},
      {'ot': itemName('bible_old_testament'), 'nt': itemName('bible_new_testament')},
    ];

    final oldTestamentBooks = getBooksByTestament('ot');
    final newTestamentBooks = getBooksByTestament('nt');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(bible_names[currentLanguage] ?? 'Bible'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: [
            Tab(
              text: testament[currentLanguage - 1]['ot'] ?? 'Old Testament',
              icon: const Icon(Icons.auto_stories),
            ),
            Tab(
              text: testament[currentLanguage - 1]['nt'] ?? 'New Testament',
              icon: const Icon(Icons.auto_stories),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
                          child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: itemName('bible_search_hint'),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _search,
            ),
          ),

          // Content
          Expanded(
            child: searchController.text.isNotEmpty
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTestamentView(oldTestamentBooks, testament[currentLanguage - 1]['ot'] ?? 'Old Testament'),
                      _buildTestamentView(newTestamentBooks, testament[currentLanguage - 1]['nt'] ?? 'New Testament'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                '${getTranslatedBookName(result['book_name'])} ${result['verse_chapter']}:${result['verse_number']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                result['verse'],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VersePage(
                      bookId: result['book_common_id'],
                      chapter: result['verse_chapter'],
                      bookName: getTranslatedBookName(result['book_name']),
                      languageId: currentLanguage,
                      highlightVerse: result['verse_number'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestamentView(List<Map<String, dynamic>> testamentBooks, String testamentName) {
    return Row(
      children: [
        // Book List
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          testamentName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Books List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: testamentBooks.length,
                    itemBuilder: (context, index) {
                      final book = testamentBooks[index];
                      final bookId = book['id'];
                      final isSelected = selectedBook == bookId;
                      final bookName2 = getBookNameInLanguage2(bookId);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: isSelected ? 4 : 1,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslatedBookName(book['book_name']),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (bookName2.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  bookName2,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            _loadChapters(bookId);
                            setState(() {
                              selectedBook = bookId;
                              selectedBookName = getTranslatedBookName(book['book_name']);
                              selectedChapter = -1;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Chapter List
        if (selectedBook != -1)
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Container(
                margin: const EdgeInsets.only(left: 8, right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.list,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              itemName('bible_chapters'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chapters List - Now scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: chapters.length,
                              itemBuilder: (context, index) {
                                final chapter = index + 1;
                                final isSelected = selectedChapter == chapter;
                                
                                return Card(
                                  elevation: isSelected ? 4 : 1,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                                      : Theme.of(context).colorScheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isSelected
                                        ? BorderSide(
                                            color: Theme.of(context).colorScheme.secondary,
                                            width: 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setState(() {
                                        selectedChapter = chapter;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VersePage(
                                            bookId: selectedBook,
                                            chapter: chapter,
                                            bookName: selectedBookName,
                                            languageId: currentLanguage,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: Text(
                                        '$chapter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
