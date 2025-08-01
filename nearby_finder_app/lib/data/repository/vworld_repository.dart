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
      final response = await _dio.get(
        _apiUrl,
        queryParameters: {
          'service': 'address',
          'request': 'getAddress',
          'key': _apiKey,
          'point': '$lon,$lat', // 경도, 위도 순서
          'type': 'ROAD',
          'zipcode': 'false',
        },
      );
      if (response.statusCode == 200 &&
          response.data['response']['status'] == 'OK') {
        return response.data['response']['result'][0]['text'];
      }
      return null;
    } catch (e) {
      debugPrint('VWORLD API 에러: $e');
      return null;
    }
  }
}

final vworldRepositoryProvider = Provider((ref) => VworldRepository());
