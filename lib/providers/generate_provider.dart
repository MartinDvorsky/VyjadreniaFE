import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../services/notification_service.dart';
import 'step2_data_provider.dart';
import 'step3_data_provider.dart';
import 'step4_notifications_provider.dart';
import 'step5_data_provider.dart';
import 'city_provider.dart';

class GenerateProvider with ChangeNotifier {
  int _currentStep = 0;

  // ✅ CityProvider pre GENERATE workflow
  final CityProvider cityProvider;



  // ✅ NOVÉ: BuildContext pre validáciu
  BuildContext? _context;

  // Ostatné dáta
  List<String> _selectedOffices = [];
  String? _requestType;
  bool _enableNotifications = false;
  String? _notificationEmail;
  String? _documentPrefix;
  bool _isGenerating = false;
  String? _generationError;

  GenerateProvider({required this.cityProvider}) {
    cityProvider.addListener(_onCityProviderChanged);
  }

  void _onCityProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    cityProvider.removeListener(_onCityProviderChanged);
    super.dispose();
  }

  // ✅ NOVÉ: Nastav context pre validáciu
  void setContext(BuildContext context) {
    _context = context;
  }

  // Getters
  int get currentStep => _currentStep;
  List<City> get selectedCities => cityProvider.selectedCities;
  int get totalSteps => 6;
  double get progress => (_currentStep + 1) / totalSteps;

  List<String> get stepTitles => [
    'Výber mesta',
    'Vstupné údaje',
    'Detailné projektové údaje',
    'Notifikácie',
    'Názvy súborov a filtrovanie subjektov',
    'Generovanie dokumentov',
  ];

  List<String> get stepIcons => [
    'location_city',
    'settings',
    'description',
    'notifications',
    'folder',
    'rocket_launch',
  ];

  // Validácia krokov
  bool isStepValid(BuildContext context, int step) {
    switch (step) {
      case 0:
        return cityProvider.selectedCities.isNotEmpty;
      case 1:
        final step2Data = context.read<Step2DataProvider>();
        return step2Data.isValid();
      case 2:
        final step3Data = context.read<Step3DataProvider>();
        return step3Data.isValid();
      case 3:
      // Step 4 - notifikácie sú voliteľné
        return true;
      case 4:
      // ✅ Validácia Step 5 - Filenames
        final step5Data = context.read<Step5DataProvider>();
        final isValid = step5Data.isValid();
        print('🔍 Step 5 validation: $isValid');
        return isValid;
      case 5:
        return true;
      default:
        return false;
    }
  }

  // ✅ NOVÉ: Trigger validáciu aktuálneho stepu
  void validateCurrentStep() {
    if (_context != null) {
      print('🔄 Triggering validation for step $_currentStep');
      notifyListeners();
    }
  }

  // Navigácia
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // Settery
  void setSelectedOffices(List<String> offices) {
    _selectedOffices = offices;
    notifyListeners();
  }

  void setRequestType(String? type) {
    _requestType = type;
    notifyListeners();
  }

  void setEnableNotifications(bool enable) {
    _enableNotifications = enable;
    notifyListeners();
  }

  void setNotificationEmail(String? email) {
    _notificationEmail = email;
    notifyListeners();
  }

  void setDocumentPrefix(String? prefix) {
    _documentPrefix = prefix;
    notifyListeners();
  }

  // Generovanie
  Future<void> generateDocuments(BuildContext context) async {
    _isGenerating = true;
    _generationError = null;
    notifyListeners();

    try {
      final step2Data = context.read<Step2DataProvider>();
      final step3Data = context.read<Step3DataProvider>();
      final step4Data = context.read<Step4NotificationsProvider>();
      final step5Data = context.read<Step5DataProvider>();

      await Future.delayed(const Duration(seconds: 2));

      print('🚀 Generujem dokumenty...');
      final cityNames = cityProvider.selectedCities.map((c) => c.name).join(', ');
      print('Mestá: $cityNames');
      print('Step 2 dáta: ${step2Data.toJson()}');
      print('Step 3 dáta: ${step3Data.toJson()}');
      print('Step 4 dáta:');
      print('  - emailNotificationsEnabled: ${step4Data.emailNotificationsEnabled}');
      print('  - znacka: ${step4Data.znacka}');
      print('  - nazovstavby: ${step4Data.nazovstavby}');
      print('  - firstNotificationDate: ${step4Data.firstNotificationDate}');
      print('  - secondNotificationDate: ${step4Data.secondNotificationDate}');

      // ✅ NOVÉ: Vytvorenie notifikácie po úspešnom generovaní
      if (step4Data.emailNotificationsEnabled) {
        print('📬 Notifikácie SÚ zapnuté - vytvárám notifikáciu...');

        final notificationService = NotificationService();

        try {
          await notificationService.createNotification(
            znacka: step2Data.znacka,
            nazovstavby: step2Data.nazovStavby,
            firstNotificationDate: step4Data.firstNotificationDate ?? DateTime.now().add(const Duration(days: 20)),
            secondNotificationDate: step4Data.secondNotificationDate ?? DateTime.now().add(const Duration(days: 40)),
          );

          print('✅ Notifikácia úspešne vytvorená');
        } catch (notificationError) {
          print('❌ Chyba pri vytváraní notifikácie: $notificationError');
        }
      } else {
        print('⚠️ Notifikácie NIE sú zapnuté - preskakujem vytvorenie');
      }

      print('Step 5 dáta: Úrady s filenames:');
      print('  ${step5Data.exportApplicationsWithFilenames(znacka: step2Data.znacka)}');

      _isGenerating = false;
      notifyListeners();
    } catch (e) {
      _generationError = e.toString();
      _isGenerating = false;
      notifyListeners();
      print('❌ Chyba pri generovaní: $e');
    }
  }

  // Reset
  void reset() {
    _currentStep = 0;
    cityProvider.clearSelection();
    _selectedOffices = [];
    _requestType = null;
    _enableNotifications = false;
    _notificationEmail = null;
    _documentPrefix = null;
    _isGenerating = false;
    _generationError = null;
    notifyListeners();
  }
}