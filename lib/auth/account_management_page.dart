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
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
      appBar: AppBar(
        title: Text(itemName('account_page')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
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
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.deepPurple,
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // User email
                      Text(
                        _userData['email'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // User information section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _userData['email'] ?? 'Not provided',
                              ),
                              const Divider(),
                              _buildInfoItem(
                                icon: Icons.badge_outlined,
                                label: 'Full Name',
                                value: _userData['fullName'] ?? 'Not provided',
                              ),
                              const Divider(),
                              _buildInfoItem(
                                icon: Icons.people_outline,
                                label: 'Gender',
                                value: _userData['gender'] ?? 'Not provided',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Account actions
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Edit Profile Button
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: Colors.deepPurple,
                              ),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
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
                              title: const Text('Logout'),
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
