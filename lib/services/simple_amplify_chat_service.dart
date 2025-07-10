import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import '../models/abune_chat_message.dart';

class SimpleAmplifyChatService {
  static const String _abuneUserId = 'c93e34a8-e071-708c-ffdf-e927952546a7';
  // TODO: Replace with your actual API Gateway endpoint
  static const String _apiBaseUrl = 'https://YOUR_API_ID.execute-api.ap-southeast-2.amazonaws.com/dev';
  
  final StreamController<List<AbuneChatMessage>> _messagesController = 
      StreamController<List<AbuneChatMessage>>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();
  
  Timer? _refreshTimer;
  List<AbuneChatMessage> _cachedMessages = [];
  String? _currentUserId;
  String? _currentUserName;
  int _unreadCount = 0;
  bool _isApiConfigured = false;

  Stream<List<AbuneChatMessage>> get messagesStream => _messagesController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  int get unreadCount => _unreadCount;

  Future<void> initialize() async {
    try {
      // Get current user info
      final user = await Amplify.Auth.getCurrentUser();
      _currentUserId = user.userId;
      
      // Get user attributes for display name
      final attributes = await Amplify.Auth.fetchUserAttributes();
      _currentUserName = attributes
          .firstWhere(
            (attr) => attr.userAttributeKey == AuthUserAttributeKey.email,
            orElse: () => const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.email,
              value: 'Unknown User'
            ),
          )
          .value;

      // Check if API is configured
      _isApiConfigured = !_apiBaseUrl.contains('YOUR_API_ID');

      print('🚀 SimpleAmplifyChatService initialized for user: $_currentUserName ($_currentUserId)');
      print('📡 API configured: $_isApiConfigured');
      
      // Load initial messages (demo or real)
      if (_isApiConfigured) {
        _startPeriodicRefresh();
        await loadMessages();
      } else {
        // Load demo messages for UI testing
        _loadDemoMessages();
        // Immediately emit to streams so UI updates
        _messagesController.add(_cachedMessages);
        _unreadCountController.add(0);
        print('✅ Demo messages loaded and emitted to streams');
      }
      
      print('✅ Chat service initialization complete');
    } catch (e) {
      print('❌ Error initializing SimpleAmplifyChatService: $e');
      // Load demo messages even if initialization fails
      _loadDemoMessages();
      _messagesController.add(_cachedMessages);
      _unreadCountController.add(0);
      print('🔄 Fallback: Demo messages loaded after error');
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      loadMessages();
    });
  }

  Future<List<AbuneChatMessage>> loadMessages() async {
    try {
      if (_currentUserId == null) {
        print('⚠️ User not authenticated, cannot load messages');
        return [];
      }

      // If API is not configured, return cached demo messages
      if (!_isApiConfigured) {
        print('📝 API not configured, using demo messages');
        return _cachedMessages;
      }

      print('🔄 Loading messages for user: $_currentUserId');

      // Use direct HTTP request instead of Amplify API
      final url = Uri.parse('$_apiBaseUrl/items?userId=$_currentUserId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messagesList = responseData['messages'] as List<dynamic>? ?? [];
        
        final messages = messagesList
            .map((messageJson) => _convertToAbuneChatMessage(messageJson))
            .toList();

        _cachedMessages = messages;
        _messagesController.add(messages);
        
        // Update unread count
        _unreadCount = await getUnreadMessageCount();
        _unreadCountController.add(_unreadCount);
        
        print('✅ Loaded ${messages.length} messages');
        return messages;
      } else {
        print('❌ Failed to load messages: ${response.statusCode}');
        return _cachedMessages;
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
      return _cachedMessages;
    }
  }

  Future<bool> sendMessage({
    required String content,
    String? targetUserId,
  }) async {
    try {
      if (_currentUserId == null || _currentUserName == null) {
        print('⚠️ User not authenticated, cannot send message');
        return false;
      }

      print('📤 Sending message: $content');

      String messageTypeStr;
      if (_currentUserId == _abuneUserId) {
        messageTypeStr = targetUserId != null ? 'ABUNE_TO_USER' : 'ABUNE_TO_ALL';
      } else {
        messageTypeStr = 'USER_TO_ABUNE';
        targetUserId = _abuneUserId; // Regular users always send to Abune
      }

      // If API is not configured, add to demo messages
      if (!_isApiConfigured) {
        print('📝 API not configured, adding message to demo data');
        final newMessage = AbuneChatMessage(
          id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          content: content,
          senderId: _currentUserId!,
          senderName: _currentUserName!,
          senderEmail: _currentUserName!,
          recipientId: targetUserId,
          timestamp: DateTime.now(),
          type: _parseMessageType(messageTypeStr),
          status: MessageStatus.sent,
          isFromCurrentUser: true,
          isFromAbune: _currentUserId == _abuneUserId,
          readBy: [],
        );
        
        _cachedMessages.add(newMessage);
        _messagesController.add(_cachedMessages);
        print('✅ Demo message added successfully');
        return true;
      }

      final messageData = {
        'senderId': _currentUserId!,
        'senderName': _currentUserName!,
        'content': content,
        'messageType': messageTypeStr,
        'targetUserId': targetUserId ?? '',
        'isRead': false,
      };

      // Use direct HTTP request instead of Amplify API
      final url = Uri.parse('$_apiBaseUrl/items');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 200) {
        print('✅ Message sent successfully');
        
        // Immediately refresh messages
        await loadMessages();
        return true;
      } else {
        print('❌ Failed to send message: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  Future<bool> markMessageAsRead(String messageId) async {
    try {
      // Use direct HTTP request instead of Amplify API
      final url = Uri.parse('$_apiBaseUrl/items/$messageId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isRead': true}),
      );

      if (response.statusCode == 200) {
        print('✅ Message marked as read: $messageId');
        await loadMessages(); // Refresh messages
        return true;
      } else {
        print('❌ Failed to mark message as read: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error marking message as read: $e');
      return false;
    }
  }

  // Utility methods
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  bool get isAbune => _currentUserId == _abuneUserId;
  static bool isAbuneUser(String userId) => userId == _abuneUserId;

  Future<int> getUnreadMessageCount() async {
    try {
      if (_currentUserId == null) return 0;
      
      return _cachedMessages
          .where((message) => 
              message.status != MessageStatus.read && 
              message.senderId != _currentUserId)
          .length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  List<AbuneChatMessage> get cachedMessages => List.unmodifiable(_cachedMessages);

  AbuneChatMessage _convertToAbuneChatMessage(Map<String, dynamic> json) {
    final messageType = _parseMessageType(json['messageType'] ?? 'USER_TO_ABUNE');
    
    return AbuneChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderEmail: json['senderName'] ?? '', // Using senderName as email placeholder
      recipientId: json['targetUserId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
      type: messageType,
      status: json['isRead'] == true ? MessageStatus.read : MessageStatus.sent,
      isFromCurrentUser: json['senderId'] == _currentUserId,
      isFromAbune: json['senderId'] == _abuneUserId,
      readBy: json['isRead'] == true ? [_currentUserId ?? ''] : [],
    );
  }

  MessageType _parseMessageType(String type) {
    switch (type) {
      case 'USER_TO_ABUNE':
        return MessageType.userToAbune;
      case 'ABUNE_TO_USER':
        return MessageType.abuneToUser;
      case 'ABUNE_TO_ALL':
        return MessageType.abuneToAll;
      case 'SYSTEM':
        return MessageType.system;
      default:
        return MessageType.userToAbune;
    }
  }

  // Compatibility methods for existing UI
  Future<void> sendMessageToAbune(String content) async {
    await sendMessage(content: content);
  }

  Future<void> broadcastMessageToAll(String content) async {
    await sendMessage(content: content);
  }

  Future<void> markAllMessagesAsRead() async {
    for (final message in _cachedMessages) {
      if (message.status != MessageStatus.read && message.senderId != _currentUserId) {
        await markMessageAsRead(message.id);
      }
    }
  }

  void dispose() {
    _refreshTimer?.cancel();
    _messagesController.close();
    _unreadCountController.close();
    print('🧹 SimpleAmplifyChatService disposed');
  }

  void _loadDemoMessages() {
    print('📝 Loading demo messages for UI testing');
    
    final bool isCurrentUserAbune = _currentUserId == _abuneUserId;
    List<AbuneChatMessage> demoMessages = [];
    
    if (isCurrentUserAbune) {
      // Demo messages for Abune - showing messages from various users
      demoMessages = [
        AbuneChatMessage(
          id: 'demo_user1',
          content: 'Dear Abune, thank you for your guidance during today\'s service.',
          senderId: 'user_demo_1',
          senderName: 'Mary',
          senderEmail: 'mary@example.com',
          recipientId: _abuneUserId,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: MessageType.userToAbune,
          status: MessageStatus.sent,
          isFromCurrentUser: false,
          isFromAbune: false,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_user2',
          content: 'Please pray for my family. We are going through difficult times.',
          senderId: 'user_demo_2',
          senderName: 'John',
          senderEmail: 'john@example.com',
          recipientId: _abuneUserId,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.userToAbune,
          status: MessageStatus.sent,
          isFromCurrentUser: false,
          isFromAbune: false,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_abune_response',
          content: 'Peace be with you all. Remember that God is always with us in times of trouble. I will pray for your families.',
          senderId: _abuneUserId,
          senderName: 'Abune',
          senderEmail: 'abune@copticchurch.org',
          recipientId: null, // Broadcast message
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          type: MessageType.abuneToAll,
          status: MessageStatus.sent,
          isFromCurrentUser: true,
          isFromAbune: true,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_system_abune',
          content: '📝 Demo mode: API not configured. Real messages will appear here once backend is set up.',
          senderId: 'system',
          senderName: 'System',
          senderEmail: 'system@app.com',
          recipientId: _abuneUserId,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          type: MessageType.system,
          status: MessageStatus.read,
          isFromCurrentUser: false,
          isFromAbune: false,
          readBy: [],
        ),
      ];
    } else {
      // Demo messages for regular users - showing messages from Abune
      demoMessages = [
        AbuneChatMessage(
          id: 'demo_welcome',
          content: 'Welcome to our church chat, ${_currentUserName ?? 'child of God'}! Peace be with you.',
          senderId: _abuneUserId,
          senderName: 'Abune',
          senderEmail: 'abune@copticchurch.org',
          recipientId: _currentUserId,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: MessageType.abuneToUser,
          status: MessageStatus.sent,
          isFromCurrentUser: false,
          isFromAbune: true,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_broadcast',
          content: 'Dear beloved children, Sunday service will be at 9 AM. Please join us for the Divine Liturgy. God bless you all.',
          senderId: _abuneUserId,
          senderName: 'Abune',
          senderEmail: 'abune@copticchurch.org',
          recipientId: null, // Broadcast message
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.abuneToAll,
          status: MessageStatus.sent,
          isFromCurrentUser: false,
          isFromAbune: true,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_user_message',
          content: 'Thank you for your guidance, Abune. Your words bring me peace.',
          senderId: _currentUserId!,
          senderName: _currentUserName!,
          senderEmail: _currentUserName!,
          recipientId: _abuneUserId,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          type: MessageType.userToAbune,
          status: MessageStatus.sent,
          isFromCurrentUser: true,
          isFromAbune: false,
          readBy: [],
        ),
        AbuneChatMessage(
          id: 'demo_system_user',
          content: '📝 Demo mode: API not configured. Real messages with Abune will appear here once backend is set up.',
          senderId: 'system',
          senderName: 'System',
          senderEmail: 'system@app.com',
          recipientId: _currentUserId,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          type: MessageType.system,
          status: MessageStatus.read,
          isFromCurrentUser: false,
          isFromAbune: false,
          readBy: [],
        ),
      ];
    }
    
    _cachedMessages = demoMessages;
    _messagesController.add(demoMessages);
    _unreadCountController.add(0);
    print('✅ Loaded ${demoMessages.length} demo messages for ${isCurrentUserAbune ? 'Abune' : 'user'}');
  }
} 