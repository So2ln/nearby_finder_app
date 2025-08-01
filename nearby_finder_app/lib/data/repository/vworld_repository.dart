import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VworldRepository {
  final Dio _dio = Dio();
  static const String _apiUrl = 'https://api.vworld.kr/req/address';
  static const String _apiKey =
      '92CC286C-59C1-31FE-BA4D-DEB07A8C1C54'; // VWORLD에서 발급받은 키

  Future<String?> getAddressFromCoords({
    required double lat,
    required double lon,
  }) async {
    try {
      final queryParams = {
        'service': 'address',
        'request': 'getAddress',
        'key': _apiKey,
        'point': '$lon,$lat', // 경도, 위도 순서
        'type': 'ROAD',
        'zipcode': 'false',
      };
      
      debugPrint('VWORLD API 요청 URL: $_apiUrl');
      debugPrint('VWORLD API 파라미터: $queryParams');
      
      final response = await _dio.get(
        _apiUrl,
        queryParameters: queryParams,
      );

      debugPrint('VWORLD API Response Status: ${response.statusCode}');
      debugPrint('VWORLD API Response: ${response.data}'); // 디버깅용 로그 출력

      if (response.statusCode == 200) {
        final responseData = response.data;

        // 응답 구조 확인
        if (responseData['response'] != null) {
          debugPrint('Response status: ${responseData['response']['status']}');
          
          if (responseData['response']['status'] == 'OK' &&
              responseData['response']['result'] != null &&
              responseData['response']['result'].isNotEmpty) {
            final result = responseData['response']['result'][0];
            String? address = result['text'];

            if (address != null && address.isNotEmpty) {
              debugPrint('주소 변환 성공: $address');
              return address;
            }
          } else {
            debugPrint('VWORLD API 오류: ${responseData['response']['status']}');
            if (responseData['response']['error'] != null) {
              debugPrint('오류 메시지: ${responseData['response']['error']}');
            }
          }
        }

        debugPrint('VWORLD API 응답은 성공했지만 주소를 찾을 수 없습니다.');
      }

      return null;
    } catch (e) {
      debugPrint('VWORLD API 에러: $e');
      return null;
    }
  }
}

final vworldRepositoryProvider = Provider((ref) => VworldRepository());
