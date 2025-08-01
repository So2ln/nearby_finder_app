import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/model/review.dart';

class ReviewRepository {
  final _firestore = FirebaseFirestore.instance.collection('reviews');

  // 특정 장소의 모든 리뷰 볼러오기
  Future<List<Review>> getReviews(String locationId) async {
    try {
      final snapshot = await _firestore
          .where('locationId', isEqualTo: locationId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  // 리뷰 추가하기
  Future<void> addReview(Review review) async {
    await _firestore.add(review.toFirestore());
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});
