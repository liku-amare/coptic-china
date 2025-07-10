import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  // Authentication related logs
  static void logAuthSuccess(String message, {Map<String, dynamic>? data}) {
    String logMessage = '🔐 AUTH SUCCESS: $message';
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.i(logMessage);
  }

  static void logAuthError(String message, {dynamic error}) {
    String logMessage = '🚫 AUTH ERROR: $message';
    if (error != null) {
      logMessage += ' - Error: $error';
    }
    _logger.e(logMessage);
  }

  static void logAuthAttempt(String message, {Map<String, dynamic>? data}) {
    String logMessage = '🔑 AUTH ATTEMPT: $message';
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.d(logMessage);
  }

  // User related logs
  static void logUserInfo(String message, {Map<String, dynamic>? userData}) {
    String logMessage = '👤 USER INFO: $message';
    if (userData != null) {
      logMessage += ' - UserData: $userData';
    }
    _logger.i(logMessage);
  }

  static void logUserId(String userId, {String? context}) {
    _logger.i('🆔 USER ID: $userId ${context != null ? '($context)' : ''}');
  }

  // General app logs
  static void info(String message, {dynamic data}) {
    String logMessage = message;
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.i(logMessage);
  }

  static void debug(String message, {dynamic data}) {
    String logMessage = message;
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.d(logMessage);
  }

  static void warning(String message, {dynamic data}) {
    String logMessage = message;
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.w(logMessage);
  }

  static void error(String message, {dynamic error}) {
    String logMessage = message;
    if (error != null) {
      logMessage += ' - Error: $error';
    }
    _logger.e(logMessage);
  }

  // Language change logs
  static void logLanguageChange(String message, {Map<String, dynamic>? data}) {
    String logMessage = '🌐 LANGUAGE: $message';
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.d(logMessage);
  }

  // Theme change logs
  static void logThemeChange(String message, {Map<String, dynamic>? data}) {
    String logMessage = '🎨 THEME: $message';
    if (data != null) {
      logMessage += ' - Data: $data';
    }
    _logger.d(logMessage);
  }
} 