import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new request (parent sends to caregiver)
  Future<void> createRequest({
    required String parentId,
    required String parentName,
    required String caregiverId,
    required String message,
  }) async {
    await _db.collection('requests').add({
      'parentId': parentId,
      'parentName': parentName,
      'caregiverId': caregiverId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // Get requests for a caregiver (stream for real-time updates)
  Stream<List<RequestModel>> getRequestsForCaregiver(String caregiverId) {
    return _db
        .collection('requests')
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map((snap) {
      final requests = snap.docs
          .map((doc) => RequestModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory instead of using orderBy (avoids index requirement)
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get requests sent by a parent
  Stream<List<RequestModel>> getRequestsByParent(String parentId) {
    return _db
        .collection('requests')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snap) {
      final requests = snap.docs
          .map((doc) => RequestModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory instead of using orderBy (avoids index requirement)
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Accept a request
  Future<void> acceptRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).update({
      'status': 'accepted',
    });
  }

  // Decline a request
  Future<void> declineRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).update({
      'status': 'declined',
    });
  }

  // Get count of pending requests for a caregiver
  Future<int> getPendingCount(String caregiverId) async {
    final snap = await _db
        .collection('requests')
        .where('caregiverId', isEqualTo: caregiverId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.length;
  }
}
