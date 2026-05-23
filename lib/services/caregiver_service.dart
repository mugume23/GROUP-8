import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/caregiver_model.dart';
import '../models/review_model.dart';

class CaregiverService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all caregivers
  Future<List<CaregiverModel>> getAllCaregivers() async {
    final snap = await _db.collection('caregivers').get();
    return snap.docs
        .map((d) => CaregiverModel.fromMap(d.data(), d.id))
        .toList();
  }

  // Get caregiver by userId
  Future<CaregiverModel?> getCaregiverByUserId(String userId) async {
    try {
      // First try direct document access (more efficient)
      final doc = await _db.collection('caregivers').doc(userId).get();
      if (doc.exists) {
        return CaregiverModel.fromMap(doc.data()!, doc.id);
      }

      // Fallback to query by userId field
      final snap = await _db
          .collection('caregivers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return CaregiverModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
    } catch (e) {
      print('Error fetching caregiver by userId: $e');
      return null;
    }
  }

  // Get caregiver by doc id
  Future<CaregiverModel?> getCaregiverById(String id) async {
    final doc = await _db.collection('caregivers').doc(id).get();
    if (!doc.exists) return null;
    return CaregiverModel.fromMap(doc.data()!, doc.id);
  }

  // Update caregiver profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    final snap = await _db
        .collection('caregivers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      await _db.collection('caregivers').doc(snap.docs.first.id).update(data);
    }
  }

  // Search & filter caregivers
  Future<List<CaregiverModel>> searchCaregivers({
    String? query,
    String? location,
    List<String>? specializations,
    double? maxRate,
    bool? availableOnly,
  }) async {
    Query q = _db.collection('caregivers');

    if (availableOnly == true) {
      q = q.where('isAvailable', isEqualTo: true);
    }

    final snap = await q.get();
    List<CaregiverModel> results = snap.docs
        .map((d) => CaregiverModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    // Client-side filtering
    if (query != null && query.isNotEmpty) {
      final q2 = query.toLowerCase();
      results = results.where((c) =>
          c.name.toLowerCase().contains(q2) ||
          c.bio.toLowerCase().contains(q2) ||
          c.location.toLowerCase().contains(q2)).toList();
    }

    if (location != null && location.isNotEmpty) {
      results = results
          .where((c) => c.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    if (specializations != null && specializations.isNotEmpty) {
      results = results.where((c) {
        return specializations.any((s) => c.specializations.contains(s));
      }).toList();
    }

    if (maxRate != null) {
      results = results.where((c) => c.hourlyRate <= maxRate).toList();
    }

    return results;
  }

  // Hybrid matching algorithm
  List<CaregiverModel> getMatchedCaregivers(
    List<CaregiverModel> caregivers,
    Map<String, dynamic> parentPrefs,
  ) {
    // Score each caregiver
    final scored = caregivers.map((c) {
      return {'caregiver': c, 'score': c.matchScore(parentPrefs)};
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored.map((s) => s['caregiver'] as CaregiverModel).toList();
  }

  // Add review
  Future<void> addReview(ReviewModel review, String caregiverId) async {
    await _db.collection('reviews').add(review.toMap());

    // Recalculate average rating
    final reviews = await _db
        .collection('reviews')
        .where('caregiverId', isEqualTo: caregiverId)
        .get();

    if (reviews.docs.isNotEmpty) {
      double total = 0;
      for (final doc in reviews.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }
      final avg = total / reviews.docs.length;

      await _db.collection('caregivers').doc(caregiverId).update({
        'rating': avg,
        'reviewCount': reviews.docs.length,
      });
    }
  }

  // Get reviews for a caregiver
  Future<List<ReviewModel>> getReviews(String caregiverId) async {
    final snap = await _db
        .collection('reviews')
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => ReviewModel.fromMap(d.data(), d.id))
        .toList();
  }
}
