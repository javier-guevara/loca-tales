import '../../domain/repositories/i_places_repository.dart';
import '../../domain/models/place.dart';
import '../../domain/models/location.dart';
import '../services/mapbox/mapbox_places_service.dart';
import '../services/local/shared_preferences_service.dart';
import '../models/mappers/place_mapper.dart';

class PlacesRepositoryImpl implements IPlacesRepository {
  final MapboxPlacesService _placesService;
  final SharedPreferencesService _prefsService;

  PlacesRepositoryImpl({
    required MapboxPlacesService placesService,
    required SharedPreferencesService prefsService,
  })  : _placesService = placesService,
        _prefsService = prefsService;

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    Location? proximity,
  }) async {
    try {
      final results = await _placesService.searchPlaces(
        query: query,
        proximityLat: proximity?.latitude,
        proximityLon: proximity?.longitude,
      );

      return results
          .map((feature) => PlaceMapper.fromMapboxFeature(feature))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar lugares: ${e.toString()}');
    }
  }

  @override
  Future<Place> getPlaceDetails(String placeId) async {
    // For now, search for the place by ID
    // In a real implementation, you'd have a dedicated endpoint
    final results = await searchPlaces(query: placeId);
    if (results.isEmpty) {
      throw Exception('Lugar no encontrado');
    }
    return results.first;
  }

  @override
  Future<void> saveFavoritePlace(Place place) async {
    await _prefsService.saveFavoritePlace(place);
  }

  @override
  Future<List<Place>> getFavoritePlaces() async {
    return await _prefsService.getFavoritePlaces();
  }
}


