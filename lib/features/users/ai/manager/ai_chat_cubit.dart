import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:joby/features/users/ai/manager/ai_chat_state.dart";

import "../data/models/chat_message_model.dart";

class AiChatCubit extends Cubit<AiChatState> {
  final String _apiKey = "AIzaSyCPha58cKprqL6H94MfjUo8Gl98V3VrLLE";

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text:
          "Hello! I'm Joby Assistant. I can help you review your CV, prepare for interviews, or suggest a career roadmap. How can I help you today?",
      isAi: true,
    ),
  ];

  AiChatCubit() : super(AiChatInitial()) {
    _initAi();
    emit(AiChatUpdated(messages: List.from(_messages)));
  }

  void _initAi() {
    _model = GenerativeModel(
      model: "gemini-1.5-flash-latest",
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "You are Joby Assistant, a friendly and expert career coach inside a job-seeking app called Joby. You help users with resume tips, mock interviews, and career advice. Keep your answers concise, well-formatted, and professional. Only answer career and job-related questions.",
      ),
    );
    _chatSession = _model.startChat();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessageModel(text: text, isAi: false));
    emit(AiChatUpdated(messages: List.from(_messages), isLoading: true));

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final aiText = response.text ?? "I'm sorry, I couldn't process that.";

      _messages.add(ChatMessageModel(text: aiText, isAi: true));
      emit(AiChatUpdated(messages: List.from(_messages), isLoading: false));
    } catch (e) {
      _messages.add(
        ChatMessageModel(
          text: "Connection error. Please try again later.",
          isAi: true,
        ),
      );
      emit(AiChatUpdated(messages: List.from(_messages), isLoading: false));
    }
  }
}
