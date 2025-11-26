import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/models/travel_plan.dart';
import '../../domain/models/chat_message.dart';
import '../services/gemini/gemini_service.dart';
import '../services/local/shared_preferences_service.dart';
import '../models/mappers/travel_plan_mapper.dart';
import 'dart:math';

class ChatRepositoryImpl implements IChatRepository {
  final GeminiService _geminiService;
  final SharedPreferencesService _prefsService;
  final List<ChatMessage> _chatHistory = [];

  ChatRepositoryImpl({
    required GeminiService geminiService,
    required SharedPreferencesService prefsService,
  })  : _geminiService = geminiService,
        _prefsService = prefsService;

  @override
  Future<TravelPlan> generateTravelPlan({
    required String prompt,
    required String city,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? interests,
  }) async {
    try {
      final response = await _geminiService.generateTravelPlan(
        city: city,
        startDate: startDate,
        endDate: endDate,
        interests: interests,
      );

      final plan = TravelPlanMapper.fromGeminiResponse(
        response: response,
        city: city,
        startDate: startDate,
        endDate: endDate,
      );

      // Save to local storage
      await _prefsService.saveTravelPlan(plan);

      return plan;
    } catch (e) {
      if (e.toString().contains('quota') || e.toString().contains('429')) {
        throw Exception('Límite de solicitudes alcanzado. Intenta más tarde.');
      }
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
      }
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Sin conexión a internet');
      }
      throw Exception('Error al procesar respuesta de IA: ${e.toString()}');
    }
  }

  @override
  Future<String> refineExistingPlan({
    required TravelPlan currentPlan,
    required String refinementRequest,
  }) async {
    try {
      // Serialize current plan (simplified)
      final planJson = {
        'city': currentPlan.city,
        'places': currentPlan.places.map((p) => p.name).toList(),
      };

      final response = await _geminiService.refineResponse(
        currentPlanJson: planJson.toString(),
        refinementRequest: refinementRequest,
      );

      return response;
    } catch (e) {
      throw Exception('Error al refinar el plan: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    return List.unmodifiable(_chatHistory);
  }
}


