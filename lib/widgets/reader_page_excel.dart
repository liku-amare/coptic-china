import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/settings.dart';

class ReaderPageExcel extends StatefulWidget {
  final String filePath; // asset path
  final String initialLanguage = AppSettings.getCachedLang();

  ReaderPageExcel({super.key, required this.filePath});

  @override
  _ReaderPageExcelState createState() => _ReaderPageExcelState();
}

class _ReaderPageExcelState extends State<ReaderPageExcel> {
  List<Map<String, String>> verses = [];
  List<String> chapterTitles = [];
  String currentLanguage = 'en';
  String language1 = 'en';
  String language2 = 'ar';
  String currentChapter = '';
  final Map<String, List<String>> speakerMap = {
    'en': ['Priest', 'Deacon', 'Congregation'],
    'zh_hans': ['主祭', '执事', '全体'],
    'zh_hant': ['主祭', '執事', '全體'],
    'ar': ['الكاهن', 'الشماس', 'الشعب'],
  };

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    language1 = AppSettings.getLangCode(await AppSettings.getLanguage1());
    language2 = AppSettings.getLangCode(await AppSettings.getLanguage2());
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    final bytes = await rootBundle.load(widget.filePath);
    final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
    final sheet = excel.tables[excel.tables.keys.first]!;
    final headers =
        sheet.rows.first.map((cell) => cell?.value.toString() ?? '').toList();

    final titleKey1 = 'title_$language1';
    final prayerKey1 = 'prayer_$language1';
    final titleKey2 = 'title_$language2';
    final prayerKey2 = 'prayer_$language2';

    final titleIndex1 = headers.indexOf(titleKey1);
    final prayerIndex1 = headers.indexOf(prayerKey1);
    final titleIndex2 = headers.indexOf(titleKey2);
    final prayerIndex2 = headers.indexOf(prayerKey2);

    List<Map<String, String>> loadedVerses = [];
    Set<String> seenChapters = {};

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final title1 = row[titleIndex1]?.value.toString().trim() ?? '';
      final prayer1 = row[prayerIndex1]?.value.toString().trim() ?? '';
      final title2 = row[titleIndex2]?.value.toString().trim() ?? '';
      final prayer2 = row[prayerIndex2]?.value.toString().trim() ?? '';

      loadedVerses.add({
        'title': title1,
        'prayer1': prayer1,
        'prayer2': prayer2,
      });
      if (!seenChapters.contains(title1)) {
        seenChapters.add(title1);
      }
    }

    setState(() {
      verses = loadedVerses;
      chapterTitles = seenChapters.toList();
      if (chapterTitles.isNotEmpty) {
        currentChapter = chapterTitles.first;
      }
    });
  }

  // void _switchLanguage(String lang) {
  //   setState(() {
  //     currentLanguage = lang;
  //     _loadExcelData();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final filteredVerses =
        verses.where((v) => v['title'] == currentChapter).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(currentChapter),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: _switchLanguage,
        //     itemBuilder:
        //         (context) => [
        //           PopupMenuItem(value: 'en', child: Text('English')),
        //           PopupMenuItem(value: 'zh_hans', child: Text('中文简体')),
        //           PopupMenuItem(value: 'zh_hant', child: Text('中文繁體')),
        //           PopupMenuItem(value: 'ar', child: Text('العربية')),
        //         ],
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: kToolbarHeight * 1.5,
              color: Color(0xFF2D2D2D),
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
                itemCount: chapterTitles.length,
                itemBuilder: (context, index) {
                  final chapter = chapterTitles[index];
                  return ListTile(
                    title: Text(chapter),
                    selected: chapter == currentChapter,
                    onTap: () {
                      setState(() {
                        currentChapter = chapter;
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

      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.deepPurple),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Text(
      //               itemName('reader_page_sections_header'),
      //               style: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       ...chapterTitles.map((chapter) {
      //         return ListTile(
      //           title: Text(chapter),
      //           selected: chapter == currentChapter,
      //           onTap: () {
      //             setState(() {
      //               currentChapter = chapter;
      //             });
      //             Navigator.pop(context);
      //           },
      //         );
      //       }).toList(),
      //     ],
      //   ),
      // ),
      body: ListView.builder(
        itemCount: filteredVerses.length,
        itemBuilder: (context, index) {
          final verse = filteredVerses[index];
          final prayer1 = verse['prayer1'] ?? '';
          final prayer2 = verse['prayer2'] ?? '';
          final speaker1 = _extractSpeaker(prayer1, language1);
          final speaker2 = _extractSpeaker(prayer2, language2);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (speaker1 != null)
                        Text(
                          speaker1,
                          style: TextStyle(
                            color: _getSpeakerColor(speaker1, language1),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      Text(
                        speaker1 != null
                            ? prayer1.replaceFirst('$speaker1:', '').trim()
                            : prayer1,
                        textAlign: TextAlign.left,
                        textDirection:
                            language2 == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (speaker2 != null)
                        Text(
                          speaker2,
                          style: TextStyle(
                            color: _getSpeakerColor(speaker2, language2),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      Text(
                        speaker2 != null
                            ? prayer2.replaceFirst('$speaker2:', '').trim()
                            : prayer2,
                        textDirection:
                            language2 == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _extractSpeaker(String text, String language) {
    final speakers = speakerMap[language] ?? [];

    for (var s in speakers) {
      if (text.startsWith('$s:') || text.startsWith('$s：')) return s;
    }
    return null;
  }

  Color _getSpeakerColor(String speaker, String language) {
    final speakers = speakerMap[language] ?? [];
    final speakerIndex = speakers.indexOf(speaker);
    switch (speakerIndex) {
      case 0: // Priest
        return Colors.red;
      case 1: // Deacon
        return Colors.purple;
      case 2: // Congregation
        return Colors.blueAccent;
      default:
        return Colors.black12;
    }
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}
