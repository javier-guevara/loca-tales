import '../models/place.dart';
import '../repositories/i_places_repository.dart';

class SearchPlacesUseCase {
  final IPlacesRepository _repository;

  SearchPlacesUseCase(this._repository);

  Future<List<Place>> call({
    required String query,
    PlaceCategory? category,
    double? minRating,
    double? radiusInKm,
  }) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('La búsqueda no puede estar vacía');
    }

    try {
      final results = await _repository.searchPlaces(
        query: query,
        proximity: null, // TODO: Add proximity support
      );

      // Filter by category if specified
      var filtered = results;
      if (category != null) {
        filtered = filtered.where((place) => place.category == category).toList();
      }

      // Filter by rating if specified
      if (minRating != null) {
        filtered = filtered.where((place) {
          return place.rating != null && place.rating! >= minRating;
        }).toList();
      }

      // Sort by rating (highest first)
      filtered.sort((a, b) {
        final ratingA = a.rating ?? 0.0;
        final ratingB = b.rating ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      return filtered;
    } catch (e) {
      throw Exception('Error al buscar lugares: ${e.toString()}');
    }
  }
}


