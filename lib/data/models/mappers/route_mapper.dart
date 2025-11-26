import '../../models/mapbox/directions_response_dto.dart';
import '../../../domain/models/route_info.dart';

class RouteMapper {
  static RouteInfo fromMapboxDirections({
    required DirectionsResponseDto response,
    required TransportMode transportMode,
  }) {
    final route = response.routes?.firstOrNull;
    if (route == null) {
      throw Exception('No se encontró ruta en la respuesta de Mapbox');
    }

    // Convert distance from meters to kilometers
    final distance = (route.distance ?? 0.0) / 1000.0;

    // Convert duration from seconds to Duration
    final duration = Duration(seconds: (route.duration ?? 0).toInt());

    // Extract polyline from geometry
    String polyline = '';
    if (route.geometry?.coordinates != null) {
      // Mapbox returns coordinates as [lon, lat] pairs
      final coords = route.geometry!.coordinates!;
      polyline = _encodePolyline(coords);
    }

    // Extract steps with instructions
    final stepsList = route.legs
        ?.expand((leg) => leg.steps ?? [])
        .map((step) => step.maneuver?.instruction ?? step.name ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final steps = stepsList != null && stepsList.isNotEmpty 
        ? List<String>.from(stepsList) 
        : null;

    return RouteInfo(
      distance: distance,
      duration: duration,
      transportMode: transportMode,
      polyline: polyline,
      steps: steps,
    );
  }

  // Simple polyline encoding (for production, use a proper polyline encoder)
  static String _encodePolyline(List<List<double>> coordinates) {
    // This is a simplified version. In production, use the polyline package
    return coordinates.map((coord) => '${coord[1]},${coord[0]}').join(';');
  }
}

