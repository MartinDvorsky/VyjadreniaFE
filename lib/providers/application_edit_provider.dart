import 'package:flutter/foundation.dart';
import '../models/application_edit_model.dart';
import '../services/application_edit_service.dart';

class ApplicationEditProvider extends ChangeNotifier {
  final ApplicationEditService _service = ApplicationEditService();

  List<ApplicationEdit> _applications = [];
  ApplicationEdit? _selectedApplication;
  bool _isLoading = false;
  String? _error;

  List<ApplicationEdit> get applications => _applications;
  ApplicationEdit? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vyhľadaj úrady
  Future<void> searchApplications({
    String? name,
    String? department,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _service.searchApplications(
        name: name,
        department: department,
        city: city,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _applications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyčisti vyhľadávanie
  void clearSearch() {
    _applications = [];
    _selectedApplication = null;
    _error = null;
    notifyListeners();
  }

  /// Vyber úrad
  void selectApplication(ApplicationEdit application) {
    _selectedApplication = application;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedApplication = null;
    notifyListeners();
  }

  /// Vytvor nový úrad
  Future<void> createApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createApplication(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizuj úrad
  Future<void> updateApplication(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateApplication(id, data);

      // Aktualizuj v zozname
      final index = _applications.indexWhere((app) => app.id == id);
      if (index != -1) {
        _applications[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedApplication?.id == id) {
        _selectedApplication = updated;
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

  /// Zmaž úrad
  Future<void> deleteApplication(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteApplication(id);

      // Odstráň zo zoznamu
      _applications.removeWhere((app) => app.id == id);

      // Vyčisti výber ak bol zmazaný
      if (_selectedApplication?.id == id) {
        _selectedApplication = null;
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