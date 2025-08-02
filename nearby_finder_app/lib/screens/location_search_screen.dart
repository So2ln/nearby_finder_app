// lib/screens/location_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/screens/review_screen.dart';
import '../viewmodels/location_viewmodel.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 뷰모델의 현재 키워드와 텍스트 필드를 동기화
    _controller.text = ref.read(searchKeywordProvider);
  }

  void _performSearch() {
    final keyword = _controller.text.trim();
    if (keyword.isNotEmpty) {
      // ref.read(searchKeywordProvider.notifier).state = keyword;

      // searchKeywordProvider를 직접 수정하는 대신,
      // ViewModel의 searchByKeyword 메서드를 호출한다.
      ref.read(locationViewModelProvider.notifier).searchByKeyword(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(locationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            onPressed: () {
              // viewmodel의 현재 위치 검색 메서드 호출
              ref
                  .read(locationViewModelProvider.notifier)
                  .searchCurrentLocation();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 화면을 터치하면 키보드가 내려가도록 함
          FocusScope.of(context).unfocus();
        },
        //비어있는 공간의 탭도 감지하도록 하는 기능이라고 함
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: '주요 지역/건물명, 지하철역 검색',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(
                          Icons.explore_outlined,
                          color: Colors.blue,
                          size: 30,
                        ),
                        hintText: '예: 수원, 스타필드, 강남역',
                        hintStyle: TextStyle(
                          fontSize: 16,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0, // 버튼의 vertical padding과 값을 맞춤
                          horizontal: 12.0,
                        ),

                        // 활성화 상태 (평상시) 테두리
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 3.0,
                          ),
                        ),

                        // 포커스 상태 (사용자가 터치했을 때) 테두리
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 3.0,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 65, // 버튼의 너비를 65으로 설정
                    height: 65, // 버튼의 높이를 65으로 설정
                    child: IconButton(
                      iconSize: 30,
                      // 로딩 중이 아닐 때만 버튼이 눌리도록 함
                      onPressed: asyncValue.isLoading ? null : _performSearch,
                      // 버튼 스타일 지정
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.blue,

                        // backgroundColor: Colors.blue, // 기본 배경색'
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 3,
                        ),
                        // shape 속성을 추가하고 RoundedRectangleBorder를 지정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        // 비활성화 상태일 때의 배경색
                        disabledForegroundColor: Colors.grey,
                      ),
                      // 로딩 상태에 따라 아이콘 변경
                      icon: asyncValue.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.blue,
                              ),
                            )
                          : const Icon(
                              Icons.search,
                              size: 30, // 아이콘 크기 조정
                              color: Colors.blue, // 아이콘 색상
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // 검색창과 결과 목록 사이의 간격
              // 3. 검색 결과 목록을 담는 Expanded 위젯
              Expanded(
                child: asyncValue.when(
                  data: (locations) {
                    if (locations.isEmpty &&
                        ref.watch(searchKeywordProvider).isNotEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '검색 결과가 없습니다.',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(location.title),
                            subtitle: Text(location.roadAddress),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReviewScreen(location: location),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('에러 발생: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
