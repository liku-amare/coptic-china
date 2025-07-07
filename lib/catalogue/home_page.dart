import 'package:coptic_reader/catalogue/bible/bible_main_page.dart';
import 'package:coptic_reader/catalogue/daily_readings.dart';
import 'package:coptic_reader/catalogue/readings_page.dart';
import 'package:coptic_reader/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'father_message_page.dart';
import '../utils/coptic_date.dart';
import '../widgets/settings.dart';
import '../database/bible_database_helper.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> currentDate = getCopticDate();
  List<Map<String, dynamic>> versesList1 = [];
  List<Map<String, dynamic>> versesList2 = [];
  int currentLanguage = AppSettings.getCachedLangId();
  int language1 = 2;
  int language2 = 1;
  ThemeMode _currentThemeMode = ThemeMode.system;
  String _defaultLanguage = AppSettings.getCachedLang();
  final LanguageNotifier _languageNotifier = LanguageNotifier();

  String getFormattedDate({String locale = 'en'}) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, y', locale);
    return formatter.format(now);
  }

  Future<void> _loadSettings() async {
    language1 = AppSettings.getLandIdFromCode(
      AppSettings.getLangCode(await AppSettings.getLanguage1()),
    );
    language2 = AppSettings.getLandIdFromCode(
      AppSettings.getLangCode(await AppSettings.getLanguage2()),
    );
    _currentThemeMode = await AppSettings.getThemeMode();
    _defaultLanguage = await AppSettings.getDefaultLanguage();
  }

  @override
  void initState() {
    super.initState();
    _loadVerses();
    _loadSettings();
    
    // Listen to language changes
    _languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      currentLanguage = AppSettings.getCachedLangId();
      _defaultLanguage = AppSettings.getCachedLang();
    });
    _loadVerses(); // Reload verses with new language
  }

  void _loadVerses() async {
    final db = BibleDatabase();
    final result = await db.getDailyReadings(
      currentDate[1],
      currentDate[2],
      language1,
    );
    setState(() {
      versesList1 = result;
    });

    final result2 = await db.getDailyReadings(
      currentDate[1],
      currentDate[2],
      language2,
    );
    setState(() {
      versesList2 = result2;
    });
  }

  void _toggleTheme() async {
    ThemeMode newMode;
    switch (_currentThemeMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        // If currently on system, switch to light
        newMode = ThemeMode.light;
        break;
    }
    
    await AppSettings.setThemeMode(newMode);
    setState(() {
      _currentThemeMode = newMode;
    });
    
    // Use global theme notifier to update theme
    final themeNotifier = ThemeNotifier();
    themeNotifier.updateTheme(newMode);
  }

  void _showLanguageDropdown() {
    final List<String> availableLanguages = ['English', 'العربية', '中文（繁體）', '中文（简体）', 'Coptic'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(itemName('sett_language_settings')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableLanguages.map((language) {
              return ListTile(
                title: Text(language),
                leading: _getLanguageIconForLanguage(language),
                selected: _defaultLanguage == language,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _changeLanguage(language);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(String newLanguage) async {
    setState(() {
      _defaultLanguage = newLanguage;
    });
    
    await AppSettings.setDefaultLanguage(newLanguage);
    final languageCode = AppSettings.getLangCode(newLanguage);
    final languageNotifier = LanguageNotifier();
    languageNotifier.updateLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final List<_GridCard> gridCards = [
      _GridCard(
        title: itemName('home_read_bible'),
        icon: Icons.auto_stories,
        className: 'bible',
        gradient: const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GridCard(
        title: itemName('home_listen_to_sermon'),
        icon: Icons.headphones,
        className: 'listen',
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GridCard(
        title: itemName('home_readings'),
        icon: Icons.library_books,
        className: 'readings',
        gradient: const LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF6495ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GridCard(
        title: itemName('home_agpeya'),
        icon: Icons.schedule,
        className: 'agpeya',
        gradient: const LinearGradient(
          colors: [Color(0xFF8A2BE2), Color(0xFF9370DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                // Language Dropdown Button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: _showLanguageDropdown,
                    icon: _getLanguageIcon(),
                    tooltip: itemName('sett_language_settings'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                // Theme Toggle Button
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: _toggleTheme,
                    icon: _getThemeIcon(),
                    tooltip: _getThemeTooltip(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  itemName('home_page'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.church,
                      size: 60,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getFormattedDate(
                                  locale: AppSettings.getCachedLang(),
                                ),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Blessed be the Lord our God',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'May His grace and peace be with you always',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Readings Card
                    _buildDailyReadingsCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Father's Message Card
                    _buildFatherMessageCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Section Title
                    Text(
                      'Sacred Services',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Grid Cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridCards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final gridCard = gridCards[index];
                        return _buildGridCard(gridCard);
                      },
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          tooltip: itemName('home_chat_with_church'),
          child: const Icon(
            Icons.chat_bubble_rounded,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyReadingsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DailyReadings(
                  verses1: versesList1,
                  verses2: versesList2,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName('home_todays_readings'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${versesList1.length} readings available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFatherMessageCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FatherMessagePage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.message,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName('home_father_message'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "O Lord, a new morning and a new week are in Your hands…",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(_GridCard gridCard) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            launcher(gridCard.className);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: gridCard.gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    gridCard.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  gridCard.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void launcher(String className) {
    switch (className) {
      case 'bible':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BibleNavigatorPage()),
        );
        break;
      case 'listen':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListenPage()),
        );
        break;
      case 'readings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReadingsPage('readings')),
        );
        break;
      case 'agpeya':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReadingsPage('agpeya')),
        );
        break;
    }
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }

  Icon _getThemeIcon() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return const Icon(Icons.brightness_7, color: Colors.white);
      case ThemeMode.dark:
        return const Icon(Icons.brightness_4, color: Colors.white);
      case ThemeMode.system:
        // Show sun icon for system mode (treat as light)
        return const Icon(Icons.brightness_7, color: Colors.white);
    }
  }

  String _getThemeTooltip() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Switch to Dark Mode';
      case ThemeMode.dark:
        return 'Switch to Light Mode';
      case ThemeMode.system:
        return 'Switch to Light Mode';
    }
    throw Exception("Invalid ThemeMode");
  }

  Icon _getLanguageIcon() {
    return _getLanguageIconForLanguage(_defaultLanguage);
  }

  Icon _getLanguageIconForLanguage(String language) {
    switch (language) {
      case 'English':
        return const Icon(Icons.language);
      case 'العربية':
        return const Icon(Icons.translate);
      case '中文（繁體）':
        return const Icon(Icons.language);
      case '中文（简体）':
        return const Icon(Icons.translate);
      case 'Coptic':
        return const Icon(Icons.church);
      default:
        return const Icon(Icons.language);
    }
  }
}

class _GridCard {
  final String title;
  final IconData icon;
  final String className;
  final LinearGradient gradient;
  
  const _GridCard({
    required this.title,
    required this.icon,
    required this.className,
    required this.gradient,
  });
}
