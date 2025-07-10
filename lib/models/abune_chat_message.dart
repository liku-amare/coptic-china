enum MessageType {
  userToAbune,    // Regular user sending to Abune
  abuneToUser,    // Abune sending to specific user
  abuneToAll,     // Abune broadcasting to all users
  system,         // System messages
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class AbuneChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String? recipientId; // For direct messages
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isFromCurrentUser;
  final bool isFromAbune;
  final List<String> readBy; // List of user IDs who have read the message

  AbuneChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    this.recipientId,
    required this.timestamp,
    required this.type,
    this.status = MessageStatus.sent,
    required this.isFromCurrentUser,
    required this.isFromAbune,
    this.readBy = const [],
  });

  factory AbuneChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    const String abuneUserId = 'c93e34a8-e071-708c-ffdf-e927952546a7';
    
    return AbuneChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderEmail: json['senderEmail'] ?? '',
      recipientId: json['recipientId'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.userToAbune,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      isFromCurrentUser: json['senderId'] == currentUserId,
      isFromAbune: json['senderId'] == abuneUserId,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'recipientId': recipientId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'readBy': readBy,
    };
  }

  AbuneChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    String? senderEmail,
    String? recipientId,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    bool? isFromCurrentUser,
    bool? isFromAbune,
    List<String>? readBy,
  }) {
    return AbuneChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      recipientId: recipientId ?? this.recipientId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      isFromAbune: isFromAbune ?? this.isFromAbune,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AbuneChatMessage &&
        other.id == id &&
        other.content == content &&
        other.senderId == senderId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        senderId.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'AbuneChatMessage(id: $id, content: $content, senderId: $senderId, type: $type, status: $status)';
  }
}

// Helper class for organizing messages by user for Abune's view
class UserConversation {
  final String userId;
  final String userName;
  final String userEmail;
  final List<AbuneChatMessage> messages;
  final int unreadCount;
  final DateTime lastMessageTime;

  UserConversation({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.messages,
    required this.unreadCount,
    required this.lastMessageTime,
  });

  factory UserConversation.fromMessages(List<AbuneChatMessage> userMessages) {
    if (userMessages.isEmpty) {
      throw ArgumentError('Cannot create UserConversation from empty messages list');
    }

    final firstMessage = userMessages.first;
    final unreadCount = userMessages.where((msg) => 
      msg.type == MessageType.userToAbune && 
      !msg.readBy.contains('c93e34a8-e071-708c-ffdf-e927952546a7')
    ).length;

    return UserConversation(
      userId: firstMessage.senderId,
      userName: firstMessage.senderName,
      userEmail: firstMessage.senderEmail,
      messages: userMessages,
      unreadCount: unreadCount,
      lastMessageTime: userMessages.map((m) => m.timestamp).reduce((a, b) => a.isAfter(b) ? a : b),
    );
  }
} 