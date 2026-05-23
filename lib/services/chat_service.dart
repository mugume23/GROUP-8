import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  String _chatId(String parentId, String caregiverId) {
    final ids = [parentId, caregiverId]..sort();
    return ids.join('_');
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    required String parentId,
    required String caregiverId,
    required String parentName,
    required String caregiverName,
    String? parentImage,
    String? caregiverImage,
  }) async {
    final chatId = _chatId(parentId, caregiverId);
    final msgId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      id: msgId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: now,
      status: MessageStatus.sent, // written = sent
    );

    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(msgId)
        .set(message.toMap());

    // Update chat metadata
    await _db.collection('chats').doc(chatId).set({
      'parentId': parentId,
      'caregiverId': caregiverId,
      'parentName': parentName,
      'caregiverName': caregiverName,
      'parentImage': parentImage,
      'caregiverImage': caregiverImage,
      'lastMessage': content,
      'lastMessageTime': now.millisecondsSinceEpoch,
      'unreadCount': FieldValue.increment(1),
      'isTyping': false,
      'typingUserId': null,
    }, SetOptions(merge: true));
  }

  // ── Mark all messages as read (blue ticks) ────────────────────────────────
  Future<void> markAsRead(
      String parentId, String caregiverId, String currentUserId) async {
    final chatId = _chatId(parentId, caregiverId);

    // Reset unread counter
    await _db
        .collection('chats')
        .doc(chatId)
        .update({'unreadCount': 0});

    // Update all unread messages sent TO this user to 'read'
    final unread = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', whereIn: ['sent', 'delivered'])
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'status': 'read', 'isRead': true});
    }
    await batch.commit();
  }

  // ── Mark messages as delivered when chat list is viewed ──────────────────
  Future<void> markDelivered(
      String parentId, String caregiverId, String currentUserId) async {
    final chatId = _chatId(parentId, caregiverId);

    final sent = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    final batch = _db.batch();
    for (final doc in sent.docs) {
      batch.update(doc.reference, {'status': 'delivered'});
    }
    await batch.commit();
  }

  // ── Typing indicator ──────────────────────────────────────────────────────
  Future<void> setTyping(
      String parentId, String caregiverId, String userId, bool typing) async {
    final chatId = _chatId(parentId, caregiverId);
    await _db.collection('chats').doc(chatId).set({
      'isTyping': typing,
      'typingUserId': typing ? userId : null,
    }, SetOptions(merge: true));
  }

  // ── Stream messages ───────────────────────────────────────────────────────
  Stream<List<MessageModel>> getMessages(
      String parentId, String caregiverId) {
    final chatId = _chatId(parentId, caregiverId);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Stream chat metadata (for typing indicator) ───────────────────────────
  Stream<ChatModel?> getChatStream(String parentId, String caregiverId) {
    final chatId = _chatId(parentId, caregiverId);
    return _db
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snap) =>
            snap.exists ? ChatModel.fromMap(snap.data()!, snap.id) : null);
  }

  // ── Stream all chats for a user ───────────────────────────────────────────
  Stream<List<ChatModel>> getUserChats(String userId, String role) {
    final field = role == 'parent' ? 'parentId' : 'caregiverId';
    return _db
        .collection('chats')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final chats = snap.docs
          .map((d) => ChatModel.fromMap(d.data(), d.id))
          .toList();
      // Sort in memory to avoid index requirement
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }
}
