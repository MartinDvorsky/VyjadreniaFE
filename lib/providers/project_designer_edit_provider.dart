import 'package:flutter/foundation.dart';
import '../models/project_designer_model.dart';
import '../services/project_designer_service.dart';

class ProjectDesignerEditProvider extends ChangeNotifier {
  final ProjectDesignerService _service = ProjectDesignerService();

  List<ProjectDesigner> _designers = [];
  ProjectDesigner? _selectedDesigner;
  bool _isLoading = false;
  String? _error;

  List<ProjectDesigner> get designers => _designers;
  ProjectDesigner? get selectedDesigner => _selectedDesigner;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Načítaj všetkých projektantov
  Future<void> loadAllDesigners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _designers = await _service.getAllProjectDesigners2();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _designers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyčisti zoznam
  void clearList() {
    _designers = [];
    _selectedDesigner = null;
    _error = null;
    notifyListeners();
  }

  /// Vyber projektanta
  void selectDesigner(ProjectDesigner designer) {
    _selectedDesigner = designer;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedDesigner = null;
    notifyListeners();
  }

  /// Vytvor nového projektanta
  Future<void> createDesigner(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDesigner = await _service.createProjectDesigner(data);
      _designers.add(newDesigner);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizuj projektanta
  Future<void> updateDesigner(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateProjectDesigner(id, data);

      // Aktualizuj v zozname
      final index = _designers.indexWhere((d) => d.id == id);
      if (index != -1) {
        _designers[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedDesigner?.id == id) {
        _selectedDesigner = updated;
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

  /// Zmaž projektanta
  Future<void> deleteDesigner(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteProjectDesigner(id);

      // Odstráň zo zoznamu
      _designers.removeWhere((d) => d.id == id);

      // Vyčisti výber ak bol zmazaný
      if (_selectedDesigner?.id == id) {
        _selectedDesigner = null;
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