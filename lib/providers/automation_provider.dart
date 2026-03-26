import 'package:flutter/foundation.dart';
import '../models/automation_bond_model.dart';
import '../models/automation_condition_model.dart';
import '../services/automation_service.dart';

class AutomationProvider extends ChangeNotifier {
  final AutomationService _service = AutomationService();

  // State
  List<AutomationBond> _bonds = [];
  AutomationBond? _selectedBond;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AutomationBond> get bonds => _bonds;
  AutomationBond? get selectedBond => _selectedBond;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered bonds
  List<AutomationBond> get activeBonds => _bonds.where((b) => b.active).toList();
  List<AutomationBond> get inactiveBonds => _bonds.where((b) => !b.active).toList();

  // ==========================================
  // LOAD DATA
  // ==========================================

  /// Načítaj všetky automation bonds
  Future<void> loadBonds({bool activeOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bonds = await _service.getAllBonds(activeOnly: activeOnly);

      // Synchronizuj vybraný bond, aby reflectoval čerstvé dáta (napr. nové podmienky)
      if (_selectedBond != null) {
        final id = _selectedBond!.id;
        final index = _bonds.indexWhere((b) => b.id == id);
        if (index != -1) {
          _selectedBond = _bonds[index];
        }
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _bonds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Načítaj štatistiky
  Future<void> loadStatistics() async {
    try {
      _statistics = await _service.getStatistics();
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  /// Refresh všetkého
  Future<void> refresh() async {
    await Future.wait([
      loadBonds(),
      loadStatistics(),
    ]);
  }

  // ==========================================
  // CRUD OPERATIONS
  // ==========================================

  /// Vytvor nový automation bond
  Future<void> createBond({
    required int applicationId,
    required bool active,
    required List<Map<String, dynamic>> conditions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBond = await _service.createBond(
        applicationId: applicationId,
        active: active,
        conditions: conditions,
      );

      // Pridaj do zoznamu
      _bonds.insert(0, newBond);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizuj bond (aktivácia/deaktivácia)
  Future<void> updateBond(int id, {required bool active}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateBond(id, active: active);

      // Aktualizuj v zozname
      final index = _bonds.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bonds[index] = updated;
      }

      // Aktualizuj výber
      if (_selectedBond?.id == id) {
        _selectedBond = updated;
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

  /// Zmaž bond
  Future<void> deleteBond(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteBond(id);

      // Odstráň zo zoznamu
      _bonds.removeWhere((b) => b.id == id);

      // Vyčisti výber ak bol zmazaný
      if (_selectedBond?.id == id) {
        _selectedBond = null;
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

  // ==========================================
  // CONDITIONS OPERATIONS
  // ==========================================

  /// Pridaj podmienku k existujúcemu bond
  Future<void> addCondition({
    required int bondId,
    String? region,
    String? district,
  }) async {
    try {
      final newCondition = await _service.addCondition(
        bondId: bondId,
        region: region,
        district: district,
      );

      // Aktualizuj bond v zozname
      final index = _bonds.indexWhere((b) => b.id == bondId);
      if (index != -1) {
        final updatedConditions = List<AutomationCondition>.from(_bonds[index].conditions)
          ..add(newCondition);
        _bonds[index] = _bonds[index].copyWith(conditions: updatedConditions);
      }

      // Aktualizuj výber
      if (_selectedBond?.id == bondId) {
        final updatedConditions = List<AutomationCondition>.from(_selectedBond!.conditions)
          ..add(newCondition);
        _selectedBond = _selectedBond!.copyWith(conditions: updatedConditions);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Zmaž podmienku
  Future<void> deleteCondition(int conditionId, int bondId) async {
    try {
      await _service.deleteCondition(conditionId);

      // Aktualizuj bond v zozname
      final index = _bonds.indexWhere((b) => b.id == bondId);
      if (index != -1) {
        final updatedConditions = _bonds[index].conditions
            .where((c) => c.id != conditionId)
            .toList();
        _bonds[index] = _bonds[index].copyWith(conditions: updatedConditions);
      }

      // Aktualizuj výber
      if (_selectedBond?.id == bondId) {
        final updatedConditions = _selectedBond!.conditions
            .where((c) => c.id != conditionId)
            .toList();
        _selectedBond = _selectedBond!.copyWith(conditions: updatedConditions);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // ==========================================
  // SELECTION
  // ==========================================

  /// Vyber bond
  void selectBond(AutomationBond bond) {
    _selectedBond = bond;
    notifyListeners();
  }

  /// Zruš výber
  void clearSelection() {
    _selectedBond = null;
    notifyListeners();
  }

  // ==========================================
  // MATCHING & SYNC
  // ==========================================

  /// Validuj mesto (bez zmien)
  Future<Map<String, dynamic>> validateCity(int cityId) async {
    try {
      return await _service.validateCity(cityId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Synchronizuj jedno mesto
  Future<Map<String, dynamic>> syncCity(int cityId, {bool removeExtra = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.syncCity(cityId, removeExtra: removeExtra);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronizuj všetky mestá
  Future<Map<String, dynamic>> syncAllCities({
    bool removeExtra = false,
    int? limit,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.syncAllCities(
        removeExtra: removeExtra,
        limit: limit,
      );

      // Refresh štatistík po sync
      await loadStatistics();

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validuj všetky mestá (report)
  Future<Map<String, dynamic>> validateAllCities({int? limit}) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.validateAllCities(limit: limit);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================

  /// Nájdi bond podľa application_id
  AutomationBond? findBondByApplicationId(int applicationId) {
    try {
      return _bonds.firstWhere((b) => b.applicationId == applicationId);
    } catch (e) {
      return null;
    }
  }

  /// Získaj počet aktívnych bonds
  int get activeBondsCount => _bonds.where((b) => b.active).length;

  /// Získaj počet neaktívnych bonds
  int get inactiveBondsCount => _bonds.where((b) => !b.active).length;

  /// Získaj celkový počet podmienok
  int get totalConditionsCount {
    return _bonds.fold(0, (sum, bond) => sum + bond.conditions.length);
  }

  /// Reset
  void reset() {
    _bonds = [];
    _selectedBond = null;
    _statistics = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}