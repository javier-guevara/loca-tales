import '../models/travel_plan.dart';
import '../repositories/i_chat_repository.dart';

class GenerateTravelPlanUseCase {
  final IChatRepository _repository;

  GenerateTravelPlanUseCase(this._repository);

  Future<TravelPlan> call({
    required String prompt,
    required String city,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? interests,
  }) async {
    // Validations
    if (city.trim().isEmpty) {
      throw ArgumentError('La ciudad no puede estar vacía');
    }

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('La fecha de inicio debe ser anterior a la fecha de fin');
      }

      final now = DateTime.now();
      if (startDate.isBefore(now.subtract(const Duration(days: 1)))) {
        throw ArgumentError('Las fechas no pueden estar en el pasado');
      }
    }

    try {
      return await _repository.generateTravelPlan(
        prompt: prompt,
        city: city,
        startDate: startDate,
        endDate: endDate,
        interests: interests,
      );
    } catch (e) {
      throw Exception('Error al generar el plan de viaje: ${e.toString()}');
    }
  }
}


