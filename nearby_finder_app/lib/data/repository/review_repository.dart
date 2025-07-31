import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby_finder_app/data/model/review.dart';

class ReviewRepository {
  final _firestore = FirebaseFirestore.instance;

  // 특정 장소의 모든 리뷰 볼러오기
  Future<List<Review>> fetchReviews(String locationTitle) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('locationTitle', isEqualTo: locationTitle)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // 리뷰 추가하기
  Future<void> addReview(Review review) async {
    try {
      await _firestore.collection('reviews').add(review.toFirestore());
    } catch (e) {
      print('Error adding review: $e');
    }
  }
}
