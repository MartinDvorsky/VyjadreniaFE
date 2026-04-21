import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_message_model.dart';

class ChatNotifier extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  static const _sessionKey = 'chat_session_id';

  List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  String? _sessionId;
  String? get sessionId => _sessionId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ChatNotifier() {
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionKey);
    // Historický load zavoláme explicitne až pri otvorení panela
    notifyListeners();
  }

  void togglePanel() {
    _isPanelOpen = !_isPanelOpen;
    if (_isPanelOpen && _messages.isEmpty && _sessionId != null) {
      loadHistory();
    }
    notifyListeners();
  }

  void openPanel() {
    if (!_isPanelOpen) {
      _isPanelOpen = true;
      if (_messages.isEmpty && _sessionId != null) {
        loadHistory();
      }
      notifyListeners();
    }
  }

  void closePanel() {
    if (_isPanelOpen) {
      _isPanelOpen = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    if (_sessionId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = await _repository.getHistory(_sessionId!);
      _messages = history;
    } catch (e) {
      _errorMessage = 'Chyba pri načítaní histórie chatu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, String? screenId) async {
    if (text.trim().isEmpty) return;

    // Pridáme používateľskú správu
    final tempUserId = 'temp_u_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ChatMessageModel(
        id: tempUserId,
        role: 'user',
        content: text,
      ),
    );

    // Pridáme dočasnú asistentovu správu s indikátorom načítavania
    final tempAssistantId = 'temp_a_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ChatMessageModel(
        id: tempAssistantId,
        role: 'assistant',
        content: '',
        isGenerating: true,
      ),
    );
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.sendMessage(
        message: text,
        sessionId: _sessionId,
        screenId: screenId,
      );

      // Aktualizujeme session_id ak bolo vytvorené nové
      if (response['session_id'] != null && _sessionId != response['session_id']) {
        _sessionId = response['session_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, _sessionId!);
      }

      // Nahradíme asistentovu správu reálnou odpoveďou
      final newAssistantMessage = ChatMessageModel.fromJson(response);
      
      final index = _messages.indexWhere((m) => m.id == tempAssistantId);
      if (index != -1) {
        _messages[index] = newAssistantMessage;
      } else {
        _messages.add(newAssistantMessage);
      }
    } catch (e) {
      _errorMessage = 'Nepodarilo sa odoslať správu: $e';
      
      // Odstránime "generating" správu
      _messages.removeWhere((m) => m.id == tempAssistantId);
      
      // Môžeme aj pridať varovanie, že to asistent nezvládol
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> provideFeedback(String messageId, int rating) async {
    try {
      await _repository.submitFeedback(messageId, rating);
      
      // Aktualizácia UI
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(feedbackRating: rating);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Chyba pri odoslaní spätnej väzby: $e';
      notifyListeners();
    }
  }

  Future<void> clearSession() async {
    _sessionId = null;
    _messages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
