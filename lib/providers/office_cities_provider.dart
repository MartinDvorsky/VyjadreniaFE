import 'package:flutter/foundation.dart';
import '../models/application_edit_model.dart';
import '../models/city_model.dart';
import '../services/office_cities_service.dart';

class OfficeCitiesProvider extends ChangeNotifier {
  final OfficeCitiesService _service = OfficeCitiesService();

  ApplicationEdit? _selectedOffice;
  List<City> _cities = [];
  bool _isLoading = false;
  String? _error;

  ApplicationEdit? get selectedOffice => _selectedOffice;
  List<City> get cities => _cities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vyber úrad a načítaj jeho mestá
  Future<void> selectOffice(ApplicationEdit office) async {
    _selectedOffice = office;
    _cities = [];
    _error = null;
    notifyListeners();

    await loadCitiesForOffice(office.id);
  }

  /// Načítaj mestá pre vybraný úrad
  Future<void> loadCitiesForOffice(int officeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cities = await _service.getCitiesForOffice(officeId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pridaj mesto k úradu
  Future<void> addCityToOffice(int officeId, int cityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.addCityToOffice(officeId, cityId);

      // Refresh zoznam miest
      await loadCitiesForOffice(officeId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Odstráň mesto z úradu
  Future<void> removeCityFromOffice(int officeId, int cityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.removeCityFromOffice(officeId, cityId);

      // Odstráň z lokálneho zoznamu
      _cities.removeWhere((city) => city.id == cityId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Zruš výber úradu
  void clearSelection() {
    _selectedOffice = null;
    _cities = [];
    _error = null;
    notifyListeners();
  }

  /// Reset všetkého
  void reset() {
    _selectedOffice = null;
    _cities = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}