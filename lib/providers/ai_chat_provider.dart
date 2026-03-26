import 'package:flutter/foundation.dart';
import '../services/ai_chat_service.dart';

class AiChatProvider extends ChangeNotifier {
  final AiChatService _aiChatService = AiChatService();

  bool _isOpen = false;
  bool get isOpen => _isOpen;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// História konverzácie pre potreby aktuálneho chatu (zobrazovanie v UI)
  /// a pre odosielanie celej histórie na backend.
  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  /// Otvorí alebo zatvorí chatovacie okno.
  void toggleChat() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void openChat() {
    _isOpen = true;

    // Pridaj uvítaciu správu len ak je chat prázdny
    if (_messages.isEmpty) {
      _messages.add({
        'role': 'assistant',
        'content':
        '👋 Ahoj! Som AI asistent pre generovanie vyjadrení k stavbe.\n\n'
            'Sprevádzam ťa celým procesom — od výberu lokality až po stiahnutie hotových dokumentov.\n\n'
            'V ktorom kroku ti môžem pomôcť? 😊',
      });
    }

    notifyListeners();
  }

  void closeChat() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Odošle správu od používateľa a počká na odpoveď od AI.
  Future<void> sendMessage(String content, int currentStep) async {
    if (content.trim().isEmpty) return;

    // Pridáme používateľovu správu do histórie
    _messages.add({"role": "user", "content": content.trim()});
    _isLoading = true;
    notifyListeners();

    try {
      // Vytvoríme kópiu pre API call (backend aktuálne nemusí zlyhať na extra kľúčoch, ale pre istotu posielame iba role a content)
      final requestMessages = _messages.map((m) => {
        "role": m["role"]!,
        "content": m["content"]!
      }).toList();

      final aiReply = await _aiChatService.sendMessage(requestMessages, currentStep + 1); // step in UI is 0-indexed, backend usually 1-indexed (we will pass currentStep+1 from UI if needed, but the current UI says currentStep = 2 so step 2)

      // Pridáme odpoveď do histórie
      _messages.add({"role": "assistant", "content": aiReply});
    } catch (e) {
      // Ak nastane chyba, pridáme informačnú správu
      _messages.add({"role": "system", "content": "Ospravedlňujeme sa, nastala chyba pri komunikácii s AI asistentom. (${e.toString()})"});
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Zmaže históriu chatu (napr. pri resetovaní projektu alebo novom prihlásení)
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }
}
