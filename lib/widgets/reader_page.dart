import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReaderPage extends StatefulWidget {
  final String filePath;
  final List<String> sections;

  const ReaderPage({super.key, required this.filePath, required this.sections});

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  String content = '';
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final data = await rootBundle.loadString(widget.filePath);
      setState(() {
        content = data;
      });
    } catch (e) {
      setState(() {
        content = 'Error loading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sections[selectedIndex])),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: widget.sections.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(widget.sections[index]),
              selected: selectedIndex == index,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body:
          content.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(child: Text(content)),
              ),
    );
  }
}
