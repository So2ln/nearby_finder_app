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
      ref.read(searchKeywordProvider.notifier).state = keyword;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '주요 지역/건물명, 지하철역 검색',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: '예: 수원, 스타필드, 강남역',
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: asyncValue.isLoading ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                  ),
                  child: asyncValue.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('검색', style: TextStyle(fontSize: 16)),
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
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('검색 결과가 없습니다.', style: TextStyle(fontSize: 18)),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('에러 발생: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
