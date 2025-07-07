import 'package:flutter/material.dart';
import '../widgets/settings.dart';
import 'auth_service.dart';
import 'edit_account_page.dart';
import 'login_page.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({Key? key}) : super(key: key);

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final _authService = AuthService();
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    // Show confirmation dialog first
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(itemName('auth_logout')),
          content: Text(itemName('auth_logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(itemName('auth_cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    // If user cancels, don't proceed with logout
    if (shouldLogout != true) {
      return;
    }

    try {
      await _authService.signOut();
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to Account Page - this will trigger UI update to show login button
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon, 
            color: Theme.of(context).colorScheme.primary, 
            size: 28
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14, 
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Profile image
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User name in large text
                      Text(
                        _userData['fullName'] ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // User email
                      Text(
                        _userData['email'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // User information section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName('auth_account_info'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: itemName('auth_email'),
                                value: _userData['email'] ?? itemName('auth_not_provided'),
                              ),
                              const Divider(),
                              _buildInfoItem(
                                icon: Icons.badge_outlined,
                                label: itemName('auth_full_name'),
                                value: _userData['fullName'] ?? itemName('auth_not_provided'),
                              ),
                              const Divider(),
                              _buildInfoItem(
                                icon: Icons.people_outline,
                                label: itemName('auth_gender'),
                                value: _userData['gender'] ?? itemName('auth_not_provided'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Account actions
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Column(
                          children: [
                            // Edit Profile Button
                            ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                itemName('auth_edit_profile'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditAccountPage(
                                          fullName: _userData['fullName'] ?? '',
                                          gender: _userData['gender'] ?? 'male',
                                        ),
                                  ),
                                ).then((result) {
                                  // Reload user data if changes were made
                                  if (result == true) {
                                    _loadUserData();
                                  }
                                });
                              },
                            ),

                            const Divider(height: 1),

                            // Logout Button
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: Text(
                                itemName('auth_logout'),
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onTap: _signOut,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
