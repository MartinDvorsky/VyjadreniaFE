import 'package:flutter/foundation.dart';
import '../models/building_purpose_model.dart';
import '../services/building_purpose_service.dart';

class BuildingPurposeProvider extends ChangeNotifier {
  final BuildingPurposeService _service = BuildingPurposeService();

  List<BuildingPurpose> _purposes = [];
  BuildingPurpose? _selectedPurpose;
  bool _isLoading = false;
  String? _error;

  List<BuildingPurpose> get purposes => _purposes;
  BuildingPurpose? get selectedPurpose => _selectedPurpose;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Načítaj všetky účely stavby
  Future<void> loadAllPurposes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _purposes = await _service.getAllBuildingPurposes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _purposes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vyčisti zoznam
  void clearList() {
    _purposes = [];
    _selectedPurpose = null;
    _error = null;
    notifyListeners();
  }

  /// Vyber účel stavby
  void selectPurpose(BuildingPurpose purpose) {
    _selectedPurpose = purpose;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedPurpose = null;
    notifyListeners();
  }

  /// Vytvor nový účel stavby
  Future<void> createPurpose(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPurpose = await _service.createBuildingPurpose(data);
      _purposes.add(newPurpose);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizuj účel stavby
  Future<void> updatePurpose(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateBuildingPurpose(id, data);

      // Aktualizuj v zozname
      final index = _purposes.indexWhere((p) => p.id == id);
      if (index != -1) {
        _purposes[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedPurpose?.id == id) {
        _selectedPurpose = updated;
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

  /// Zmaž účel stavby
  Future<void> deletePurpose(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteBuildingPurpose(id);

      // Odstráň zo zoznamu
      _purposes.removeWhere((p) => p.id == id);

      // Vyčisti výber ak bol zmazaný
      if (_selectedPurpose?.id == id) {
        _selectedPurpose = null;
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