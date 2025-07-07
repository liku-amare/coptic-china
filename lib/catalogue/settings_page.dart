import 'package:flutter/material.dart';
import '../widgets/settings.dart';
import '../main.dart';
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
  ThemeMode _themeMode = ThemeMode.system;

  final List<String> fontStyles = ['Roboto', 'Arial', 'Georgia'];
  final List<String> languages = ['العربية', 'English', '中文（繁體）', '中文（简体）', 'Coptic'];

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
    _themeMode = await AppSettings.getThemeMode();
    setState(() {});
  }

  void _saveSettings() {
    AppSettings.setFontSize(_fontSize);
    AppSettings.setFontStyle(_fontStyle);
    AppSettings.setFontColor(_fontColor);
    AppSettings.setDefaultLanguage(_defaultLanguage);
    AppSettings.setLanguage1(_language1);
    AppSettings.setLanguage2(_language2);
    AppSettings.setThemeMode(_themeMode);
    
    // Apply theme change immediately
    final mainScreen = context.findAncestorStateOfType<MainScreenState>();
    if (mainScreen != null && mainScreen.widget.onThemeChanged != null) {
      mainScreen.widget.onThemeChanged!(_themeMode);
    }
    
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(
              content: Text(itemName('auth_settings_saved')),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ));
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(itemName('acc_settings')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            _buildSectionCard(
              title: itemName('sett_appearance'),
              icon: Icons.palette,
              children: [
                _buildThemeModeSelector(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Reading Settings Section
            _buildSectionCard(
              title: itemName('sett_reading_settings'),
              icon: Icons.text_fields,
              children: [
                _buildFontSizeSlider(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Language Settings Section
            _buildSectionCard(
              title: itemName('sett_language_settings'),
              icon: Icons.language,
              children: [
                _buildLanguageDropdown(
                  itemName('sett_default_language'),
                  _defaultLanguage,
                  (value) => setState(() => _defaultLanguage = value!),
                ),
                const SizedBox(height: 16),
                _buildLanguageDropdown(
                  itemName('sett_display_language_1'),
                  _language1,
                  (value) => setState(() => _language1 = value!),
                ),
                const SizedBox(height: 16),
                _buildLanguageDropdown(
                  itemName('sett_display_language_2'),
                  _language2,
                  (value) => setState(() => _language2 = value!),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  itemName('sett_savesettings'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                ThemeMode.light,
                'Light',
                Icons.wb_sunny,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption(
                ThemeMode.dark,
                'Dark',
                Icons.nightlight_round,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption(
                ThemeMode.system,
                'System',
                Icons.settings_system_daydream,
                Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon, Color color) {
    final isSelected = _themeMode == mode;
    
    return GestureDetector(
      onTap: () async {
        setState(() => _themeMode = mode);
        // Apply theme change immediately
        await AppSettings.setThemeMode(mode);
        
        // Use global theme notifier to update theme
        final themeNotifier = ThemeNotifier();
        themeNotifier.updateTheme(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
            ? color.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? color
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Font Size',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fontSize.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _fontSize,
            min: 10,
            max: 30,
            onChanged: (value) => setState(() => _fontSize = value),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(String label, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: (newValue) async {
              onChanged(newValue);
              
              // Apply language changes immediately
              if (label == 'Default Language' && newValue != null) {
                await AppSettings.setDefaultLanguage(newValue);
                final languageCode = AppSettings.getLangCode(newValue);
                final languageNotifier = LanguageNotifier();
                languageNotifier.updateLanguage(languageCode);
              } else if (label == 'Display Language 1' && newValue != null) {
                await AppSettings.setLanguage1(newValue);
              } else if (label == 'Display Language 2' && newValue != null) {
                await AppSettings.setLanguage2(newValue);
              }
            },
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: languages.map((lang) => DropdownMenuItem(
              value: lang,
              child: Text(
                lang,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}
