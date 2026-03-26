// ========================================
// STEP 5 DATA PROVIDER - FINÁLNA VERZIA
// Uložiť ako: lib/providers/step5_data_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';  // pre BuildContext
import 'package:provider/provider.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';
import '../providers/generate_provider.dart';

class Step5DataProvider with ChangeNotifier {
  BuildContext? _context;
  final ApplicationService _applicationService = ApplicationService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Application> _applications = [];
  final Map<int, String> _customFilenames = {};
  final Set<int> _hiddenApplicationIds = {};
  final Set<int> _manuallyAddedIds = {};

  // ✅ NOVÉ: Flag či sú dáta pripravené
  bool _isReady = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Application> get applications => _applications;
  int get applicationsCount => _applications.length;
  int get hiddenCount => _hiddenApplicationIds.length;
  int get visibleCount => _applications.length - _hiddenApplicationIds.length;

  bool isHidden(int applicationId) {
    return _hiddenApplicationIds.contains(applicationId);
  }

  /// Načítaj filtrované úrady pre dané mestá
  Future<void> loadFilteredApplications({
    required List<int> cityIds,
    required bool fireProtection,
    required bool waterManagement,
    required bool publicHealth,
    required bool railways,
    required bool roads1,
    required bool roads2,
    required bool municipality,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Loading applications for cities: $cityIds');
      print('Filters: ORHAZZ=$fireProtection, SVP=$waterManagement, RUVZ=$publicHealth');
      print('         ŽSR=$railways, Cesty1=$roads1, Cesty2=$roads2, Obec=$municipality');

      _applications = await _applicationService.getFilteredApplicationsForCities(
        cityIds: cityIds,
        fireProtection: fireProtection,
        waterManagement: waterManagement,
        publicHealth: publicHealth,
        railways: railways,
        roads1: roads1,
        roads2: roads2,
        municipality: municipality,
      );

      print('✅ Loaded ${_applications.length} applications');

      _errorMessage = null;
    } catch (e) {
      print('❌ Error loading applications: $e');
      _errorMessage = e.toString();
      _applications = [];
    } finally {
      _isLoading = false;
      // Notifikuj o zmene stavu po načítaní
      notifyListeners();
      // Trigger validáciu v GenerateProvider
      Future.microtask(() {
        if (_applications.isNotEmpty) {
          final generateProvider = Provider.of<GenerateProvider>(
            _context!,
            listen: false,
          );
          generateProvider.validateCurrentStep();
        }
      });
    }
  }

  /// ✅ Označ ako pripravené (po inicializácii controllerov)
  void markAsReady() {
    _isReady = true;
    print('✅ Step 5 marked as ready with ${visibleCount} visible applications');
    notifyListeners();
  }

  /// Setter pre context
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Nastav custom filename pre úrad
  void setFilename(int applicationId, String filename) {
    _customFilenames[applicationId] = filename;
    notifyListeners();
  }

  /// Získaj filename pre úrad (custom alebo default)
  String getFilename(int applicationId, {String? znacka}) {
    if (_customFilenames.containsKey(applicationId) &&
        _customFilenames[applicationId]!.isNotEmpty) {
      return _customFilenames[applicationId]!;
    }

    final app = _applications.firstWhere(
          (a) => a.applicationId == applicationId,
      orElse: () => _applications.first,
    );

    return _generateDefaultFilename(app, znacka: znacka);
  }

  /// Generuj default filename na základe údajov úradu
  String _generateDefaultFilename(Application app, {String? znacka}) {
    String cleanName = _cleanFilename(app.name);
    String department = _cleanFilename(app.department);
    if (znacka == null || znacka.isEmpty) {
      return cleanName;
    }
    String cleanZnacka = _cleanFilename(znacka);
    return '${cleanName}-${department}-${cleanZnacka}';
  }

  /// Vyčisti string pre použitie v názve súboru
  /// ✅ Odstráni aj bodku
  String _cleanFilename(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*.\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')  // Viacnásobné _ -> jedno _
        .replaceAll(RegExp(r'^_|_$'), ''); // Odstráň _ na začiatku/konci
  }

  /// Skry úrad
  void hideApplication(int applicationId) {
    _hiddenApplicationIds.add(applicationId);
    print('🙈 Hidden application: $applicationId');
    notifyListeners();
  }

  /// Zobraz úrad
  void showApplication(int applicationId) {
    _hiddenApplicationIds.remove(applicationId);
    print('👁️ Shown application: $applicationId');
    notifyListeners();
  }

  /// Kontrola, či bol úrad manuálne pridaný
  bool isManuallyAdded(int applicationId) {
    return _manuallyAddedIds.contains(applicationId);
  }

  /// Pridaj manuálne úrad z DB do zoznamu
  bool addManualApplication(Application app) {
    // Kontrola duplikátov
    if (_applications.any((a) => a.applicationId == app.applicationId)) {
      print('⚠️ Application ${app.applicationId} already exists');
      return false;
    }
    _applications.add(app);
    _manuallyAddedIds.add(app.applicationId);
    print('✅ Manually added application: ${app.name} (${app.applicationId})');
    notifyListeners();
    return true;
  }

  /// Odober manuálne pridaný úrad
  void removeManualApplication(int applicationId) {
    if (_manuallyAddedIds.contains(applicationId)) {
      _applications.removeWhere((a) => a.applicationId == applicationId);
      _manuallyAddedIds.remove(applicationId);
      _hiddenApplicationIds.remove(applicationId);
      _customFilenames.remove(applicationId);
      print('🗑️ Removed manually added application: $applicationId');
      notifyListeners();
    }
  }

  /// Zobraz všetky úrady
  void showAllApplications() {
    _hiddenApplicationIds.clear();
    print('👁️ Showing all applications');
    notifyListeners();
  }

  /// Exportuj všetky VIDITEĽNÉ úrady s ich filename do JSON
  // step5_data_provider.dart

  /// Exportuj všetky VIDITEĽNÉ úrady s ich filename do JSON
  /// ✅ VRÁTANE ONLINE (Excel ich potrebuje)
  List<Map<String, dynamic>> exportApplicationsWithFilenames({String? znacka}) {
    return _applications
        .where((app) => !_hiddenApplicationIds.contains(app.applicationId))  // ✅ Len viditeľné
        .map((app) {
      return {
        'application_id': app.applicationId,
        'name': app.name,
        'department': app.department,
        'city': app.city,
        'filename': getFilename(app.applicationId, znacka: znacka),
        'street_address': app.streetAddress,
        'postal_code': app.postalCode,
        'text_type': app.textType,
        'submission': app.submission,  // ✅ Pošli submission type
      };
    }).toList();
  }

// ✅ Nová metóda - len pre DOCX generovanie (môže byť užitočná)
  List<Map<String, dynamic>> exportNonOnlineApplications({String? znacka}) {
    return _applications
        .where((app) =>
    !_hiddenApplicationIds.contains(app.applicationId) &&
        app.submission != 'online')
        .map((app) {
      return {
        'application_id': app.applicationId,
        'name': app.name,
        'department': app.department,
        'city': app.city,
        'filename': getFilename(app.applicationId, znacka: znacka),
        'street_address': app.streetAddress,
        'postal_code': app.postalCode,
        'text_type': app.textType,
        'submission': app.submission,
      };
    }).toList();
  }

  List<Map<String, dynamic>> exportOnlineApplications() {
    return _applications
        .where((app) =>
    !_hiddenApplicationIds.contains(app.applicationId) &&
        app.submission == 'online')
        .map((app) {
      return {
        'application_id': app.applicationId,
        'name': app.name,
        'department': app.department,
        'city': app.city,
        'street_address': app.streetAddress,
        'postal_code': app.postalCode,
        'submission': app.submission,
      };
    }).toList();
  }

  /// Validácia - všetky VIDITEĽNÉ úrady majú filename?
  bool isValid() {
    // Ak nie sú dáta pripravené, vráť false
    if (!_isReady) return false;

    // Ak sa ešte len načítavajú dáta, vráť false
    if (_isLoading) return false;

    // Ak nastala chyba, vráť false
    if (_errorMessage != null) return false;

    // Ak nie sú žiadne aplikácie, vráť false
    if (_applications.isEmpty) return false;

    // ✅ ZMENA: Filtruj len NON-online viditeľné aplikácie
    final nonOnlineVisibleApps = _applications
        .where((app) =>
    !_hiddenApplicationIds.contains(app.applicationId) &&
        app.submission != 'online')
        .toList();

    // Ak nie sú žiadne non-online viditeľné aplikácie, vráť false
    if (nonOnlineVisibleApps.isEmpty) return false;

    // Ak všetky non-online viditeľné aplikácie majú filename, vráť true
    return true;
  }

  /// Reset
  void reset() {
    _applications = [];
    _customFilenames.clear();
    _hiddenApplicationIds.clear();
    _manuallyAddedIds.clear();
    _errorMessage = null;
    _isLoading = false;
    _isReady = false;
    notifyListeners();
  }

  /// Získaj štatistiky
  Map<String, int> getStatistics() {
    int withCustomFilename = _customFilenames.length;
    int withDefaultFilename = toGenerateCount - withCustomFilename;

    return {
      'total': _applications.length,
      'visible': visibleCount,
      'hidden': hiddenCount,
      'custom': withCustomFilename,
      'default': withDefaultFilename,
      'online': onlineCount,
      'toGenerate': toGenerateCount,
    };
  }

  int get onlineCount => _applications
      .where((app) => app.submission == 'online' && !_hiddenApplicationIds.contains(app.applicationId))
      .length;

  int get toGenerateCount => _applications
      .where((app) => app.submission != 'online' && !_hiddenApplicationIds.contains(app.applicationId))
      .length;
}
