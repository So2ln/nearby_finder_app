import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id; // Firestore document ID
  final String content; // Review content
  final String locationId; // 어떤 장소의 리뷰인지 식별하기 위해 추가
  final DateTime createdAt; // 작성 시간

  Review({
    this.id,
    required this.content,
    required this.locationId,
    required this.createdAt,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Review(
      id: doc.id,
      content: data['content'],
      locationId: data['locationId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'locationId': locationId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
