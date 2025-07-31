// ConsumerWidget을 상속받아야 ref를 사용할 수 있음
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/home/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch: homeViewModelProvider의 상태(HomeState)를 지켜보다
    // 변경되면 HomePage를 다시 빌드함 (rebuild)
    final homeState = ref.watch(HomeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: '지역을 검색해주세요',
            border: InputBorder.none,
          ),
          // 검색 버튼을 눌렀을 때
          onSubmitted: (query) {
            // ref.read(...).notifier: ViewModel의 매서드를 호출할 때 사용
            ref.read(HomeViewModelProvider.notifier).search(query);
          },
        ),
      ),
      body: homeState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: homeState.locations.length,
              itemBuilder: (context, index) {
                final location = homeState.locations[index];
                return ListTile(
                  title: Text(location.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.roadAddress),
                      Text(
                        location.category,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: 3번 과제 - 리뷰 페이지로 이동하는 로직 구현
                  },
                );
              },
            ),
    );
  }
}
