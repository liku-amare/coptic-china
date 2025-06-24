import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../amplify/amplifyconfiguration.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Configure Amplify with authentication plugin
  Future<void> configureAmplify() async {
    try {
      // Check if Amplify is already configured
      final isConfigured = await Amplify.isConfigured;
      if (isConfigured) return;

      // Add Cognito Auth plugin
      final authPlugin = AmplifyAuthCognito();
      await Amplify.addPlugin(authPlugin);

      // Configure Amplify
      await Amplify.configure(amplifyconfig);

      debugPrint('Amplify configured successfully');
    } catch (e) {
      debugPrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  /// Sign up a new user
  Future<SignUpResult> signUp({
    required String username,
    required String password,
    required String email,
    required String fullName,
    required String gender,
  }) async {
    try {
      final userAttributes = {
        CognitoUserAttributeKey.email: email,
        CognitoUserAttributeKey.name: fullName,
        CognitoUserAttributeKey.gender: gender,
      };

      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: CognitoSignUpOptions(userAttributes: userAttributes),
      );

      debugPrint('Sign-up result: ${result.isSignUpComplete}');
      return result;
    } on AuthException catch (e) {
      debugPrint('Sign-up error: ${e.message}');
      rethrow;
    }
  }

  /// Confirm sign up with verification code
  Future<SignUpResult> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );

      debugPrint('Confirmation result: ${result.isSignUpComplete}');
      return result;
    } on AuthException catch (e) {
      debugPrint('Confirm sign-up error: ${e.message}');
      rethrow;
    }
  }

  /// Resend confirmation code
  Future<ResendSignUpCodeResult> resendSignUpCode({
    required String username,
  }) async {
    try {
      final result = await Amplify.Auth.resendSignUpCode(username: username);

      debugPrint('Code resent: ${result.codeDeliveryDetails.destination}');
      return result;
    } on AuthException catch (e) {
      debugPrint('Resend code error: ${e.message}');
      rethrow;
    }
  }

  /// Sign in an existing user
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      debugPrint('Login success? ${result.isSignedIn}');

      if (result.isSignedIn) {
        // Save user data for offline access
        await _saveUserData();
      }

      return result;
    } on AuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      rethrow;
    }
  }

  /// Save user data to secure storage
  Future<void> _saveUserData() async {
    try {
      // Get current auth session
      final session =
          await Amplify.Auth.fetchAuthSession(
                options: CognitoSessionOptions(getAWSCredentials: true),
              )
              as CognitoAuthSession;

      // Get token
      final tokens = session.userPoolTokens;
      if (tokens != null) {
        final jwtToken = tokens.accessToken;
        await _secureStorage.write(key: _tokenKey, value: jwtToken.toString());
      }

      // Get user attributes
      final userData = await getUserData();

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userData.toString());
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  /// Get user data from Cognito
  Future<Map<String, dynamic>> getUserData() async {
    try {
      // Check if user is signed in
      final isUserSignedIn = await isSignedIn();
      if (!isUserSignedIn) {
        return {};
      }

      // Get user attributes
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final currentUser = await Amplify.Auth.getCurrentUser();

      // Create user data map
      final userData = <String, dynamic>{'username': currentUser.username};

      // Add attributes
      for (final attribute in attributes) {
        switch (attribute.userAttributeKey.key) {
          case 'email':
            userData['email'] = attribute.value;
            break;
          case 'name':
            userData['fullName'] = attribute.value;
            break;
          case 'gender':
            userData['gender'] = attribute.value;
            break;
        }
      }

      return userData;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return {};
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();

      // Clear stored data
      await _secureStorage.delete(key: _tokenKey);

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      debugPrint('Sign out completed');
    } on AuthException catch (e) {
      debugPrint('Sign out error: ${e.message}');
      rethrow;
    }
  }

  /// Update user attributes
  Future<void> updateUserAttributes({
    required String fullName,
    required String gender,
  }) async {
    try {
      final attributes = <AuthUserAttribute>[
        AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.name,
          value: fullName,
        ),
        AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.gender,
          value: gender,
        ),
      ];

      await Amplify.Auth.updateUserAttributes(attributes: attributes);

      // Update stored user data
      await _saveUserData();
    } on AuthException catch (e) {
      debugPrint('Update user attributes error: ${e.message}');
      rethrow;
    }
  }

  /// Check if a user is signed in
  Future<bool> isSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      return false;
    }
  }

  /// Get the current auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Check if JWT token exists and is valid
  Future<bool> hasValidToken() async {
    try {
      // Check if token exists in storage
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('No JWT token found in storage');
        return false;
      }

      // Verify token with Amplify by checking current session
      final session = await Amplify.Auth.fetchAuthSession();
      final isValid = session.isSignedIn;

      debugPrint('JWT token validation result: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  /// Reset user's password
  Future<ResetPasswordResult> resetPassword(String username) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: username);
      safePrint(
        'Password reset sent to: ${result.nextStep.codeDeliveryDetails?.destination}',
      );
      return result;
    } on AuthException catch (e) {
      safePrint('Error resetting password: ${e.message}');
      rethrow;
    }
  }

  /// Confirm reset password with a new password
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      safePrint('Password has been successfully reset.');
    } on AuthException catch (e) {
      safePrint('Error confirming password reset: ${e.message}');
      rethrow;
    }
  }
}
