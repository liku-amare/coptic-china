import 'package:coptic_reader/catalogue/bible/bible_main_page.dart';
import 'package:coptic_reader/catalogue/daily_readings.dart';
import 'package:coptic_reader/catalogue/readings_page.dart';
import 'package:coptic_reader/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../utils/coptic_date.dart';
import '../widgets/settings.dart';
import '../database/bible_database_helper.dart';
import 'package:intl/intl.dart';

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
  }

  @override
  void initState() {
    super.initState();
    _loadVerses();
    _loadSettings();
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

  @override
  Widget build(BuildContext context) {
    // String dateString = 'Retrieved ${versesList.length} verses';
    final isWide = MediaQuery.of(context).size.width > 600;
    final List<_GridCard> gridCards = [
      _GridCard(
        title: itemName('home_read_bible'),
        icon: Icons.book,
        className: 'bible',
      ),
      _GridCard(
        title: itemName('home_listen_to_sermon'),
        icon: Icons.headphones,
        className: 'listen',
      ),
      _GridCard(
        title: itemName('home_readings'),
        icon: Icons.library_books,
        className: 'readings',
      ),
      _GridCard(
        title: itemName('home_agpeya'),
        icon: Icons.lock_clock,
        className: 'agpeya',
      ),
      // Add more items here as needed
    ];
    // print("Language1 $language1 and Language2 $language2");
    // print(
    //   "First Verse ${versesList1[0]['reading_name']} \n Second Verse ${versesList2[0]['reading_name']}",
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName('home_page')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top card
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 12.0,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DailyReadings(
                            verses1: versesList1,
                            verses2: versesList2,
                          ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getFormattedDate(
                                  locale: AppSettings.getCachedLang(),
                                ),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    itemName('home_todays_readings'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 12.0,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DailyReadings(verses: versesList),
                  //   ),
                  // );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icons.message,
                              Text(
                                itemName('home_father_message'),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "O Lord, a new morning and a new week are in Your hands…",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 6),
                              // const Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Grid cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  itemCount: gridCards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final gridCard = gridCards[index];
                    return GestureDetector(
                      onTap: () {
                        launcher(gridCard.className);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              gridCard.icon,
                              size: 40,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              gridCard.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    //
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
}

class _GridCard {
  final String title;
  final IconData icon;
  final String className;
  const _GridCard({
    required this.title,
    required this.icon,
    required this.className,
  });
}
