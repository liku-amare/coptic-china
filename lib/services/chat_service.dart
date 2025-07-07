import 'package:amplify_flutter/amplify_flutter.dart';
import '../auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isFromCurrentUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isFromCurrentUser: json['senderId'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatService {
  final AuthService _authService = AuthService();
  List<ChatMessage> _messages = [];
  bool _isInitialized = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Amplify if not already configured
      await _authService.configureAmplify();
      _isInitialized = true;
      
      // Load initial messages
      await loadMessages();
    } catch (e) {
      debugPrint('Error initializing chat service: $e');
    }
  }

  Future<void> loadMessages() async {
    try {
      // For now, we'll use a simple in-memory approach
      // In a real implementation, you'd fetch from API/DataStore
      _messages = [
        ChatMessage(
          id: '1',
          content: 'Welcome to the Coptic Church chat! How can we help you today?',
          senderId: 'system',
          senderName: 'Church Admin',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isFromCurrentUser: false,
        ),
        ChatMessage(
          id: '2',
          content: 'Thank you! I have a question about the daily readings.',
          senderId: 'user1',
          senderName: 'John Doe',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isFromCurrentUser: false,
        ),
        ChatMessage(
          id: '3',
          content: 'Of course! The daily readings are based on the Coptic calendar. You can find them in the Readings section.',
          senderId: 'system',
          senderName: 'Church Admin',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isFromCurrentUser: false,
        ),
      ];
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final userData = await _authService.getUserData();
      final userName = userData['fullName'] ?? 'User';
      final userId = userData['username'] ?? 'unknown';

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        senderId: userId,
        senderName: userName,
        timestamp: DateTime.now(),
        isFromCurrentUser: true,
      );

      _messages.add(newMessage);

      // In a real implementation, you'd save to API/DataStore here
      // await _saveMessageToAPI(newMessage);

      // Simulate response from admin
      await Future.delayed(const Duration(seconds: 2));
      
      final responseMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: _generateResponse(content),
        senderId: 'system',
        senderName: 'Church Admin',
        timestamp: DateTime.now(),
        isFromCurrentUser: false,
      );

      _messages.add(responseMessage);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  String _generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('reading') || message.contains('bible')) {
      return 'The daily readings are available in the Readings section. They follow the Coptic calendar and include passages from the Bible that are relevant to today\'s liturgical season.';
    } else if (message.contains('prayer') || message.contains('agpeya')) {
      return 'The Agpeya (Book of Hours) contains the seven canonical prayers of the Coptic Church. You can access it in the Agpeya section of the app.';
    } else if (message.contains('service') || message.contains('liturgy')) {
      return 'Our church services follow the Coptic Orthodox tradition. The main liturgy is the Divine Liturgy of St. Basil, celebrated on Sundays and feast days.';
    } else if (message.contains('calendar') || message.contains('date')) {
      return 'The Coptic calendar is based on the ancient Egyptian calendar and is used to determine feast days and fasting periods. Today\'s readings are based on this calendar.';
    } else {
      return 'Thank you for your message. If you have specific questions about the Coptic Church, our services, or the app, please feel free to ask. You can also explore the different sections of the app to learn more.';
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
  }

  void dispose() {
    _messages.clear();
    _isInitialized = false;
  }
} 