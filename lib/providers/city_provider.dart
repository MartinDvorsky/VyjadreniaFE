import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../services/city_service.dart';

class CityProvider with ChangeNotifier {
  final CityService _cityService = CityService();

  List<City> _cities = [];
  bool _isLoading = false;
  String? _error;
  List<City> _selectedCities = [];

  List<City> get cities => _cities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<City> get selectedCities => _selectedCities;

  // Vyhľadaj mestá
  Future<void> searchCities({
    String? name,
    String? district,
    String? region,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cities = await _cityService.searchCities(
        name: name,
        district: district,
        region: region,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Načítaj všetky mestá
  Future<void> loadAllCities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cities = await _cityService.getAllCities();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aktualizuj mesto
  Future<void> updateCity(int id, Map<String, dynamic> updateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCity = await _cityService.updateCity(id, updateData);

      // Aktualizuj mesto v zozname
      final index = _cities.indexWhere((city) => city.id == id);
      if (index != -1) {
        _cities[index] = updatedCity;
      }

      // Aktualizuj vybraté mesto
      final selectedIndex = _selectedCities.indexWhere((c) => c.id == id);
      if (selectedIndex != -1) {
        _selectedCities[selectedIndex] = updatedCity;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow; // Prehoď chybu aby ju mohol zachytiť UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vytvor nové mesto
  Future<void> createCity(Map<String, dynamic> cityData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCity = await _cityService.createCity(cityData);

      // Pridaj nové mesto do zoznamu
      _cities.insert(0, newCity);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Zmaž mesto
  Future<void> deleteCity(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _cityService.deleteCity(id);

      // Odstráň mesto zo zoznamu
      _cities.removeWhere((city) => city.id == id);

      // Ak bolo vybraté, zruš výber
      _selectedCities.removeWhere((c) => c.id == id);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle výber mesta (pridá/odstráni)
  void selectCity(City city) {
    final existingIndex = _selectedCities.indexWhere((c) => c.id == city.id);
    if (existingIndex != -1) {
      _selectedCities.removeAt(existingIndex);
    } else {
      _selectedCities.add(city);
    }
    notifyListeners();
  }

  // Odstráň konkrétne mesto
  void removeCity(City city) {
    _selectedCities.removeWhere((c) => c.id == city.id);
    notifyListeners();
  }

  // Zruš výber všetkých
  void clearSelection() {
    _selectedCities.clear();
    notifyListeners();
  }

  // Vyčisti vyhľadávanie
  void clearSearch() {
    _cities = [];
    _error = null;
    notifyListeners();
  }

  // Reset všetkého
  void reset() {
    _cities = [];
    _selectedCities.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}