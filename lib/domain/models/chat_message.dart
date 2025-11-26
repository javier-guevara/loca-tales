import 'package:freezed_annotation/freezed_annotation.dart';
import 'travel_plan.dart';

part 'chat_message.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    TravelPlan? travelPlan,
  }) = _ChatMessage;
}


