import 'dart:convert';
import 'dart:developer' as developer;
import '../../models/gemini/gemini_response_dto.dart';
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';
import '../../../domain/models/location.dart';
import 'place_mapper.dart';

class TravelPlanMapper {
  static TravelPlan fromGeminiResponse({
    required GeminiResponseDto response,
    required String city,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      // Extract JSON from response
      final text = response.candidates?.firstOrNull?.content?.parts?.firstOrNull?.text;
      
      developer.log('Raw Gemini response text: $text', name: 'TravelPlanMapper');
      
      if (text == null || text.isEmpty) {
        throw Exception('Respuesta de Gemini vacía');
      }

      // Clean the response text (remove markdown code blocks if present)
      final cleanedText = _cleanJsonResponse(text);
      
      developer.log('Cleaned JSON text: $cleanedText', name: 'TravelPlanMapper');

      // Parse JSON
      final jsonData = jsonDecode(cleanedText) as Map<String, dynamic>;

      // Validate required fields
      if (!jsonData.containsKey('places') || jsonData['places'] is! List) {
        throw Exception('La respuesta no contiene lugares válidos');
      }

      // Parse places
      final placesJson = jsonData['places'] as List<dynamic>;
      
      if (placesJson.isEmpty) {
        throw Exception('No se generaron lugares en el plan');
      }
      
      final places = placesJson
          .map((placeJson) {
            try {
              return PlaceMapper.fromGeminiPlace(placeJson as Map<String, dynamic>);
            } catch (e) {
              developer.log('Error parsing place: $e', name: 'TravelPlanMapper', error: e);
              return null;
            }
          })
          .whereType<Place>()
          .toList();

      if (places.isEmpty) {
        throw Exception('No se pudieron parsear los lugares del plan');
      }

      // Parse dates
      final parsedStartDate = startDate ?? DateTime.now();
      final parsedEndDate = endDate ?? parsedStartDate.add(const Duration(days: 3));

      // Generate ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      developer.log('Successfully parsed ${places.length} places', name: 'TravelPlanMapper');

      return TravelPlan(
        id: id,
        city: jsonData['city'] as String? ?? city,
        startDate: parsedStartDate,
        endDate: parsedEndDate,
        places: places,
        budget: jsonData['estimatedBudget'] as Map<String, dynamic>?,
        preferences: {
          'description': jsonData['description'] as String?,
          'tips': jsonData['tips'] as List<dynamic>?,
          'dailyItinerary': jsonData['dailyItinerary'] as Map<String, dynamic>?,
        },
        generatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error parsing Gemini response',
        name: 'TravelPlanMapper',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error al parsear respuesta de IA: ${e.toString()}');
    }
  }

  /// Cleans JSON response by removing markdown code blocks and extra whitespace
  static String _cleanJsonResponse(String text) {
    String cleaned = text.trim();
    
    // Remove markdown code blocks (```json ... ``` or ``` ... ```)
    if (cleaned.startsWith('```')) {
      // Find the first newline after ```
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) {
        cleaned = cleaned.substring(firstNewline + 1);
      }
      
      // Remove closing ```
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
    }
    
    // Trim again after removing markdown
    cleaned = cleaned.trim();
    
    // Validate it starts with { and ends with }
    if (!cleaned.startsWith('{')) {
      // Try to find the first {
      final jsonStart = cleaned.indexOf('{');
      if (jsonStart != -1) {
        cleaned = cleaned.substring(jsonStart);
      }
    }
    
    if (!cleaned.endsWith('}')) {
      // Try to find the last }
      final jsonEnd = cleaned.lastIndexOf('}');
      if (jsonEnd != -1) {
        cleaned = cleaned.substring(0, jsonEnd + 1);
      }
    }
    
    return cleaned;
  }
}


