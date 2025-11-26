import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../../../config/environment/env.dart';

class MapboxPlacesService {
  final Dio _dio;
  final String _accessToken;

  MapboxPlacesService({Dio? dio})
      : _dio = dio ?? Dio(),
        _accessToken = Env.mapboxAccessToken {
    if (_accessToken.isEmpty) {
      throw Exception('MAPBOX_ACCESS_TOKEN no está configurada');
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces({
    required String query,
    double? proximityLat,
    double? proximityLon,
    List<String>? types,
  }) async {
    try {
      final url = '${ApiConstants.mapboxBaseUrl}${ApiConstants.mapboxSearchEndpoint}/$query.json';

      final queryParams = <String, dynamic>{
        'access_token': _accessToken,
      };

      if (proximityLat != null && proximityLon != null) {
        queryParams['proximity'] = '$proximityLon,$proximityLat';
      }

      if (types != null && types.isNotEmpty) {
        queryParams['types'] = types.join(',');
      }

      final response = await _dio.get(url, queryParameters: queryParams);

      final features = response.data['features'] as List<dynamic>? ?? [];
      return features.map((f) => f as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error al buscar lugares: ${e.toString()}');
    }
  }
}


