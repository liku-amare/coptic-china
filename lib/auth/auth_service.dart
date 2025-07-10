import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../amplify/amplifyconfiguration.dart';
import '../utils/app_logger.dart';

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

      AppLogger.info('Amplify configured successfully');
    } catch (e) {
      AppLogger.error('Error configuring Amplify: $e');
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

      AppLogger.info('Sign-up result: ${result.isSignUpComplete}');
      return result;
    } on AuthException catch (e) {
      AppLogger.error('Sign-up error: ${e.message}');
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

      AppLogger.info('Confirmation result: ${result.isSignUpComplete}');
      return result;
    } on AuthException catch (e) {
      AppLogger.error('Confirm sign-up error: ${e.message}');
      rethrow;
    }
  }

  /// Resend confirmation code
  Future<ResendSignUpCodeResult> resendSignUpCode({
    required String username,
  }) async {
    try {
      final result = await Amplify.Auth.resendSignUpCode(username: username);

      AppLogger.info('Code resent: ${result.codeDeliveryDetails.destination}');
      return result;
    } on AuthException catch (e) {
      AppLogger.error('Resend code error: ${e.message}');
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

      AppLogger.info('Login success? ${result.isSignedIn}');

      if (result.isSignedIn) {
        // Save user data for offline access
        await _saveUserData();
      }

      return result;
    } on AuthException catch (e) {
      AppLogger.error('Sign in error: ${e.message}');
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
      AppLogger.error('Error saving user data: $e');
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
      AppLogger.error('Error getting user data: $e');
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

      AppLogger.info('Sign out completed');
    } on AuthException catch (e) {
      AppLogger.error('Sign out error: ${e.message}');
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
      AppLogger.error('Update user attributes error: ${e.message}');
      rethrow;
    }
  }

  /// Check if a user is signed in
  Future<bool> isSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      AppLogger.error('Error checking auth status: $e');
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
        AppLogger.info('No JWT token found in storage');
        return false;
      }

      // Verify token with Amplify by checking current session
      final session = await Amplify.Auth.fetchAuthSession();
      final isValid = session.isSignedIn;

      AppLogger.info('JWT token validation result: $isValid');
      return isValid;
    } catch (e) {
      AppLogger.error('Error validating token: $e');
      return false;
    }
  }

  /// Reset user's password
  Future<ResetPasswordResult> resetPassword(String username) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: username);
      AppLogger.info(
        'Password reset sent to: ${result.nextStep.codeDeliveryDetails?.destination}',
      );
      return result;
    } on AuthException catch (e) {
      AppLogger.error('Error resetting password: ${e.message}');
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
      AppLogger.info('Password has been successfully reset.');
    } on AuthException catch (e) {
      AppLogger.error('Error confirming password reset: ${e.message}');
      rethrow;
    }
  }

  /// Get the current user ID
  Future<String?> getUserId() async {
    try {
      // Check if user is signed in
      final isUserSignedIn = await isSignedIn();
      if (!isUserSignedIn) {
        AppLogger.info('User is not signed in');
        return null;
      }

      // Get current user
      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;
      
      AppLogger.info('Current User ID: $userId');
      return userId;
    } catch (e) {
      AppLogger.error('Error getting user ID: $e');
      return null;
    }
  }

  /// Get complete user information including ID
  Future<Map<String, dynamic>> getCompleteUserInfo() async {
    try {
      // Check if user is signed in
      final isUserSignedIn = await isSignedIn();
      if (!isUserSignedIn) {
        AppLogger.info('User is not signed in');
        return {};
      }

      // Get user attributes and current user
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final currentUser = await Amplify.Auth.getCurrentUser();

      // Create complete user data map
      final userData = <String, dynamic>{
        'userId': currentUser.userId,
        'username': currentUser.username,
        'signInDetails': currentUser.signInDetails,
      };

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
          case 'sub':
            userData['cognitoSub'] = attribute.value;
            break;
        }
      }

      // Log complete user information
      AppLogger.info('=== COMPLETE USER INFO ===');
      AppLogger.info('User ID: ${userData['userId']}');
      AppLogger.info('Username: ${userData['username']}');
      AppLogger.info('Email: ${userData['email']}');
      AppLogger.info('Full Name: ${userData['fullName']}');
      AppLogger.info('Gender: ${userData['gender']}');
      AppLogger.info('Cognito Sub: ${userData['cognitoSub']}');
      AppLogger.info('Sign In Details: ${userData['signInDetails']}');
      AppLogger.info('========================');

      return userData;
    } catch (e) {
      AppLogger.error('Error getting complete user info: $e');
      return {};
    }
  }

  /// Clear all app data including old chat messages and cached user data
  Future<void> clearAllAppData() async {
    try {
      AppLogger.info('Clearing all app cached data...');
      
      // FIRST: Force sign out from Amplify to clear auth cache
      try {
        final isSignedIn = await Amplify.Auth.fetchAuthSession();
        if (isSignedIn.isSignedIn) {
          await Amplify.Auth.signOut(options: const SignOutOptions(globalSignOut: true));
          AppLogger.info('Forced Amplify sign out completed');
        }
      } catch (e) {
        AppLogger.info('No active session to sign out: $e');
      }
      
      // Clear secure storage
      await _secureStorage.deleteAll();
      
      // Clear shared preferences (including old chat data)
      final prefs = await SharedPreferences.getInstance();
      
      // Clear ALL keys to ensure complete reset
      await prefs.clear();
      AppLogger.info('All SharedPreferences cleared');
      
      AppLogger.info('✅ All app cached data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing app data: $e');
    }
  }

  /// Force complete authentication reset
  Future<void> forceAuthenticationReset() async {
    try {
      AppLogger.info('🔄 Forcing complete authentication reset...');
      
      // 1. Force global sign out
      try {
        await Amplify.Auth.signOut(options: const SignOutOptions(globalSignOut: true));
        AppLogger.info('✅ Global sign out completed');
      } catch (e) {
        AppLogger.info('No session to sign out: $e');
      }
      
      // 2. Clear all local storage
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      AppLogger.info('✅ All local data cleared');
      AppLogger.info('🚀 Authentication reset complete - app will use NEW Amplify backend only');
    } catch (e) {
      AppLogger.error('Error during authentication reset: $e');
    }
  }

  /// Comprehensive verification of authentication setup
  Future<Map<String, dynamic>> verifyAuthSetup() async {
    final Map<String, dynamic> report = {
      'timestamp': DateTime.now().toIso8601String(),
      'checks': <String, dynamic>{},
      'overall_status': 'unknown',
      'errors': <String>[],
    };

    try {
      // 1. Check Amplify configuration
      report['checks']['amplify_configured'] = await Amplify.isConfigured;
      
      // 2. Check authentication status
      final authSession = await Amplify.Auth.fetchAuthSession();
      report['checks']['user_signed_in'] = authSession.isSignedIn;
      
      if (authSession.isSignedIn) {
        // 3. Get current user info
        final currentUser = await Amplify.Auth.getCurrentUser();
        report['checks']['user_id'] = currentUser.userId;
        report['checks']['username'] = currentUser.username;
        
        // 4. Get user attributes
        final attributes = await Amplify.Auth.fetchUserAttributes();
        final userInfo = <String, String>{};
        for (final attr in attributes) {
          userInfo[attr.userAttributeKey.key] = attr.value;
        }
        report['checks']['user_attributes'] = userInfo;
        
        // 5. Check JWT token
        final hasToken = await hasValidToken();
        report['checks']['jwt_token_valid'] = hasToken;
        
        // 6. Test API connectivity (if chat service available)
        try {
          final testResponse = await Amplify.API.get('/items', 
            queryParameters: {'test': 'auth_verification'}).response;
          report['checks']['api_connectivity'] = testResponse.statusCode == 200;
          report['checks']['api_status_code'] = testResponse.statusCode;
        } catch (e) {
          report['checks']['api_connectivity'] = false;
          report['checks']['api_error'] = e.toString();
        }
      }
      
      // Determine overall status
      final bool allGood = report['checks']['amplify_configured'] == true &&
                          report['checks']['user_signed_in'] == true &&
                          report['checks']['jwt_token_valid'] == true;
      
      report['overall_status'] = allGood ? 'excellent' : 'needs_attention';
      
      // Log the complete report
      AppLogger.info('=== AUTHENTICATION SETUP VERIFICATION ===');
      AppLogger.info('Overall Status: ${report['overall_status']}');
      AppLogger.info('Amplify Configured: ${report['checks']['amplify_configured']}');
      AppLogger.info('User Signed In: ${report['checks']['user_signed_in']}');
      AppLogger.info('JWT Token Valid: ${report['checks']['jwt_token_valid']}');
      AppLogger.info('API Connectivity: ${report['checks']['api_connectivity']}');
      if (report['checks']['user_id'] != null) {
        AppLogger.info('Current User ID: ${report['checks']['user_id']}');
        AppLogger.info('Current Username: ${report['checks']['username']}');
      }
      AppLogger.info('=======================================');
      
      return report;
    } catch (e) {
      report['errors'].add(e.toString());
      report['overall_status'] = 'error';
      AppLogger.error('Auth verification failed: $e');
      return report;
    }
  }
}
