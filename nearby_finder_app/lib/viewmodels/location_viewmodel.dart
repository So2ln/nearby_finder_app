// lib/viewmodels/location_viewmodel.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
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

      print('현재 위치: 위도=${position.latitude}, 경도=${position.longitude}');

      // 4. VWORLD API로 좌표 -> 주소 변환 시도
      String? address = await ref
          .read(vworldRepositoryProvider)
          .getAddressFromCoords(
            lat: position.latitude,
            lon: position.longitude,
          );

      // VWORLD API 실패 시 geocoding 패키지 사용
      if (address == null || address.isEmpty) {
        print('VWORLD API 실패, geocoding 패키지로 재시도');
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, 
            position.longitude
          );
          
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            
            // 한국 주소 형식으로 조합
            List<String> addressParts = [];
            if (place.administrativeArea != null) addressParts.add(place.administrativeArea!);
            if (place.locality != null) addressParts.add(place.locality!);
            if (place.subLocality != null) addressParts.add(place.subLocality!);
            if (place.thoroughfare != null) addressParts.add(place.thoroughfare!);
            
            address = addressParts.join(' ');
            print('geocoding으로 변환된 주소: $address');
          }
        } catch (e) {
          print('geocoding도 실패: $e');
        }
      }

      if (address == null || address.isEmpty) {
        // 모든 방법이 실패한 경우 좌표로 직접 검색
        print('주소 변환 실패, 좌표로 직접 검색');
        final fallbackKeyword = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
        ref.read(searchKeywordProvider.notifier).state = fallbackKeyword;
        return;
      }

      print('최종 변환된 주소: $address');

      // 5. 변환된 주소로 네이버 API 검색
      ref.read(searchKeywordProvider.notifier).state = address;
    } catch (e) {
      print('searchCurrentLocation 에러: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
