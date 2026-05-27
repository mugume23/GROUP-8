// Message delivery status — mirrors WhatsApp tick system
enum MessageStatus {
  sending,    // clock icon — not yet written to Firestore
  sent,       // single grey tick — written to Firestore
  delivered,  // double grey tick — receiver's device received it
  read,       // double blue tick — receiver opened the chat
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
  });

  // Backwards-compatible: old docs with isRead:bool still parse correctly
  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    MessageStatus status;
    if (map['status'] != null) {
      switch (map['status'] as String) {
        case 'read':
          status = MessageStatus.read;
          break;
        case 'delivered':
          status = MessageStatus.delivered;
          break;
        case 'sending':
          status = MessageStatus.sending;
          break;
        default:
          status = MessageStatus.sent;
      }
    } else {
      // Legacy field
      status = (map['isRead'] == true)
          ? MessageStatus.read
          : MessageStatus.sent;
    }

    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      // Keep legacy field for compatibility
      'isRead': status == MessageStatus.read,
    };
  }

  MessageModel copyWith({MessageStatus? status}) {
    return MessageModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}

class ChatModel {
  final String id;
  final String parentId;
  final String caregiverId;
  final String parentName;
  final String caregiverName;
  final String? parentImage;
  final String? caregiverImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isTyping;
  final String? typingUserId;

  ChatModel({
    required this.id,
    required this.parentId,
    required this.caregiverId,
    required this.parentName,
    required this.caregiverName,
    this.parentImage,
    this.caregiverImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.isTyping = false,
    this.typingUserId,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      parentId: map['parentId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      parentName: map['parentName'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
      parentImage: map['parentImage'],
      caregiverImage: map['caregiverImage'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      isTyping: map['isTyping'] ?? false,
      typingUserId: map['typingUserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'caregiverId': caregiverId,
      'parentName': parentName,
      'caregiverName': caregiverName,
      'parentImage': parentImage,
      'caregiverImage': caregiverImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'isTyping': isTyping,
      'typingUserId': typingUserId,
    };
  }
}
