import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'settings_page.dart';
import '../widgets/settings.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _appName = 'App Name';
  String _version = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _version = 'v${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName('account_page')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      // appBar: AppBar(title: Text(itemName('account_page'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Logo
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
              'assets/logo.png',
            ), // Use your placeholder
          ),
          const SizedBox(height: 8),
          // App Name & Version
          Text(
            itemName('app_name'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(_version, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),

          // Section 1: Login, Messages, Favorites
          _buildSection([
            _buildButton(Icons.login, itemName('acc_login'), () {}),
            _buildButton(Icons.message, itemName('acc_messages'), () {}),
            // _buildButton(Icons.favorite, 'Favorites', () {}),
          ]),

          const Divider(),

          // Section 2: Settings, Feedback, About App, Contact Us
          _buildSection([
            _buildButton(Icons.settings, itemName('acc_settings'), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            }),
            _buildButton(Icons.info_outline, itemName('acc_aboutapp'), () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Column(children: items);
  }

  Widget _buildButton(IconData icon, String title, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onPressed,
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}
