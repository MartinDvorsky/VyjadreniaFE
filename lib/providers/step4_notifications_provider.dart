// ========================================
// STEP 4 NOTIFICATIONS PROVIDER
// Uložiť ako: lib/providers/step4_notifications_provider.dart
// ========================================

import 'package:flutter/foundation.dart';

class Step4NotificationsProvider with ChangeNotifier {
  bool _emailNotificationsEnabled = false;  // ✅ Zmena z true na false

  // Údaje notifikácie
  String? _znacka;
  String? _nazovstavby;
  DateTime? _firstNotificationDate;
  DateTime? _secondNotificationDate;

  // Getters
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  String? get znacka => _znacka;
  String? get nazovstavby => _nazovstavby;
  DateTime? get firstNotificationDate => _firstNotificationDate;
  DateTime? get secondNotificationDate => _secondNotificationDate;

  // Setters
  void setEmailNotificationsEnabled(bool value) {
    _emailNotificationsEnabled = value;
    notifyListeners();
  }

  void setNotificationData({
    required bool enabled,
    required String znacka,
    required String nazovstavby,
  }) {
    print('🔔 setNotificationData() volané:');
    print('  - enabled: $enabled');
    print('  - znacka: $znacka');
    print('  - nazovstavby: $nazovstavby');

    _emailNotificationsEnabled = enabled;
    _znacka = znacka;
    _nazovstavby = nazovstavby;

    if (enabled) {
      final today = DateTime.now();
      _firstNotificationDate = today.add(const Duration(days: 20));
      _secondNotificationDate = today.add(const Duration(days: 40));
      print('  - firstNotification: $_firstNotificationDate');
      print('  - secondNotification: $_secondNotificationDate');
    } else {
      _firstNotificationDate = null;
      _secondNotificationDate = null;
    }

    notifyListeners();
  }

  // Reset
  void reset() {
    _emailNotificationsEnabled = false;
    _znacka = null;
    _nazovstavby = null;
    _firstNotificationDate = null;
    _secondNotificationDate = null;
    notifyListeners();
  }

  // Export do JSON
  Map<String, dynamic> toJson() {
    return {
      'emailNotificationsEnabled': _emailNotificationsEnabled,
      'znacka': _znacka,
      'nazovstavby': _nazovstavby,
      'firstNotificationDate': _firstNotificationDate?.toIso8601String(),
      'secondNotificationDate': _secondNotificationDate?.toIso8601String(),
    };
  }

  // Import z JSON
  void fromJson(Map<String, dynamic> json) {
    _emailNotificationsEnabled = json['emailNotificationsEnabled'] ?? false;
    _znacka = json['znacka'];
    _nazovstavby = json['nazovstavby'];
    _firstNotificationDate = json['firstNotificationDate'] != null
        ? DateTime.parse(json['firstNotificationDate'])
        : null;
    _secondNotificationDate = json['secondNotificationDate'] != null
        ? DateTime.parse(json['secondNotificationDate'])
        : null;
    notifyListeners();
  }
}