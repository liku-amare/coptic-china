import 'package:flutter/material.dart';
import '../widgets/settings.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 16.0;
  String _fontStyle = 'Roboto';
  Color _fontColor = Colors.black;
  String _defaultLanguage = 'English';
  String _language1 = 'English';
  String _language2 = 'العربية';

  final List<String> fontStyles = ['Roboto', 'Arial', 'Georgia'];
  final List<String> languages = ['العربية', 'English', '中文（繁體）', '中文（简体）'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _fontSize = await AppSettings.getFontSize();
    _fontStyle = await AppSettings.getFontStyle();
    _fontColor = await AppSettings.getFontColor();
    _defaultLanguage = await AppSettings.getDefaultLanguage();
    _language1 = await AppSettings.getLanguage1();
    _language2 = await AppSettings.getLanguage2();
    setState(() {});
  }

  void _saveSettings() {
    AppSettings.setFontSize(_fontSize);
    AppSettings.setFontStyle(_fontStyle);
    AppSettings.setFontColor(_fontColor);
    AppSettings.setDefaultLanguage(_defaultLanguage);
    AppSettings.setLanguage1(_language1);
    AppSettings.setLanguage2(_language2);
    // Phoenix.rebirth(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(itemName('settings_saved_pop'))));
  }

  // void _pickColor() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Pick Font Color'),
  //         content: SingleChildScrollView(
  //           child: ColorPicker(
  //             pickerColor: _fontColor,
  //             onColorChanged: (color) => setState(() => _fontColor = color),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Done'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itemName('acc_settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Font Size Slider
            Text(
              '${itemName('sett_fontsize')}: ${_fontSize.toStringAsFixed(1)}',
            ),
            Slider(
              value: _fontSize,
              min: 10,
              max: 30,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
            const SizedBox(height: 16),

            // // Font Style Dropdown
            // Text(itemName('sett_fontstyle')),
            // DropdownButton<String>(
            //   value: _fontStyle,
            //   onChanged: (value) => setState(() => _fontStyle = value!),
            //   items:
            //       fontStyles
            //           .map(
            //             (style) =>
            //                 DropdownMenuItem(value: style, child: Text(style)),
            //           )
            //           .toList(),
            // ),
            // const SizedBox(height: 16),

            // // Font Color Picker
            // Text(itemName('sett_fontcolor')),
            // Row(
            //   children: [
            //     Container(
            //       width: 24,
            //       height: 24,
            //       color: _fontColor,
            //       margin: const EdgeInsets.only(right: 10),
            //     ),
            //     ElevatedButton(
            //       onPressed: _pickColor,
            //       child: Text(itemName('sett_fontcolor')),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),

            // Language Dropdown
            Text(itemName('sett_defaultlang')),
            DropdownButton<String>(
              value: _defaultLanguage,
              onChanged: (value) => setState(() => _defaultLanguage = value!),
              items:
                  languages
                      .map(
                        (lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),

            // Language 1 Dropdown
            Text(itemName('sett_disp_lang1')),
            DropdownButton<String>(
              value: _language1,
              onChanged: (value) => setState(() => _language1 = value!),
              items:
                  languages
                      .map(
                        (lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),

            // Language 2 Dropdown
            Text(itemName('sett_disp_lang2')),
            DropdownButton<String>(
              value: _language2,
              onChanged: (value) => setState(() => _language2 = value!),
              items:
                  languages
                      .map(
                        (lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)),
                      )
                      .toList(),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text(itemName('sett_savesettings')),
            ),
          ],
        ),
      ),
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}
