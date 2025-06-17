import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/settings.dart';
import 'auth_service.dart';
import 'login_page.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String username;

  const ConfirmationCodePage({Key? key, required this.username})
    : super(key: key);

  @override
  State<ConfirmationCodePage> createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Helper method for localization
  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  // Confirm sign up
  Future<void> _confirmSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.confirmSignUp(
        username: widget.username,
        confirmationCode: _codeController.text.trim(),
      );

      if (result.isSignUpComplete) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account confirmed successfully! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Confirmation failed. Please try again.';
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // Resend confirmation code
  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resendSignUpCode(username: widget.username);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent to your email.'),
          backgroundColor: Colors.blue,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Account'),
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

                // App logo
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage('assets/logo.png'),
                  ),
                ),

                const SizedBox(height: 30),

                // Info text
                const Text(
                  'A verification code has been sent to your email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                // Username display
                Center(
                  child: Text(
                    'Email: ${widget.username}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Confirmation code field
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter the 6-digit code',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.length < 6) {
                      return 'Please enter a valid verification code';
                    }
                    return null;
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

                // Confirm button
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmSignUp,
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
                            'Verify Account',
                            style: TextStyle(fontSize: 16),
                          ),
                ),

                const SizedBox(height: 20),

                // Resend code button
                TextButton(
                  onPressed: _isLoading ? null : _resendCode,
                  child: const Text(
                    "Didn't receive the code? Resend",
                    style: TextStyle(color: Colors.deepPurple),
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
