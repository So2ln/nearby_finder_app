// lib/viewmodels/review_viewmodel.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/review.dart';
import 'package:nearby_finder_app/data/repository/review_repository.dart';

final reviewViewModelProvider =
    AsyncNotifierProvider.family<ReviewViewModel, List<Review>, String>(() {
      return ReviewViewModel();
    });

class ReviewViewModel extends FamilyAsyncNotifier<List<Review>, String> {
  // family의 파라미터(arg)는 build 메서드에서 접근 가능함
  @override
  FutureOr<List<Review>> build(String locationId) {
    // 초기 리뷰 목록을 가져오기
    return ref.read(reviewRepositoryProvider).getReviews(locationId);
  }

  // 리뷰를 추가하는 메서드
  Future<void> addReview(String content, int rating) async {
    //별점 파라미터 추가
    final locationId = arg; // family로부터 받은 locationId

    final newReview = Review(
      content: content,
      locationId: locationId,
      createdAt: DateTime.now(),
      rating: rating, // 별점 할당해줌
    );

    // 현재 상태를 로딩 중으로 업데이트--> 사용자에게 피드백을 줌
    state = const AsyncValue.loading();

    // 낙관적 업데이트: UI에 먼저 반영하는거라네....
    // state = AsyncValue.data([...state.value!, newReview]);

    // Repository를 통해 Firestore에 저장
    await ref.read(reviewRepositoryProvider).addReview(newReview);

    // 상태를 새로고침하여 최신 목록을 다시 불러옴
    ref.invalidateSelf();
    await future; // build 메서드가 완료될 때까지 기다림
  }
}
