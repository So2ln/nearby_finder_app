import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/location.dart';
import 'package:nearby_finder_app/data/repository/location_repository.dart';

// 1. ViewModel이 관리할 상태 클래스
class HomeState {
  final bool isLoading;
  final List<Location> locations;

  HomeState({this.isLoading = false, this.locations = const []});
  HomeState copyWith({bool? isLoading, List<Location>? locations}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
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
    state = state.copyWith(isLoading: true);

    // 2. Repository를 통해 데이터 검색
    final locations = await _repository.searchLocations(query);

    // 3. 로딩을 끝내고, 받아온 데이터로 상태 업데이트 후 화면에 알림
    state = state.copyWith(isLoading: false, locations: locations);
  }
}

// 3. Provider: 이 ViewModel을 UI 어디서든 접근할 수 있게 해주는 통로
final HomeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
