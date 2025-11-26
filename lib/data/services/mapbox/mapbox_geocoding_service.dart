import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../../../config/environment/env.dart';
import '../../models/mapbox/geocoding_response_dto.dart';

class MapboxGeocodingService {
  final Dio _dio;
  final String _accessToken;

  MapboxGeocodingService({Dio? dio})
      : _dio = dio ?? Dio(),
        _accessToken = Env.mapboxAccessToken {
    if (_accessToken.isEmpty) {
      throw Exception('MAPBOX_ACCESS_TOKEN no está configurada');
    }
  }

  Future<GeocodingResponseDto> geocode(String address) async {
    try {
      final url = '${ApiConstants.mapboxBaseUrl}${ApiConstants.mapboxGeocodingEndpoint}/$address.json';

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _accessToken,
        },
      );

      return GeocodingResponseDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al geocodificar dirección: ${e.toString()}');
    }
  }

  Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final url = '${ApiConstants.mapboxBaseUrl}${ApiConstants.mapboxGeocodingEndpoint}/$lon,$lat.json';

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _accessToken,
        },
      );

      final geocodingResponse = GeocodingResponseDto.fromJson(response.data);
      return geocodingResponse.features?.firstOrNull?.placeName ?? 'Dirección no encontrada';
    } catch (e) {
      throw Exception('Error en geocodificación inversa: ${e.toString()}');
    }
  }
}


