// lib/viewmodels/location_viewmodel.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/location.dart';
import 'package:nearby_finder_app/data/repository/location_repository.dart';

// 현재 검색 키워드를 관리하는 간단한 상태 프로바이더
final searchKeywordProvider = StateProvider<String>((ref) => '');

// 비동기 데이터를 관리하는 주력 ViewModel
final locationViewModelProvider =
    AsyncNotifierProvider<LocationViewModel, List<Location>>(() {
      return LocationViewModel();
    });

class LocationViewModel extends AsyncNotifier<List<Location>> {
  @override
  FutureOr<List<Location>> build() {
    // build 메서드는 초기 데이터를 반환하거나, 다른 Provider를 watch하여
    // 해당 Provider의 값이 변경될 때마다 재실행됩니다.
    final keyword = ref.watch(searchKeywordProvider);
    return ref.read(locationRepositoryProvider).searchLocations(keyword);
  }
}
