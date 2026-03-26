import 'package:flutter/foundation.dart';
import '../models/text_type_model.dart';
import '../services/text_type_service.dart';

class TextTypeProvider extends ChangeNotifier {
  final TextTypeService _service = TextTypeService();

  List<TextType> _textTypes = [];
  TextType? _selectedTextType;
  bool _isLoading = false;
  String? _error;

  List<TextType> get textTypes => _textTypes;
  TextType? get selectedTextType => _selectedTextType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Načítaj všetky typy textov
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _textTypes = await _service.getAllTextTypes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _textTypes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyber typ textu
  void selectTextType(TextType textType) {
    _selectedTextType = textType;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedTextType = null;
    notifyListeners();
  }

  /// Aktualizuj typ textu (iba text atribút)
  Future<void> updateTextType(int id, String newText) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateTextType(id, {'text': newText});

      // Aktualizuj v zozname
      final index = _textTypes.indexWhere((t) => t.id == id);
      if (index != -1) {
        _textTypes[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedTextType?.id == id) {
        _selectedTextType = updated;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
