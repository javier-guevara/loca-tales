class PromptBuilder {
  static String buildTravelPlanPrompt({
    required String city,
    DateTime? startDate,
    DateTime? endDate,
    int? days,
    List<String>? interests,
  }) {
    final daysCount = days ?? 
        (startDate != null && endDate != null 
            ? endDate.difference(startDate).inDays + 1 
            : 3);

    final dateRange = startDate != null && endDate != null
        ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
        : 'próximos días';

    final interestsText = interests != null && interests.isNotEmpty
        ? '\nIntereses del usuario: ${interests.join(", ")}'
        : '';

    return '''
Genera un plan de viaje detallado para $city para $daysCount días ($dateRange).$interestsText

El plan debe incluir:
- 4-6 lugares por día, distribuidos de manera balanceada
- Mezcla de categorías: atracciones culturales, restaurantes, naturaleza, entretenimiento
- Coordenadas geográficas precisas (latitud y longitud con 6 decimales)
- Horarios realistas de apertura
- Tiempos estimados de visita
- Orden cronológico lógico considerando distancias y horarios
- Incluir tanto lugares icónicos como joyas ocultas

Responde ÚNICAMENTE con un objeto JSON válido siguiendo esta estructura exacta:
{
  "city": "$city",
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
    "day1": ["nombre_lugar1", "nombre_lugar2", "nombre_lugar3"],
    "day2": ["nombre_lugar4", "nombre_lugar5"]
  },
  "tips": ["consejo útil 1", "consejo útil 2"],
  "estimatedBudget": {
    "min": número en USD,
    "max": número en USD
  }
}
''';
  }

  static String buildRefinementPrompt({
    required String currentPlanJson,
    required String refinementRequest,
  }) {
    return '''
El usuario quiere modificar el siguiente plan de viaje:

Plan actual:
$currentPlanJson

Solicitud de modificación:
$refinementRequest

Proporciona una respuesta textual explicando cómo se puede modificar el plan para cumplir con la solicitud. Incluye sugerencias específicas de cambios.
''';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


