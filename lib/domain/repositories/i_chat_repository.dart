import '../models/travel_plan.dart';
import '../models/chat_message.dart';

abstract class IChatRepository {
  Future<TravelPlan> generateTravelPlan({
    required String prompt,
    required String city,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? interests,
  });

  Future<String> refineExistingPlan({
    required TravelPlan currentPlan,
    required String refinementRequest,
  });

  Future<List<ChatMessage>> getChatHistory();
}

