import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/location.dart';
import 'package:nearby_finder_app/data/repository/location_repository.dart';

// 1. ViewModel이 관리할 상태 클래스
class HomeState {
  final bool isLoading;
  final bool isLoadingNextPage; // 다음 페이지 로딩 여부
  final List<Location> locations; // 검색 결과
  final String query; // 현재 검색어
  final int nextPageStart; // 다음 페이지 시작 위치
  final bool hasNextPage; // 다음 페이지가 있는지 여부

  HomeState({
    this.isLoading = false,
    this.isLoadingNextPage = false,
    this.locations = const [],
    this.query = '',
    this.nextPageStart = 1,
    this.hasNextPage = false,
  });
  HomeState copyWith({
    bool? isLoading,
    bool? isLoadingNextPage,
    List<Location>? locations,
    String? query,
    int? nextPageStart,
    bool? hasNextPage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      query: query ?? this.query,
      nextPageStart: nextPageStart ?? this.nextPageStart,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

// 2. ViewModel 클래스 (Notifier 상속)
class HomeViewModel extends Notifier<HomeState> {
  late final LocationRepository _repository;

  @override
  HomeState build() {
    _repository = LocationRepository();
    // 최초 상태는 로딩도 아니고, 데이터도 없는 상태
    return HomeState();
  }

  // 검색 로직
  Future<void> search(String query) async {
    // 1. 로딩 상태로 변경하고 화면에 알림
    state = state.copyWith(isLoading: true, query: query);

    // 2. Repository를 통해 데이터 검색
    // final locations = await _repository.searchLocations(query);
    final newLocations = await _repository.searchLocations(query, start: 1);

    // 3. 로딩을 끝내고, 받아온 데이터로 상태 업데이트 후 화면에 알림
    state = state.copyWith(
      isLoading: false,
      locations: newLocations,
      nextPageStart: 6,
      hasNextPage: newLocations.length == 5,
    );
  }

  // 다음 페이지 로딩 로직
  Future<void> loadNextPage() async {
    // 이미 로딩 중이거나, 다음 페이지가 없으면 리턴
    if (state.isLoadingNextPage || !state.hasNextPage) return;

    state = state.copyWith(isLoadingNextPage: true);

    final newLocations = await _repository.searchLocations(
      state.query,
      start: state.nextPageStart,
    );

    state = state.copyWith(
      isLoadingNextPage: false,
      locations: [...state.locations, ...newLocations],
      nextPageStart: state.nextPageStart + 5, // 다음 페이지 시작 위치 업데이트
      hasNextPage: newLocations.length == 5, // 다음 페이지가 있는지 여부 업데이트
    );
  }
}

// 3. Provider: 이 ViewModel을 UI 어디서든 접근할 수 있게 해주는 통로
final HomeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
