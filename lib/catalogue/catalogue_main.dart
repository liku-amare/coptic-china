import 'package:flutter/material.dart';
import 'readings_page.dart';
import '../widgets/settings.dart';
import '../main.dart';
// for MainScreenWithIndex

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final List<String> catalogueCodes = [
    'agpeya',
    'psalmody',
    'liturgies',
    'melodies',
    'clergy',
    'readings',
    'index',
    'special',
  ];
  
  final LanguageNotifier _languageNotifier = LanguageNotifier();

  @override
  void initState() {
    super.initState();
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
      // Force rebuild when language changes
    });
  }

  @override
  Widget build(BuildContext context) {
    List<_CatalogueItem> items = [
      _CatalogueItem(
        itemName('cat_agpeya'),
        Icons.schedule,
        const LinearGradient(
          colors: [Color(0xFF8A2BE2), Color(0xFF9370DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_psalmody'),
        Icons.music_note,
        const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_liturgies'),
        Icons.church,
        const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_melodies'),
        Icons.audiotrack,
        const LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF6495ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_clergy'),
        Icons.people,
        const LinearGradient(
          colors: [Color(0xFFDC143C), Color(0xFFFF6347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_readings'),
        Icons.menu_book,
        const LinearGradient(
          colors: [Color(0xFF228B22), Color(0xFF32CD32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_index'),
        Icons.list,
        const LinearGradient(
          colors: [Color(0xFF696969), Color(0xFF808080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _CatalogueItem(
        itemName('cat_special'),
        Icons.star,
        const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(itemName('catalogue_page')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.library_books,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sacred Library',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore the rich collection of Orthodox texts, prayers, and liturgical resources',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid Section
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                return _buildCatalogueCard(context, items[index], catalogueCodes[index]);
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogueCard(BuildContext context, _CatalogueItem item, String code) {
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
                builder: (context) => ReadingsPage(code),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: item.gradient,
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
                    item.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}

class _CatalogueItem {
  final String title;
  final IconData icon;
  final LinearGradient gradient;

  _CatalogueItem(this.title, this.icon, this.gradient);
}
