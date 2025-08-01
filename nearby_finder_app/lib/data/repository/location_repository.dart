import 'package:dio/dio.dart';
import 'package:nearby_finder_app/data/model/location.dart';

class LocationRepository {
  final Dio _dio = Dio();
  final String _clientId = 'ZT6dUtxPSqaMlPSq3AKz';
  final String _clientSecret = 'zFscQoFIHV';

  Future<List<Location>> searchLocations(String query, {int start = 1}) async {
    try {
      final response = await _dio.get(
        'https://openapi.naver.com/v1/search/local.json',
        queryParameters: {'query': query, 'display': 50, 'start': start},
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
        // API 요청 실패 시 빈 리스트 반환
        return [];
      }
    } catch (e) {
      // 에러 발생 시 (네트워크 오류 등)
      print('Search Error: $e');
      return [];
    }
  }
}
