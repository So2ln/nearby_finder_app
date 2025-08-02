import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/review.dart';

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

  // (추가) 해당 장소의 평균 별점과 리뷰 개수 가져오기!
  Future<(double, int)> getAverageRatingAndCount(String locationId) async {
    try {
      final snapshot = await _firestore
          .where('locationId', isEqualTo: locationId)
          .get();

      if (snapshot.docs.isEmpty) {
        return (0.0, 0); // 리뷰가 없을 경우
      }

      int totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc.data()['rating'] as int;
      }

      double averageRating = totalRating / snapshot.docs.length;
      return (averageRating, snapshot.docs.length);
    } catch (e) {
      debugPrint('Error fetching average rating: $e');
      return (0.0, 0); // 에러 발생 시 기본값 반환
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});
