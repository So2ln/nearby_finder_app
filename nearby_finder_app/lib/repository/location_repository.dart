import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/model/location.dart';

class LocationRepository {
  final Dio _dio = Dio();
  final String _clientId = 'ZT6dUtxPSqaMlPSq3AKz';
  final String _clientSecret = 'zFscQoFIHV';

  Future<List<Location>> searchLocations(String query, {int start = 1}) async {
    if (query.isEmpty) {
      return []; // 검색어가 비어있으면 빈 리스트 반환
    }
    try {
      final response = await _dio.get(
        'https://openapi.naver.com/v1/search/local.json',
        queryParameters: {'query': query, 'display': 5, 'start': start},
        options: Options(
          headers: {
            'X-Naver-Client-Id': _clientId,
            'X-Naver-Client-Secret': _clientSecret,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'];
        //받아온 item 목록을 Location 객체 목록으로 변환
        return items.map((item) => Location.fromJson(item)).toList();
      } else {
        // API 요청 실패 시 예외 처리 : 지훈 튜터님 코드 참고 ㅋㅋ
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // 에러 발생 시 (네트워크 오류 등)
      debugPrint('Search Error: $e');
      rethrow; // 에러를 다시 던져서 호출한 곳에서 처리할 수 있게 함
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});
