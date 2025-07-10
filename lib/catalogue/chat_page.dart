import 'package:flutter/material.dart';
import 'dart:async';
import '../services/simple_amplify_chat_service.dart';
import '../models/abune_chat_message.dart';
import '../widgets/settings.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SimpleAmplifyChatService _chatService = SimpleAmplifyChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isAbune = false;
  List<AbuneChatMessage> _messages = [];
  int _unreadCount = 0;
  
  StreamSubscription<List<AbuneChatMessage>>? _messagesSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final isSignedIn = await _authService.isSignedIn();
      setState(() {
        _isAuthenticated = isSignedIn;
      });

      if (isSignedIn) {
        try {
          await _chatService.initialize();
          _isAbune = _chatService.isAbune;
          
          // Set up stream subscriptions
          _messagesSubscription = _chatService.messagesStream.listen((messages) {
            setState(() {
              _messages = messages;
            });
            _scrollToBottom();
          });

          _unreadCountSubscription = _chatService.unreadCountStream.listen((count) {
            setState(() {
              _unreadCount = count;
            });
          });
          
          debugPrint('✅ Chat service initialized successfully for ${_isAbune ? 'Abune' : 'regular user'}');
        } catch (e) {
          debugPrint('❌ Error initializing chat service: $e');
          // Even if chat service fails, we still want to show the UI
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking authentication: $e');
    } finally {
      // ALWAYS stop loading and show UI
      setState(() {
        _isLoading = false;
      });
      debugPrint('🎯 Loading complete - showing UI (authenticated: $_isAuthenticated)');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn != _isAuthenticated) {
        setState(() {
          _isAuthenticated = isSignedIn;
        });
        
        if (isSignedIn) {
          await _initializeChat();
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      if (_isAbune) {
        // For Abune, always broadcast to all users
        await _chatService.broadcastMessageToAll(message);
      } else {
        await _chatService.sendMessageToAbune(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    await _chatService.markAllMessagesAsRead();
  }

  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(_isAbune ? 'Abune Chat - Broadcast' : 'Chat with Abune'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAuthenticated
              ? _buildChatInterface()
              : _buildLoginPrompt(),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Header showing chat with Abune
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAbune ? 'Broadcasting to All Users' : 'Abune',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isAbune 
                        ? 'Send messages to all users'
                        : 'Send your messages to Abune',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: _buildMessagesList(),
        ),
        
        // Message Input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isAbune ? 'No messages yet' : 'Start a conversation with Abune',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(AbuneChatMessage message) {
    final isFromCurrentUser = message.isFromCurrentUser;
    final isFromAbune = message.isFromAbune;
    
    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isFromCurrentUser
              ? Theme.of(context).colorScheme.primary
              : isFromAbune
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isFromAbune
              ? Border.all(color: Colors.green, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isFromCurrentUser)
              Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFromAbune ? Colors.green : Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isFromCurrentUser 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isFromCurrentUser 
                        ? Colors.white.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                if (isFromCurrentUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _getStatusIcon(message.status),
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _isAbune 
                    ? 'Broadcast message to all users...'
                    : 'Send message to Abune...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Login Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please login to start chatting with Abune',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
              
              if (result == true) {
                await _initializeChat();
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
} 