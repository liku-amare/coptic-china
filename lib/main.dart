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

class CopticReaderApp extends StatelessWidget {
  const CopticReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coptic Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int startIndex;
  const MainScreen({super.key, this.startIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
