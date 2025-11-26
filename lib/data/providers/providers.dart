import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/repositories/i_map_repository.dart';
import '../../domain/repositories/i_places_repository.dart';
import '../../domain/use_cases/generate_travel_plan_use_case.dart';
import '../../domain/use_cases/optimize_route_use_case.dart';
import '../../domain/use_cases/search_places_use_case.dart';
import '../../domain/models/travel_plan.dart';
import '../../domain/models/place.dart';
import '../repositories/chat_repository_impl.dart';
import '../repositories/map_repository_impl.dart';
import '../repositories/places_repository_impl.dart';
import '../services/gemini/gemini_service.dart';
import '../services/mapbox/mapbox_directions_service.dart';
import '../services/mapbox/mapbox_geocoding_service.dart';
import '../services/mapbox/mapbox_places_service.dart';
import '../services/local/shared_preferences_service.dart';
import '../services/location/location_service.dart';
import 'package:dio/dio.dart';

part 'providers.g.dart';

// Services
@riverpod
GeminiService geminiService(GeminiServiceRef ref) {
  return GeminiService();
}

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}

@riverpod
MapboxDirectionsService mapboxDirectionsService(MapboxDirectionsServiceRef ref) {
  return MapboxDirectionsService(dio: ref.watch(dioProvider));
}

@riverpod
MapboxGeocodingService mapboxGeocodingService(MapboxGeocodingServiceRef ref) {
  return MapboxGeocodingService(dio: ref.watch(dioProvider));
}

@riverpod
MapboxPlacesService mapboxPlacesService(MapboxPlacesServiceRef ref) {
  return MapboxPlacesService(dio: ref.watch(dioProvider));
}

@riverpod
SharedPreferencesService sharedPreferencesService(SharedPreferencesServiceRef ref) {
  return SharedPreferencesService();
}

@riverpod
LocationService locationService(LocationServiceRef ref) {
  return LocationService();
}

// Repositories
@riverpod
IChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl(
    geminiService: ref.watch(geminiServiceProvider),
    prefsService: ref.watch(sharedPreferencesServiceProvider),
  );
}

@riverpod
IMapRepository mapRepository(MapRepositoryRef ref) {
  return MapRepositoryImpl(
    directionsService: ref.watch(mapboxDirectionsServiceProvider),
    geocodingService: ref.watch(mapboxGeocodingServiceProvider),
    placesService: ref.watch(mapboxPlacesServiceProvider),
  );
}

@riverpod
IPlacesRepository placesRepository(PlacesRepositoryRef ref) {
  return PlacesRepositoryImpl(
    placesService: ref.watch(mapboxPlacesServiceProvider),
    prefsService: ref.watch(sharedPreferencesServiceProvider),
  );
}

// Use Cases
@riverpod
GenerateTravelPlanUseCase generateTravelPlanUseCase(GenerateTravelPlanUseCaseRef ref) {
  return GenerateTravelPlanUseCase(
    ref.watch(chatRepositoryProvider),
  );
}

@riverpod
OptimizeRouteUseCase optimizeRouteUseCase(OptimizeRouteUseCaseRef ref) {
  return OptimizeRouteUseCase(
    ref.watch(mapRepositoryProvider),
  );
}

@riverpod
SearchPlacesUseCase searchPlacesUseCase(SearchPlacesUseCaseRef ref) {
  return SearchPlacesUseCase(
    ref.watch(placesRepositoryProvider),
  );
}

// Map ViewModel Provider - Imported from ui/map/view_model
// Note: MapViewModel is defined in lib/ui/map/view_model/map_view_model.dart

// Plan Detail ViewModel Provider  
@riverpod
class PlanDetailViewModel extends _$PlanDetailViewModel {
  @override
  TravelPlan build(TravelPlan initialPlan) {
    return initialPlan;
  }

  void removePlaceFromPlan(String placeId) {
    final updatedPlaces = state.places
        .where((place) => place.id != placeId)
        .toList();

    state = state.copyWith(places: updatedPlaces);
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedPlaces = List<Place>.from(state.places);
    final place = updatedPlaces.removeAt(oldIndex);
    updatedPlaces.insert(newIndex, place);

    state = state.copyWith(places: updatedPlaces);
  }

  Future<void> savePlan() async {
    // Save to local storage
  }

  Future<void> sharePlan() async {
    // Share functionality
  }
}

