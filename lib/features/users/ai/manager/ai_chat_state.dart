import '../data/models/chat_message_model.dart';

abstract class AiChatState {}

class AiChatInitial extends AiChatState {}

class AiChatUpdated extends AiChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;

  AiChatUpdated({required this.messages, this.isLoading = false});
}
