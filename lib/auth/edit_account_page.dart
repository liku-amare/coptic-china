import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/settings.dart';
import 'auth_service.dart';

class EditAccountPage extends StatefulWidget {
  final String fullName;
  final String gender;

  const EditAccountPage({
    Key? key,
    required this.fullName,
    required this.gender,
  }) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String _gender = 'male';

  final List<String> _genders = ['male', 'female'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data
    _fullNameController.text = widget.fullName;
    _gender = widget.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  // Helper method for localization
  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.updateUserAttributes(
        fullName: _fullNameController.text.trim(),
        gender: _gender,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate changes were made
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Profile Image
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 30),

                // Full Name field
                TextFormField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // We're not showing email field since we don't have it in the parameters
                const SizedBox(height: 20),

                // Gender dropdown
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items:
                      _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender.substring(0, 1).toUpperCase() +
                                gender.substring(1),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _gender = value;
                      });
                    }
                  },
                ),

                // Error message (if any)
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 30),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
