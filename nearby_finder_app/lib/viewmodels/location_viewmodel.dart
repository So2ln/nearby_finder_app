// lib/viewmodels/location_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:nearby_finder_app/data/model/location.dart';
import 'package:nearby_finder_app/data/repository/location_repository.dart';
import 'package:nearby_finder_app/data/repository/vworld_repository.dart';

// 현재 검색 키워드를 관리하는 간단한 StateProvider
final searchKeywordProvider = StateProvider<String>((ref) => '');

// 비동기 데이터를 관리하는 주력 ViewModel
final locationViewModelProvider =
    AsyncNotifierProvider<LocationViewModel, List<Location>>(() {
      return LocationViewModel();
    });

class LocationViewModel extends AsyncNotifier<List<Location>> {
  @override
  FutureOr<List<Location>> build() {
    // // build 메서드는 초기 데이터를 반환하거나, 다른 Provider를 watch하여
    // // 해당 Provider의 값이 변경될 때마다 재실행? 호출됨
    // final keyword = ref.watch(searchKeywordProvider);
    // return ref.read(locationRepositoryProvider).searchLocations(keyword);

    // build 메서드는 비어있는 초기 상태만 반환하도록 단순화하기!!!!
    return [];
  }

  // A. 키워드 검색을 위한 별도 메서드 생성
  Future<void> searchByKeyword(String keyword) async {
    // 키워드가 비어있으면 아무것도 하지 않음
    if (keyword.isEmpty) return;

    // 로딩 상태를 명시적으로 UI에 알림
    state = const AsyncValue.loading();
    try {
      final locations = await ref
          .read(locationRepositoryProvider)
          .searchLocations(keyword);
      state = AsyncValue.data(locations);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // B. 현재 위치 검색 메서드 수정
  Future<void> searchCurrentLocation() async {
    // 로딩 상태로 변환하여 UI에 알림
    state = const AsyncValue.loading();
    try {
      // 1. 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.');
      }

      // 2. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 변경해주세요.');
      }

      // 3. 현재 위치 가져오기
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('위치 정보를 가져오는 시간이 초과되었습니다. 다시 시도해주세요.'),
          );

      // print('현재 위치: 위도=${position.latitude}, 경도=${position.longitude}');

      String? address;

      // 먼저 geocoding 패키지로 시도 (전 세계 지원)
      try {
        // print('geocoding 패키지로 주소 변환 시도');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          // 주소 형식 조합
          List<String> addressParts = [];
          if (place.country != null) addressParts.add(place.country!);
          if (place.administrativeArea != null) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.locality != null) addressParts.add(place.locality!);
          if (place.subLocality != null) addressParts.add(place.subLocality!);
          if (place.thoroughfare != null) addressParts.add(place.thoroughfare!);

          address = addressParts.join(' ');
          // print('geocoding으로 변환된 주소: $address');
        }
      } catch (e) {
        debugPrint('geocoding 실패: $e');
      }

      // geocoding 실패 시 VWORLD API 시도 (한국만 지원)
      if ((address == null || address.isEmpty) &&
          position.latitude >= 33.0 &&
          position.latitude <= 43.0 &&
          position.longitude >= 124.0 &&
          position.longitude <= 132.0) {
        // print('한국 좌표 범위 내, VWORLD API 시도');
        address = await ref
            .read(vworldRepositoryProvider)
            .getAddressFromCoords(
              lat: position.latitude,
              lon: position.longitude,
            );
        if (address != null) {
          // print('VWORLD API로 변환된 주소: $address');
        }
      }

      if (address == null || address.isEmpty) {
        // // 모든 방법이 실패한 경우 좌표로 직접 검색
        // // print('주소 변환 실패, 좌표로 직접 검색');
        // final fallbackKeyword =
        //     '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
        // ref.read(searchKeywordProvider.notifier).state = fallbackKeyword;
        // return;

        throw Exception('현재 위치의 주소를 찾을 수 없습니다.');
      }

      // print('최종 변환된 주소: $address');

      // 5. 변환된 주소로 네이버 API 검색
      // ref.read(searchKeywordProvider.notifier).state = address;

      // 핵심 변경: 변환된 주소로 바로 검색하고 그 결과를 state에 반영
      // searchKeywordProvider를 업데이트하는 대신, 직접 검색 로직을 수행합니다.
      final locations = await ref
          .read(locationRepositoryProvider)
          .searchLocations(address);
      state = AsyncValue.data(locations);
    } catch (e, s) {
      debugPrint('searchCurrentLocation 에러: $e');
      state = AsyncValue.error(e, s);
    }
  }
}
