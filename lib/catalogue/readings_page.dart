import 'package:coptic_reader/widgets/reader_page_excel.dart';
import 'package:flutter/material.dart';
import 'package:coptic_reader/widgets/items.dart';

class ReadingsPage extends StatelessWidget {
  var items;
  var files;
  var pageTitle;
  final String pageType;

  ReadingsPage(this.pageType, {super.key}) {
    items = Items.itemMap[pageType];
    files = Items.fileMap[pageType];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Items.getTitles(pageType))),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(items[index].icon, color: Colors.blue, size: 30),
                title: Text(items[index].title, style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReaderPageExcel(filePath: files[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
