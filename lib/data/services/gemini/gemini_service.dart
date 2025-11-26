import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'dart:convert';
import 'dart:developer' as developer;
import '../../../config/constants/api_constants.dart';
import '../../../config/environment/env.dart';
import 'prompt_builder.dart';
import '../../models/gemini/gemini_response_dto.dart';

class GeminiService {
  late final gemini.GenerativeModel _model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY no está configurada');
    }

    _model = gemini.GenerativeModel(
      model: ApiConstants.geminiModel,
      apiKey: apiKey,
      systemInstruction: gemini.Content.system(_buildSystemInstruction()),
      generationConfig: gemini.GenerationConfig(
        temperature: ApiConstants.geminiTemperature,
        maxOutputTokens: ApiConstants.geminiMaxOutputTokens,
        responseMimeType: 'application/json',
      ),
    );
  }

  String _buildSystemInstruction() {
    return '''
Eres un experto guía turístico con conocimiento profundo de destinos alrededor del mundo.

IMPORTANTE: Siempre responde ÚNICAMENTE con un objeto JSON válido. NO incluyas markdown, backticks ni texto adicional.

Cuando el usuario solicite un plan de viaje, genera un JSON con esta estructura EXACTA:

{
  "city": "nombre de la ciudad",
  "description": "breve descripción del plan",
  "places": [
    {
      "name": "nombre del lugar",
      "description": "descripción detallada de 2-3 oraciones",
      "latitude": número (precisión 6 decimales),
      "longitude": número (precisión 6 decimales),
      "category": "uno de: attraction, restaurant, hotel, nature, culture, shopping, entertainment",
      "estimatedDuration": "formato ISO 8601 (ej: PT2H30M para 2h 30min)",
      "openingHours": "horario típico",
      "priceLevel": número del 1 al 4 (1=económico, 4=caro),
      "rating": número del 1.0 al 5.0
    }
  ],
  "dailyItinerary": {
    "day1": ["lugar1", "lugar2", "lugar3"],
    "day2": ["lugar4", "lugar5"],
    ...
  },
  "tips": ["consejo útil 1", "consejo útil 2"],
  "estimatedBudget": {
    "min": número en USD,
    "max": número en USD
  }
}

REGLAS:
1. Número de lugares: 4-6 por día
2. Distribución: mezclar categorías (cultura, comida, naturaleza)
3. Coordenadas: verificar que sean precisas
4. Orden cronológico: considerar distancias y horarios
5. Realismo: tiempos de visita y traslados reales
6. Variedad: incluir lugares icónicos Y joyas ocultas
''';
  }

  Future<GeminiResponseDto> generateTravelPlan({
    required String city,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? interests,
  }) async {
    try {
      developer.log(
        'Generating travel plan for: $city',
        name: 'GeminiService',
      );

      final prompt = PromptBuilder.buildTravelPlanPrompt(
        city: city,
        startDate: startDate,
        endDate: endDate,
        interests: interests,
      );

      developer.log(
        'Prompt length: ${prompt.length} characters',
        name: 'GeminiService',
      );

      final response = await _model.generateContent([
        gemini.Content.text(prompt),
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('timeout');
        },
      );

      developer.log(
        'Received response from Gemini',
        name: 'GeminiService',
      );

      final text = response.text;
      if (text == null || text.isEmpty) {
        developer.log(
          'Empty response from Gemini',
          name: 'GeminiService',
          error: 'Response text is null or empty',
        );
        throw Exception('La respuesta de Gemini está vacía');
      }

      developer.log(
        'Response length: ${text.length} characters',
        name: 'GeminiService',
      );

      // Convert to DTO
      return GeminiResponseDto.fromJson({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': text}
              ]
            }
          }
        ]
      });
    } on gemini.GenerativeAIException catch (e) {
      developer.log(
        'Gemini API error',
        name: 'GeminiService',
        error: e,
      );
      
      if (e.message.contains('quota') || e.message.contains('429')) {
        throw Exception('Límite de solicitudes alcanzado. Intenta más tarde.');
      }
      if (e.message.contains('API key')) {
        throw Exception('GEMINI_API_KEY inválida o no configurada');
      }
      throw Exception('Error de la API de Gemini: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Error generating travel plan',
        name: 'GeminiService',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
      }
      throw Exception('Error al generar plan de viaje: ${e.toString()}');
    }
  }

  Future<String> refineResponse({
    required String currentPlanJson,
    required String refinementRequest,
  }) async {
    try {
      final prompt = PromptBuilder.buildRefinementPrompt(
        currentPlanJson: currentPlanJson,
        refinementRequest: refinementRequest,
      );

      final response = await _model.generateContent([
        gemini.Content.text(prompt),
      ]);

      return response.text ?? 'No se pudo generar una respuesta de refinamiento';
    } catch (e) {
      throw Exception('Error al refinar el plan: ${e.toString()}');
    }
  }
}

