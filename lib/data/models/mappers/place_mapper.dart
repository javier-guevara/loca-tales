import 'dart:developer' as developer;
import '../../../domain/models/place.dart';
import '../../../domain/models/location.dart';

class PlaceMapper {
  static Place fromGeminiPlace(Map<String, dynamic> json) {
    try {
      final name = json['name'] as String? ?? '';
      final categoryString = (json['category'] as String? ?? 'attraction').toLowerCase();
      final category = _parseCategory(categoryString);
      final latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      final longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;

      // Validate required fields
      if (name.isEmpty) {
        throw Exception('Place name is empty');
      }

      // Validate coordinates
      if (latitude == 0.0 && longitude == 0.0) {
        developer.log(
          'Warning: Place "$name" has invalid coordinates (0,0)',
          name: 'PlaceMapper',
          level: 900,
        );
      }

      return Place(
        id: _generatePlaceId(name),
        name: name,
        description: json['description'] as String? ?? '',
        location: Location(
          latitude: latitude,
          longitude: longitude,
        ),
        category: category,
        rating: (json['rating'] as num?)?.toDouble(),
        imageUrl: json['imageUrl'] as String?,
        openingHours: json['openingHours'] as String?,
        estimatedDuration: json['estimatedDuration'] as String?,
        priceLevel: (json['priceLevel'] as num?)?.toInt(),
      );
    } catch (e) {
      developer.log(
        'Error parsing place from Gemini',
        name: 'PlaceMapper',
        error: e,
      );
      rethrow;
    }
  }

  static Place fromMapboxFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

    return Place(
      id: feature['id'] as String? ?? _generatePlaceId(properties['name'] as String? ?? ''),
      name: properties['name'] as String? ?? '',
      description: properties['description'] as String? ?? '',
      location: Location(
        latitude: coordinates.isNotEmpty ? (coordinates[1] as num).toDouble() : 0.0,
        longitude: coordinates.isNotEmpty ? (coordinates[0] as num).toDouble() : 0.0,
        address: properties['address'] as String?,
      ),
      category: _parseCategory(properties['category'] as String? ?? 'attraction'),
      rating: (properties['rating'] as num?)?.toDouble(),
      imageUrl: properties['imageUrl'] as String?,
    );
  }

  static PlaceCategory _parseCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'attraction':
        return PlaceCategory.attraction;
      case 'restaurant':
        return PlaceCategory.restaurant;
      case 'hotel':
        return PlaceCategory.hotel;
      case 'transport':
        return PlaceCategory.transport;
      case 'shopping':
        return PlaceCategory.shopping;
      case 'entertainment':
        return PlaceCategory.entertainment;
      case 'nature':
        return PlaceCategory.nature;
      case 'culture':
        return PlaceCategory.culture;
      default:
        return PlaceCategory.attraction;
    }
  }

  static String _generatePlaceId(String name) {
    return '${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
  }
}


