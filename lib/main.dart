import 'package:coptic_reader/catalogue/bible/bible_main_page.dart';
import 'package:flutter/material.dart';
import 'catalogue/catalogue_main.dart';
import 'catalogue/account_page.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/settings.dart';
import 'catalogue/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplify/amplifyconfiguration.dart';

// Global theme notifier
class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void updateTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// Global language notifier
class LanguageNotifier extends ChangeNotifier {
  static final LanguageNotifier _instance = LanguageNotifier._internal();
  factory LanguageNotifier() => _instance;
  LanguageNotifier._internal();

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  void updateLanguage(String language) {
    _currentLanguage = language;
    AppSettings.updateCachedLanguage(language); // Update cached language
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.initSettings();

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('zh_Hans', null);
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('zh_Hant', null);

  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugins([auth]);
    await Amplify.configure(amplifyconfig);
    print('Amplify configured');
  } catch (e) {
    print('Error configuring Amplify: $e');
  }

  // runApp(Phoenix(child: CopticReaderApp()));
  runApp(CopticReaderApp());
}

class CopticReaderApp extends StatefulWidget {
  const CopticReaderApp({super.key});

  @override
  State<CopticReaderApp> createState() => _CopticReaderAppState();
}

class _CopticReaderAppState extends State<CopticReaderApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  final LanguageNotifier _languageNotifier = LanguageNotifier();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await AppSettings.getThemeMode();
    _themeNotifier.updateTheme(themeMode);
    
    final defaultLanguage = await AppSettings.getDefaultLanguage();
    final languageCode = AppSettings.getLangCode(defaultLanguage);
    _languageNotifier.updateLanguage(languageCode);
  }

  void _updateThemeMode(ThemeMode mode) async {
    await AppSettings.setThemeMode(mode);
    _themeNotifier.updateTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeNotifier, _languageNotifier]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coptic Reader',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: _themeNotifier.themeMode,
          home: MainScreen(
            onThemeChanged: _updateThemeMode,
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B4513), // Orthodox brown
        brightness: Brightness.light,
        primary: const Color(0xFF8B4513),
        secondary: const Color(0xFFD2691E),
        tertiary: const Color(0xFFCD853F),
        surface: const Color(0xFFFDF5E6),
        background: const Color(0xFFFAF0E6),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF2F2F2F),
        onBackground: const Color(0xFF2F2F2F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2F2F2F),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F2F2F),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F2F2F),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2F2F2F),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF2F2F2F),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF2F2F2F),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF8B4513),
        size: 24,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD2691E), // Orthodox orange
        brightness: Brightness.dark,
        primary: const Color(0xFFD2691E),
        secondary: const Color(0xFFFF8C42),
        tertiary: const Color(0xFFFFA07A),
        surface: const Color(0xFF2D2D2D),
        background: const Color(0xFF1A1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2D2D2D),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2691E),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFD2691E),
        size: 24,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int startIndex;
  final Function(ThemeMode)? onThemeChanged;
  
  const MainScreen({super.key, this.startIndex = 0, this.onThemeChanged});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomePage(),
    // BiblePage(),
    BibleNavigatorPage(),
    CataloguePage(),
    ListenPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Allows external navigation to MainScreen with a specified tab index
class MainScreenWithIndex extends StatelessWidget {
  final int index;

  const MainScreenWithIndex(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return MainScreen(startIndex: index);
  }
}
