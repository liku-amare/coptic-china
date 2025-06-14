import 'package:flutter/material.dart';
import '../widgets/settings.dart';

class DailyReadings extends StatefulWidget {
  final List<Map<String, dynamic>> verses1;
  final List<Map<String, dynamic>> verses2;
  final String initialLanguage = AppSettings.getCachedLang();

  DailyReadings({super.key, required this.verses1, required this.verses2});

  @override
  _DailyReadingsState createState() => _DailyReadingsState();
}

class _DailyReadingsState extends State<DailyReadings> {
  List<String> sectionTitles = [];
  Map<String, Map<String, List>> versesMapped1 = {};
  Map<String, Map<String, List>> versesMapped2 = {};
  String language1 = 'en';
  String language2 = 'ar';
  String currentSection = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    language1 = AppSettings.getLangCode(await AppSettings.getLanguage1());
    language2 = AppSettings.getLangCode(await AppSettings.getLanguage2());
    _loadSectionTitles();
  }

  void _loadSectionTitles() {
    final versesP1 = widget.verses1;
    for (int i = 0; i < versesP1.length; i++) {
      // Language 1
      final String readingName1 = toCamelCase(versesP1[i]['reading_name']);
      final String bookName1 = versesP1[i]['book_name'];
      final int chapter1 = versesP1[i]['verse_chapter'];
      final int verseNo1 = versesP1[i]['verse_number'];
      final String verse1 = versesP1[i]['verse'];
      String bookChap1 = '$bookName1-$chapter1';
      String verseNoverse1 = '$verseNo1 $verse1';

      if (versesMapped1.containsKey(readingName1)) {
        if (versesMapped1[readingName1]!.containsKey(bookChap1)) {
          versesMapped1[readingName1]![bookChap1]!.add(verseNoverse1);
        } else {
          versesMapped1[readingName1]![bookChap1] = [verseNoverse1];
        }
      } else {
        versesMapped1[readingName1] = {
          bookChap1: [verseNoverse1],
        };
      }

      // Language 2
      if (i < widget.verses2.length) {
        final versesP2 = widget.verses2;
        final String bookName2 = versesP2[i]['book_name'];
        final int chapter2 = versesP2[i]['verse_chapter'];
        final int verseNo2 = versesP2[i]['verse_number'];
        final String verse2 = versesP2[i]['verse'];
        String bookChap2 = '$bookName2-$chapter2';
        String verseNoverse2 = '$verseNo2 $verse2';

        if (versesMapped2.containsKey(readingName1)) {
          if (versesMapped2[readingName1]!.containsKey(bookChap2)) {
            versesMapped2[readingName1]![bookChap2]!.add(verseNoverse2);
          } else {
            versesMapped2[readingName1]![bookChap2] = [verseNoverse2];
          }
        } else {
          versesMapped2[readingName1] = {
            bookChap2: [verseNoverse2],
          };
        }
      }
    }
    setState(() {
      sectionTitles = versesMapped1.keys.toList();
      if (sectionTitles.isNotEmpty) {
        currentSection = sectionTitles.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (sectionTitles.isEmpty) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text("Daily Readings")),
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    final filteredVerses1 = versesMapped1[currentSection];
    final filteredVerses2 = versesMapped2[currentSection];
    print("Filtered length 1: ${widget.verses1[0]['book_name']}");
    print("Filtered length 2: ${widget.verses2[0]['book_name']}");

    return Scaffold(
      appBar: AppBar(title: Text(currentSection)),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: kToolbarHeight * 1.5,
              color: Colors.deepPurple,
              alignment: Alignment.center,
              child: Text(
                itemName('reader_page_sections_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sectionTitles.length,
                itemBuilder: (context, index) {
                  final chapter = sectionTitles[index];
                  return ListTile(
                    title: Text(chapter),
                    selected: chapter == currentSection,
                    onTap: () {
                      setState(() {
                        currentSection = chapter;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children:
              (filteredVerses1 ?? {}).entries.map((entry1) {
                final key1 = entry1.key;
                final keyIndex = filteredVerses1!.keys.toList().indexOf(key1);
                final key2 = filteredVerses2!.keys.toList()[keyIndex];
                final verses1 = entry1.value;
                final verses2 = filteredVerses2[key2];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key1,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...verses1.map(
                                (item) => Text(
                                  item,
                                  textAlign: TextAlign.left,
                                  textDirection:
                                      language2 == 'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                key2,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...verses2!.map(
                                (item) => Text(
                                  item,
                                  textDirection:
                                      language2 == 'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),

      // ListView.builder(
      //   itemCount: filteredVerses!.values
      //       .map((list) => list.length)
      //       .fold(0, (sum, length) => sum! + length),
      //   // itemCount: filteredVerses.length,
      //   itemBuilder: (context, index) {
      //     final verse = filteredVerses[index];
      //     final text = verse['prayer'] ?? '';

      //     return Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           if (speaker != null)
      //             Text(
      //               speaker,
      //               style: TextStyle(
      //                 color: Colors.blueAccent,
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 16,
      //               ),
      //             ),
      //           Text(
      //             speaker != null
      //                 ? (currentLanguage == 'zh_hans' ||
      //                         currentLanguage == 'zh_hant')
      //                     ? text.replaceFirst('$speaker：', '').trim()
      //                     : text.replaceFirst('$speaker:', '').trim()
      //                 : text,
      //             style: TextStyle(fontSize: 16),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }

  String toCamelCase(String text) {
    return text
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }
}
