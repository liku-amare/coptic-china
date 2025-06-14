import 'package:flutter/material.dart';
import 'readings_page.dart';
import '../widgets/settings.dart';
// for MainScreenWithIndex

class CataloguePage extends StatelessWidget {
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

  CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<_CatalogueItem> items = [
      _CatalogueItem(itemName('cat_agpeya'), Icons.access_time),
      _CatalogueItem(itemName('cat_psalmody'), Icons.music_note),
      _CatalogueItem(itemName('cat_liturgies'), Icons.church),
      _CatalogueItem(itemName('cat_melodies'), Icons.audiotrack),
      _CatalogueItem(itemName('cat_clergy'), Icons.people),
      _CatalogueItem(itemName('cat_readings'), Icons.menu_book),
      _CatalogueItem(itemName('cat_index'), Icons.list),
      _CatalogueItem(itemName('cat_special'), Icons.star),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName('catalogue_page')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      // appBar: AppBar(title: Text(itemName('catalogue_page'))),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingsPage(catalogueCodes[index]),
                  ),
                );
                // TODO: Add navigation for other items
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[index].icon, size: 40, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(items[index].title, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
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

  _CatalogueItem(this.title, this.icon);
}
