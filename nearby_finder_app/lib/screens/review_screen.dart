// lib/screens/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nearby_finder_app/data/model/location.dart';
import '../viewmodels/review_viewmodel.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final Location location;
  const ReviewScreen({super.key, required this.location});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _reviewController = TextEditingController();
  // location 객체로부터 고유 ID 생성
  late final String locationId =
      "${widget.location.mapx}_${widget.location.mapy}";

  void _addReview() {
    final content = _reviewController.text.trim();
    if (content.isNotEmpty) {
      ref.read(reviewViewModelProvider(locationId).notifier).addReview(content);
      _reviewController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewViewModelProvider(locationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.location.title} 리뷰',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: reviewState.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const Center(
                    child: Text(
                      '아직 작성된 리뷰가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      child: ListTile(
                        title: Text(review.content),
                        subtitle: Text(
                          DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(review.createdAt),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('리뷰를 불러오는 중 에러 발생: $err')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: '리뷰를 남겨주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addReview,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
