import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';

class SharedPreferencesService {
  static const String _travelPlansKey = 'travel_plans';
  static const String _favoritePlacesKey = 'favorite_places';

  Future<void> saveTravelPlan(TravelPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = await getTravelPlans();
    plans.add(plan);
    
    final jsonList = plans.map((p) => _travelPlanToJson(p)).toList();
    await prefs.setString(_travelPlansKey, jsonEncode(jsonList));
  }

  Future<List<TravelPlan>> getTravelPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_travelPlansKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      // Note: Full deserialization would require implementing fromJson for TravelPlan
      // For now, return empty list - this would need proper serialization
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavoritePlace(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoritePlaces();
    if (!favorites.any((p) => p.id == place.id)) {
      favorites.add(place);
      
      final jsonList = favorites.map((p) => _placeToJson(p)).toList();
      await prefs.setString(_favoritePlacesKey, jsonEncode(jsonList));
    }
  }

  Future<List<Place>> getFavoritePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritePlacesKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      // Note: Full deserialization would require implementing fromJson for Place
      // For now, return empty list - this would need proper serialization
      return [];
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _travelPlanToJson(TravelPlan plan) {
    return {
      'id': plan.id,
      'city': plan.city,
      'startDate': plan.startDate.toIso8601String(),
      'endDate': plan.endDate.toIso8601String(),
      // Add other fields as needed
    };
  }

  Map<String, dynamic> _placeToJson(Place place) {
    return {
      'id': place.id,
      'name': place.name,
      'description': place.description,
      'latitude': place.location.latitude,
      'longitude': place.location.longitude,
      // Add other fields as needed
    };
  }
}


