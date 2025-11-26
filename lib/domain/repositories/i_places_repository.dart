import '../models/place.dart';
import '../models/location.dart';

abstract class IPlacesRepository {
  Future<List<Place>> searchPlaces({
    required String query,
    Location? proximity,
  });

  Future<Place> getPlaceDetails(String placeId);

  Future<void> saveFavoritePlace(Place place);

  Future<List<Place>> getFavoritePlaces();
}


