// lib/viewmodels/location_viewmodel.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearby_finder_app/data/model/location.dart';
import 'package:nearby_finder_app/data/repository/location_repository.dart';
import 'package:nearby_finder_app/data/repository/vworld_repository.dart';

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

  // 현재 위치 검색 메서드 추가
  Future<void> searchCurrentLocation() async {
    state = const AsyncValue.loading(); // 로딩 상태로 변경
    try {
      // 1. 위치 권한 확인 및 현재 좌표 가져오기
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // 위 deprecated 메서드 대신 아래와 같이 사용 (곧 없어지는 기능이래)
      // desiredAccuracy 대신 LocationSettings 객체를 사용한다.
      final LocationSettings locationSettings = LocationSettings(
        accuracy:
            LocationAccuracy.high, // 👈 desiredAccuracy가 accuracy로 이름이 변경되었습니다.
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // 2. VWORLD API로 좌표 -> 주소 변환
      final address = await ref
          .read(vworldRepositoryProvider)
          .getAddressFromCoords(
            lat: position.latitude,
            lon: position.longitude,
          );

      if (address == null) {
        throw Exception('현재 위치의 주소를 가져올 수 없습니다.');
      }

      // 3. 변환된 주소로 네이버 API 검색
      ref.read(searchKeywordProvider.notifier).state = address;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
