import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../models/application_model.dart';
import '../services/city_offices_service.dart';

class CityOfficesProvider extends ChangeNotifier {
  final CityOfficesService _service = CityOfficesService();

  City? _selectedCity;
  List<Application> _offices = [];
  bool _isLoading = false;
  String? _error;

  City? get selectedCity => _selectedCity;
  List<Application> get offices => _offices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vyber mesto a načítaj jeho úrady
  Future<void> selectCity(City city) async {
    _selectedCity = city;
    _offices = [];
    _error = null;
    notifyListeners();

    await loadOfficesForCity(city.id);
  }

  /// Načítaj úrady pre vybraté mesto
  Future<void> loadOfficesForCity(int cityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offices = await _service.getOfficesForCity(cityId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _offices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Načítaj filtrované úrady
  Future<void> loadFilteredOffices({
    required int cityId,
    bool? fireProtection,
    bool? waterManagement,
    bool? publicHealth,
    bool? railways,
    bool? roads1,
    bool? roads2,
    bool? municipality,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offices = await _service.getFilteredOfficesForCity(
        cityId: cityId,
        fireProtection: fireProtection,
        waterManagement: waterManagement,
        publicHealth: publicHealth,
        railways: railways,
        roads1: roads1,
        roads2: roads2,
        municipality: municipality,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _offices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pridaj úrad k mestu
  Future<void> addOfficeToCity(int applicationId, int cityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.addOfficeToCity(applicationId, cityId);

      // Refresh zoznam úradov
      await loadOfficesForCity(cityId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Odstráň úrad z mesta
  Future<void> removeOfficeFromCity(int applicationId, int cityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.removeOfficeFromCity(applicationId, cityId);

      // Odstráň z lokálneho zoznamu
      _offices.removeWhere((office) => office.applicationId == applicationId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Zruš výber mesta
  void clearSelection() {
    _selectedCity = null;
    _offices = [];
    _error = null;
    notifyListeners();
  }

  /// Reset všetkého
  void reset() {
    _selectedCity = null;
    _offices = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}