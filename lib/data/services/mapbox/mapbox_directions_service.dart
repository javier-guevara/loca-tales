import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../config/constants/api_constants.dart';
import '../../../config/environment/env.dart';
import '../../models/mapbox/directions_response_dto.dart';

class MapboxDirectionsService {
  final Dio _dio;
  final String _accessToken;

  MapboxDirectionsService({Dio? dio})
      : _dio = dio ?? Dio(),
        _accessToken = Env.mapboxAccessToken {
    if (_accessToken.isEmpty) {
      throw Exception('MAPBOX_ACCESS_TOKEN no está configurada');
    }
  }

  Future<DirectionsResponseDto> getDirections({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
    required String profile, // walking, driving, cycling
  }) async {
    try {
      // Validate coordinates
      if (originLat < -90 || originLat > 90 || destLat < -90 || destLat > 90) {
        throw ArgumentError('Latitud inválida. Debe estar entre -90 y 90');
      }
      if (originLon < -180 || originLon > 180 || destLon < -180 || destLon > 180) {
        throw ArgumentError('Longitud inválida. Debe estar entre -180 y 180');
      }
      if (originLat.isNaN || originLon.isNaN || destLat.isNaN || destLon.isNaN) {
        throw ArgumentError('Las coordenadas no pueden ser NaN');
      }
      
      // Mapbox requires coordinates as lon,lat (not lat,lon)
      final coordinates = '$originLon,$originLat;$destLon,$destLat';
      
      // Build full URL: /directions/v5/mapbox/{profile}/{coordinates}
      final url = '${ApiConstants.mapboxBaseUrl}${ApiConstants.mapboxDirectionsEndpoint}/$profile/$coordinates';

      print('[MapboxDirectionsService] 📡 Requesting Mapbox Directions');
      print('[MapboxDirectionsService] Profile: $profile');
      print('[MapboxDirectionsService] Origin: lat=$originLat, lon=$originLon');
      print('[MapboxDirectionsService] Destination: lat=$destLat, lon=$destLon');
      print('[MapboxDirectionsService] Full URL: $url');

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': 'true',
        },
      );

      print('[MapboxDirectionsService] Response code: ${response.data['code']}');

      if (response.data['code'] != 'Ok') {
        throw Exception('Mapbox error: ${response.data['code']} - ${response.data['message']}');
      }

      return DirectionsResponseDto.fromJson(response.data);
    } catch (e) {
      print('[MapboxDirectionsService] ❌ Error getting directions: $e');
      
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        print('[MapboxDirectionsService] Mapbox API error - Status: $statusCode');
        
        if (responseData != null) {
          print('[MapboxDirectionsService] Response data: $responseData');
        }
        
        if (statusCode == 404) {
          throw Exception('Ruta no encontrada');
        }
        if (statusCode == 422) {
          final message = responseData?['message'] ?? 'Solicitud inválida';
          throw Exception('Error de Mapbox (422): $message');
        }
        if (statusCode == 429) {
          throw Exception('Límite de solicitudes de Mapbox alcanzado');
        }
        if (responseData != null && responseData is Map) {
          final message = responseData['message'] ?? responseData['error'];
          if (message != null) {
            throw Exception('Error de Mapbox: $message');
          }
        }
      }
      throw Exception('Error al calcular ruta: ${e.toString()}');
    }
  }
}


