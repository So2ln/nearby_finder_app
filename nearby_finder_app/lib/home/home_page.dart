// ConsumerWidget을 상속받아야 ref를 사용할 수 있음
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/home/home_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 2. scrollcontroller를 사용하여 스크롤 이벤트를 감지할 수 있음
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 스크롤 이벤트를 감지하여 다음 페이지를 불러오는 로직
    _scrollController.addListener(() {
      // 스크롤이 끝에 도달했을 때
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // 다음 페이지를 불러오는 로직
        ref.read(HomeViewModelProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 4. 스크롤 컨트롤러를 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller:
                  _scrollController, //--> listview에 scrollcontroller를 연결
              itemCount:
                  homeState.locations.length +
                  (homeState.hasNextPage ? 1 : 0), // 다음 페이지가 있다면 +1
              itemBuilder: (context, index) {
                if (index == homeState.locations.length) {
                  // 다음 페이지 로딩 중일 때 로딩 인디케이터 표시
                  if (index == homeState.locations.length) {
                    return homeState.isLoadingNextPage
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox.shrink();
                  }
                  // 마지막 아이템이 아닌 경우
                }
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
