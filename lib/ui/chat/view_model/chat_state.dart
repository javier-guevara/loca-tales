import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/models/chat_message.dart';
import '../../../domain/models/travel_plan.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    String? errorMessage,
    TravelPlan? latestPlan,
    @Default(true) bool inputEnabled,
  }) = _ChatState;
}


