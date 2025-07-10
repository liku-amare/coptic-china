import 'dart:async';
import 'package:flutter/foundation.dart';
import 'simple_amplify_chat_service.dart';
import '../auth/auth_service.dart';

class ChatNotificationService {
  static final ChatNotificationService _instance = ChatNotificationService._internal();
  factory ChatNotificationService() => _instance;
  ChatNotificationService._internal();

  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  final AuthService _authService = AuthService();
  
  SimpleAmplifyChatService? _chatService;
  StreamSubscription<int>? _chatSubscription;
  int _currentUnreadCount = 0;
  bool _isInitialized = false;
  
  // Getters
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  int get currentUnreadCount => _currentUnreadCount;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if user is authenticated
      final isSignedIn = await _authService.isSignedIn();
      if (!isSignedIn) {
        _currentUnreadCount = 0;
        _unreadCountController.add(0);
        return;
      }

      // Initialize chat service
      _chatService = SimpleAmplifyChatService();
      await _chatService!.initialize();
      
      // Subscribe to unread count changes
      _chatSubscription = _chatService!.unreadCountStream.listen((count) {
        _currentUnreadCount = count;
        _unreadCountController.add(count);
      });
      
      // Get initial unread count
      _currentUnreadCount = _chatService!.unreadCount;
      _unreadCountController.add(_currentUnreadCount);
      
      _isInitialized = true;
      debugPrint('ChatNotificationService initialized with unread count: $_currentUnreadCount');
    } catch (e) {
      debugPrint('Error initializing ChatNotificationService: $e');
      _currentUnreadCount = 0;
      _unreadCountController.add(0);
    }
  }

  Future<void> refresh() async {
    if (!_isInitialized || _chatService == null) {
      await initialize();
      return;
    }
    
    try {
      // Mock service doesn't need manual refresh as it auto-refreshes
      debugPrint('ChatNotificationService refresh requested');
    } catch (e) {
      debugPrint('Error refreshing ChatNotificationService: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (!_isInitialized || _chatService == null) return;
    
    try {
      await _chatService!.markAllMessagesAsRead();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> reset() async {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    
    if (_chatService != null) {
      _chatService!.dispose();
      _chatService = null;
    }
    
    _currentUnreadCount = 0;
    _unreadCountController.add(0);
    _isInitialized = false;
    
    debugPrint('ChatNotificationService reset');
  }

  Future<void> reinitialize() async {
    await reset();
    await initialize();
  }

  void dispose() {
    _chatSubscription?.cancel();
    _unreadCountController.close();
    _chatService?.dispose();
  }
} 