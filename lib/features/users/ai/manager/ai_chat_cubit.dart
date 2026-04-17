import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:joby/features/users/ai/data/repos/ai_chat_repo.dart';
import 'package:joby/features/users/ai/manager/ai_chat_state.dart';
import '../data/models/chat_message_model.dart';

class AiChatCubit extends Cubit<AiChatState> {
  // ⚠️ TODO: Move this key to flutter_dotenv or --dart-define before release
  static const String _apiKey = 'AIzaSyCPha58cKprqL6H94MfjUo8Gl98V3VrLLE';

  final AiChatRepo _aiChatRepo;

  late GenerativeModel _model;
  late ChatSession _chatSession;
  late Box<String> _chatBox;

  final List<ChatMessageModel> _messages = [];

  static const String _welcomeMessage =
      "Hello! I'm Joby Assistant. I can help you review your CV, "
      "prepare for interviews, or suggest a career roadmap. "
      "How can I help you today?";

  AiChatCubit(this._aiChatRepo) : super(AiChatInitial()) {
    _init();
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> _init() async {
    _chatBox = Hive.box<String>(AppConstants.chatHistoryBox);

    // 1. Load stored messages from Hive
    if (_chatBox.isNotEmpty) {
      for (final raw in _chatBox.values) {
        try {
          final map = json.decode(raw) as Map<String, dynamic>;
          _messages.add(
            ChatMessageModel(
              text: map['text'] as String,
              isAi: map['isAi'] as bool,
            ),
          );
        } catch (e) {
          debugPrint('AiChatCubit: Failed to decode stored message — $e');
        }
      }
    } else {
      // First launch: add the welcome message and persist it
      final welcome = ChatMessageModel(text: _welcomeMessage, isAi: true);
      _messages.add(welcome);
      await _persistMessage(welcome);
    }

    emit(AiChatUpdated(messages: List.from(_messages)));

    // 2. Fetch user profile for personalization (non-blocking)
    final userInfo = await _aiChatRepo.getUserProfile();
    _initModel(
      name: userInfo?.name,
      jobTitle: userInfo?.jobTitle,
      level: userInfo?.level,
      category: userInfo?.jobCategory,
    );

    emit(AiChatUpdated(messages: List.from(_messages)));
  }

  void _initModel({
    String? name,
    String? jobTitle,
    String? level,
    String? category,
  }) {
    final String systemPrompt;

    final isPersonalized =
        name != null &&
        name.isNotEmpty &&
        jobTitle != null &&
        jobTitle.isNotEmpty;

    if (isPersonalized) {
      systemPrompt =
          'You are Joby Assistant, a friendly and expert career coach '
          'inside a job-seeking app called Joby. '
          'You are currently talking with $name, a ${level ?? ""} $jobTitle '
          'in the ${category ?? "tech"} field. '
          'Personalize your advice based on their background. '
          'Help them with CV tips, mock interviews, career roadmaps, '
          'and job search strategies. '
          'Keep answers concise, well-formatted, and professional. '
          'Only answer career and job-related questions.';
    } else {
      systemPrompt =
          'You are Joby Assistant, a friendly and expert career coach '
          'inside a job-seeking app called Joby. '
          'Help users with resume tips, mock interviews, and career advice. '
          'Keep your answers concise, well-formatted, and professional. '
          'Only answer career and job-related questions.';
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    // Restore the last 10 conversation turns into the session history
    final conversationMessages = _messages
        .where((m) => m.text != _welcomeMessage)
        .toList();
    final recentHistory = conversationMessages.length > 10
        ? conversationMessages.sublist(conversationMessages.length - 10)
        : conversationMessages;

    final history = recentHistory.map((m) {
      return m.isAi
          ? Content('model', [TextPart(m.text)])
          : Content('user', [TextPart(m.text)]);
    }).toList();

    _chatSession = _model.startChat(history: history);
  }

  // ─── Public Methods ────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageModel(text: text.trim(), isAi: false);
    _messages.add(userMessage);
    await _persistMessage(userMessage);
    emit(AiChatUpdated(messages: List.from(_messages), isLoading: true));

    try {
      final response = await _chatSession.sendMessage(
        Content.text(text.trim()),
      );
      final aiText = response.text ?? "I'm sorry, I couldn't process that.";

      final aiMessage = ChatMessageModel(text: aiText, isAi: true);
      _messages.add(aiMessage);
      await _persistMessage(aiMessage);
      emit(AiChatUpdated(messages: List.from(_messages), isLoading: false));
    } catch (e) {
      debugPrint('AiChatCubit: Gemini API error — $e');
      const errorText = 'Connection error. Please try again later.';
      final errorMessage = ChatMessageModel(text: errorText, isAi: true);
      _messages.add(errorMessage);
      await _persistMessage(errorMessage);
      emit(AiChatUpdated(messages: List.from(_messages), isLoading: false));
    }
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _chatBox.clear();

    final welcome = ChatMessageModel(text: _welcomeMessage, isAi: true);
    _messages.add(welcome);
    await _persistMessage(welcome);

    // Reset the Gemini chat session
    _chatSession = _model.startChat();

    emit(AiChatUpdated(messages: List.from(_messages)));
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Future<void> _persistMessage(ChatMessageModel message) async {
    final encoded = json.encode({'text': message.text, 'isAi': message.isAi});
    await _chatBox.add(encoded);
  }
}
