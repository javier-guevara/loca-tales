import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import 'dart:developer' as developer;
import '../../../domain/use_cases/generate_travel_plan_use_case.dart';
import '../../../domain/models/chat_message.dart';
import '../../../data/providers/providers.dart';
import 'chat_state.dart';

part 'chat_view_model.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  @override
  ChatState build() {
    return const ChatState();
  }

  GenerateTravelPlanUseCase get _generatePlanUseCase =>
      ref.read(generateTravelPlanUseCaseProvider);

  Future<void> sendMessage(
    String content, {
    Map<String, dynamic>? context,
  }) async {
    if (content.trim().isEmpty) return;
    if (!state.inputEnabled) return;

    developer.log('Sending message: $content', name: 'ChatViewModel');

    // Disable input
    state = state.copyWith(inputEnabled: false);

    // Create user message
    final userMessage = ChatMessage(
      id: _generateId(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message to state
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Parse the user prompt to extract information
      final parsedData = _parsePrompt(content);
      
      developer.log('Parsed prompt data: $parsedData', name: 'ChatViewModel');

      // Extract context (use provided context or parsed data)
      final city = context?['city'] as String? ?? parsedData['city'] as String?;
      final days = parsedData['days'] as int?;
      final interests = context?['interests'] as List<String>? ?? 
                       parsedData['interests'] as List<String>?;

      // Calculate dates if days are specified
      DateTime? startDate = context?['startDate'] as DateTime?;
      DateTime? endDate = context?['endDate'] as DateTime?;
      
      if (days != null && startDate == null) {
        startDate = DateTime.now();
        endDate = startDate.add(Duration(days: days));
      }

      // Validate we have at least a city
      if (city == null || city.isEmpty) {
        throw Exception(
          'No pude identificar la ciudad. Por favor, especifica una ciudad en tu mensaje. '
          'Ejemplo: "3 días en París" o "Viaje a Roma"'
        );
      }

      developer.log(
        'Generating plan for: city=$city, days=$days, interests=$interests',
        name: 'ChatViewModel',
      );

      // Generate travel plan
      final plan = await _generatePlanUseCase.call(
        prompt: content,
        city: city,
        startDate: startDate,
        endDate: endDate,
        interests: interests,
      );

      developer.log('Plan generated successfully: ${plan.id}', name: 'ChatViewModel');

      // Create AI response message
      final aiMessage = ChatMessage(
        id: _generateId(),
        content: 'He generado un plan de viaje para ${plan.city} '
                '${days != null ? "de $days días" : ""}. '
                '¡Revisa los detalles abajo!',
        isUser: false,
        timestamp: DateTime.now(),
        travelPlan: plan,
      );

      // Update state
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        latestPlan: plan,
        isLoading: false,
        inputEnabled: true,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error generating plan',
        name: 'ChatViewModel',
        error: e,
        stackTrace: stackTrace,
      );

      // Create user-friendly error message
      String errorMessage = _getUserFriendlyError(e);
      
      final errorMsg = ChatMessage(
        id: _generateId(),
        content: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        errorMessage: errorMessage,
        isLoading: false,
        inputEnabled: true,
      );
    }
  }

  /// Parses user prompt to extract travel information
  Map<String, dynamic> _parsePrompt(String prompt) {
    final city = _extractCity(prompt);
    final days = _extractDays(prompt);
    final interests = _extractInterests(prompt);
    
    return {
      'city': city,
      'days': days,
      'interests': interests,
    };
  }

  /// Extracts city name from prompt
  String? _extractCity(String prompt) {
    final patterns = [
      RegExp(r'en\s+([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?)', caseSensitive: false),
      RegExp(r'a\s+([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?)', caseSensitive: false),
      RegExp(r'visitar\s+([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(prompt);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }
    
    // Try to find capitalized words
    final capitalizedWords = RegExp(r'[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?')
        .allMatches(prompt)
        .map((m) => m.group(0))
        .where((word) => word != null && word.length > 2)
        .toList();
    
    return capitalizedWords.isNotEmpty ? capitalizedWords.first : null;
  }

  /// Extracts number of days from prompt
  int? _extractDays(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    // Direct number patterns
    final numberPattern = RegExp(r'(\d+)\s*d[ií]as?');
    final numberMatch = numberPattern.firstMatch(lowerPrompt);
    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(1)!);
    }
    
    // Word patterns
    if (lowerPrompt.contains('fin de semana')) return 2;
    if (lowerPrompt.contains('semana')) return 7;
    
    return null;
  }

  /// Extracts interests from prompt
  List<String> _extractInterests(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    final interests = <String>[];
    
    final keywords = {
      'romántico': ['romántico', 'romantico', 'romance'],
      'aventura': ['aventura'],
      'naturaleza': ['naturaleza', 'natural'],
      'cultura': ['cultura', 'cultural', 'museo'],
      'comida': ['comida', 'gastronom', 'restaurante'],
      'playa': ['playa', 'mar'],
      'familia': ['familia', 'familiar'],
    };
    
    for (final entry in keywords.entries) {
      for (final keyword in entry.value) {
        if (lowerPrompt.contains(keyword)) {
          interests.add(entry.key);
          break;
        }
      }
    }
    
    return interests;
  }

  /// Converts technical errors to user-friendly messages
  String _getUserFriendlyError(Object error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('GEMINI_API_KEY')) {
      return '⚠️ La aplicación no está configurada correctamente. '
             'Por favor, contacta al administrador.';
    }
    
    if (errorStr.contains('quota') || errorStr.contains('429')) {
      return '🚫 Límite de solicitudes alcanzado. '
             'Por favor, intenta nuevamente en unos minutos.';
    }
    
    if (errorStr.contains('timeout')) {
      return '⏱️ La solicitud tardó demasiado. '
             'Por favor, intenta nuevamente.';
    }
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return '📵 Sin conexión a internet. '
             'Verifica tu conexión e intenta nuevamente.';
    }
    
    if (errorStr.contains('ciudad')) {
      return errorStr; // Already user-friendly
    }
    
    if (errorStr.contains('parsear') || errorStr.contains('JSON')) {
      return '🤖 La IA generó una respuesta inesperada. '
             'Por favor, intenta reformular tu solicitud.';
    }
    
    // Generic error
    return '❌ Ocurrió un error inesperado. '
           'Por favor, intenta nuevamente o reformula tu solicitud.';
  }

  void clearChat() {
    state = const ChatState();
  }

  void retryLastMessage() {
    final lastUserMessage = state.messages.reversed
        .firstWhere((msg) => msg.isUser, orElse: () => ChatMessage(
              id: '',
              content: '',
              isUser: true,
              timestamp: DateTime(2000),
            ));

    if (lastUserMessage.content.isNotEmpty) {
      sendMessage(lastUserMessage.content);
    }
  }

  void dismissError() {
    state = state.copyWith(errorMessage: null);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}

