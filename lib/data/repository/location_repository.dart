import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/data/model/location.dart';

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
      /*
       print() 사용 시 "Don't invoke 'print'" 경고가 뜨는 이유는 Flutter 린트 규칙(lint rules)때문임.
       print()는 디버깅 목적으로는 간단하지만, 로그 출력량이 많아질 경우, 출력이 누락되거나 끊겨서
       특히 ios에서는 print()가 제대로 동작하지 않는 경우가 많음.
       그래서 flutter는 debugPrint()를 권장함
        */
      debugPrint('Search Error: $e');
      rethrow; // 에러를 다시 던져서 호출한 곳에서 처리할 수 있게 함
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});
