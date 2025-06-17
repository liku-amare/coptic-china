import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'settings_page.dart';
import '../widgets/settings.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../amplify/amplifyconfiguration.dart';
import '../auth/login_page.dart';
import '../auth/account_management_page.dart';
import '../auth/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _appName = 'App Name';
  String _version = 'v1.0.0';
  bool _isLoading = true;
  bool _isAuthenticated = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      await _authService.configureAmplify();
      await _checkAuthStatus();
    } catch (e) {
      debugPrint('Error configuring Amplify: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // First check if user is signed in
      final isSignedIn = await _authService.isSignedIn();

      if (isSignedIn) {
        // Verify JWT token exists and is valid
        final hasValidToken = await _authService.hasValidToken();

        setState(() {
          _isAuthenticated = hasValidToken;
          _isLoading = false;
        });

        debugPrint(
          'Auth status: signed in=$isSignedIn, valid token=$hasValidToken',
        );
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });

        debugPrint('Auth status: user not signed in');
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _version = 'v${info.version}';
    });
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    // Refresh auth status when returning from login page
    if (result == true) {
      _checkAuthStatus();
    }
  }

  Future<void> _navigateToAccountManagement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountManagementPage()),
    );

    // Refresh auth status when returning from account management page
    debugPrint('Returned from account management page with result: $result');

    // Force refresh auth status to update UI (especially important after logout)
    await _checkAuthStatus();

    // If user logged out, show a message
    if (result == true && !_isAuthenticated) {
      debugPrint('User logged out, UI should now show login button');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName('account_page')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Logo
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/logo.png'),
          ),
          const SizedBox(height: 8),
          // App Name & Version
          Text(
            itemName('app_name'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(_version, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),

          // Main section with auth-dependent buttons
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildSection([
                // Show login or account management based on auth status
                _isAuthenticated
                    ? _buildButton(
                      Icons.account_circle,
                      'My Account',
                      _navigateToAccountManagement,
                    )
                    : _buildButton(
                      Icons.login,
                      itemName('acc_login'),
                      _navigateToLogin,
                    ),
                // Other buttons
                _buildButton(Icons.message, itemName('acc_messages'), () {}),
              ]),

          const Divider(),

          // Section 2: Settings, About App
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
