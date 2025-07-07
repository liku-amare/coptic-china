import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'settings_page.dart';
import '../widgets/settings.dart';
import '../main.dart';
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
  final LanguageNotifier _languageNotifier = LanguageNotifier();

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _configureAmplify();
    
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(itemName('account_page')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),
            
            const SizedBox(height: 24),
            
            // Main Actions Section
            _buildSectionCard(
              title: itemName('acc_account'),
              icon: Icons.person,
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _isAuthenticated
                        ? _buildActionTile(
                            Icons.account_circle,
                            itemName('acc_my_account'),
                            itemName('acc_manage_account'),
                            _navigateToAccountManagement,
                          )
                        : _buildActionTile(
                            Icons.login,
                            itemName('acc_login'),
                            itemName('acc_sign_in'),
                            _navigateToLogin,
                          ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Settings Section
            _buildSectionCard(
              title: itemName('acc_preferences'),
              icon: Icons.settings,
              children: [
                _buildActionTile(
                  Icons.settings,
                  itemName('acc_settings'),
                  itemName('acc_customize'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
                _buildActionTile(
                  Icons.info_outline,
                  itemName('acc_aboutapp'),
                  itemName('acc_learn_more'),
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.church,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Text(
            itemName('app_name'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Version
          Text(
            _version,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isLoading
                  ? itemName('acc_loading')
                  : _isAuthenticated
                      ? itemName('acc_signed_in')
                      : itemName('acc_guest_user'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
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
          ),
          
          // Section Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}
