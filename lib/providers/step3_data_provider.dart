// ========================================
// STEP 3 DATA PROVIDER - UPDATED
// Uložiť ako: lib/providers/step3_data_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import '../models/building_purpose_model.dart';

class Step3DataProvider with ChangeNotifier {
  // ========== HLAVNÉ CHECKBOXY ==========
  bool _orhazz = false;
  bool _svp = false;
  bool _ruvz = false;
  bool _mestoObec = false;
  bool _zsr = false;
  bool _cestyI = false;
  bool _cestyII = false;

  // ========== ÚČEL STAVBY (NOVÉ) ==========
  BuildingPurpose? _selectedBuildingPurpose;

  // ========== ŽSR ÚDAJE ==========
  String _zsrStavbaTyp = 'Stavba zasahuje do ochranného pásma';
  String _zsrZeleznicnaTrat = '';
  bool _zsrAnoNie = true;

  // Pre "zasahuje do ochranného pásma"
  String _zsrCisloTrate = '';
  String _zsrZaciatok = '';
  String _zsrKoniec = '';
  String _zsrVzdialenost1 = '';
  String _zsrVzdialenost2 = '';

  // Pre "križuje"
  String _zsrKilometer = '';
  String _zsrStanica1 = '';
  String _zsrStanica2 = '';

  // ========== CESTY ÚDAJE ==========
  String _cestyITyp = 'Bez prílohy';
  String _cestyIITyp = 'Bez prílohy';

  // Getters - Hlavné checkboxy
  bool get orhazz => _orhazz;
  bool get svp => _svp;
  bool get ruvz => _ruvz;
  bool get mestoObec => _mestoObec;
  bool get zsr => _zsr;
  bool get cestyI => _cestyI;
  bool get cestyII => _cestyII;

  // Getters - Účel stavby
  BuildingPurpose? get selectedBuildingPurpose => _selectedBuildingPurpose;

  // Getters - ŽSR
  String get zsrStavbaTyp => _zsrStavbaTyp;
  String get zsrZeleznicnaTrat => _zsrZeleznicnaTrat;
  bool get zsrAnoNie => _zsrAnoNie;
  String get zsrCisloTrate => _zsrCisloTrate;
  String get zsrZaciatok => _zsrZaciatok;
  String get zsrKoniec => _zsrKoniec;
  String get zsrVzdialenost1 => _zsrVzdialenost1;
  String get zsrVzdialenost2 => _zsrVzdialenost2;
  String get zsrKilometer => _zsrKilometer;
  String get zsrStanica1 => _zsrStanica1;
  String get zsrStanica2 => _zsrStanica2;

  // Getters - Cesty
  String get cestyITyp => _cestyITyp;
  String get cestyIITyp => _cestyIITyp;

  // Setters - Hlavné checkboxy
  void setOrhazz(bool value) {
    _orhazz = value;
    notifyListeners();
  }

  void setSvp(bool value) {
    _svp = value;
    notifyListeners();
  }

  void setRuvz(bool value) {
    _ruvz = value;
    notifyListeners();
  }

  void setMestoObec(bool value) {
    _mestoObec = value;
    notifyListeners();
  }

  void setZsr(bool value) {
    _zsr = value;
    if (!value) {
      // Reset ŽSR údajov ak sa checkbox vypne
      _zsrStavbaTyp = 'Stavba zasahuje do ochranného pásma';
      _zsrZeleznicnaTrat = '';
      _zsrAnoNie = true;
      _zsrZaciatok = '';
      _zsrKoniec = '';
      _zsrVzdialenost1 = '';
      _zsrVzdialenost2 = '';
      _zsrKilometer = '';
      _zsrStanica1 = '';
      _zsrStanica2 = '';
      _zsrCisloTrate = '';
    }
    notifyListeners();
  }

  void setCestyI(bool value) {
    _cestyI = value;
    if (!value) {
      _cestyITyp = 'Bez prílohy';
    }
    notifyListeners();
  }

  void setCestyII(bool value) {
    _cestyII = value;
    if (!value) {
      _cestyIITyp = 'Bez prílohy';
    }
    notifyListeners();
  }

  // Setters - Účel stavby
  void setSelectedBuildingPurpose(BuildingPurpose? purpose) {
    _selectedBuildingPurpose = purpose;
    notifyListeners();
  }

  // Setters - ŽSR kompletné dáta
  void setZsrData({
    required String stavbaTyp,
    required String zeleznicnaTrat,
    required String cisloTrate,
    required bool anoNie,
    required String zaciatok,
    required String koniec,
    required String vzdialenost1,
    required String vzdialenost2,
    required String kilometer,
    required String stanica1,
    required String stanica2,
  }) {
    _zsrStavbaTyp = stavbaTyp;
    _zsrZeleznicnaTrat = zeleznicnaTrat;
    _zsrCisloTrate = cisloTrate;
    _zsrAnoNie = anoNie;
    _zsrZaciatok = zaciatok;
    _zsrKoniec = koniec;
    _zsrVzdialenost1 = vzdialenost1;
    _zsrVzdialenost2 = vzdialenost2;
    _zsrKilometer = kilometer;
    _zsrStanica1 = stanica1;
    _zsrStanica2 = stanica2;
    notifyListeners();
  }

  // Setters - Cesty
  void setCestyITyp(String value) {
    _cestyITyp = value;
    notifyListeners();
  }

  void setCestyIITyp(String value) {
    _cestyIITyp = value;
    notifyListeners();
  }

  // Validácia
  bool isValid() {
    return _selectedBuildingPurpose != null;
  }

  // Počet vybratých úradov
  int get selectedOfficesCount {
    int count = 0;
    if (_orhazz) count++;
    if (_svp) count++;
    if (_ruvz) count++;
    if (_mestoObec) count++;
    if (_zsr) count++;
    if (_cestyI) count++;
    if (_cestyII) count++;
    return count;
  }

  // Reset
  void reset() {
    _orhazz = false;
    _svp = false;
    _ruvz = false;
    _mestoObec = false;
    _zsr = false;
    _cestyI = false;
    _cestyII = false;

    _selectedBuildingPurpose = null;

    _zsrStavbaTyp = 'Stavba zasahuje do ochranného pásma';
    _zsrZeleznicnaTrat = '';
    _zsrAnoNie = true;
    _zsrZaciatok = '';
    _zsrKoniec = '';
    _zsrVzdialenost1 = '0.000';
    _zsrVzdialenost2 = '0.000';
    _zsrKilometer = '0.000';
    _zsrStanica1 = '';
    _zsrStanica2 = '';

    _cestyITyp = 'Bez prílohy';
    _cestyIITyp = 'Bez prílohy';

    notifyListeners();
  }

  // Export do JSON
  Map<String, dynamic> toJson() {
    return {
      // Hlavné checkboxy
      'orhazz': _orhazz,
      'svp': _svp,
      'ruvz': _ruvz,
      'mestoObec': _mestoObec,
      'zsr': _zsr,
      'cestyI': _cestyI,
      'cestyII': _cestyII,

      // Účel stavby
      if (_selectedBuildingPurpose != null)
        'buildingPurpose': _selectedBuildingPurpose!.toJson(),

      // ŽSR údaje
      if (_zsr) ...{
        'zsrStavbaTyp': _zsrStavbaTyp,
        'zsrZeleznicnaTrat': _zsrZeleznicnaTrat,
        'zsrAnoNie': _zsrAnoNie,
        if (_zsrStavbaTyp == 'Stavba zasahuje do ochranného pásma') ...{
          'zsrCisloTrate': _zsrCisloTrate,
          'zsrZaciatok': _zsrZaciatok,
          'zsrKoniec': _zsrKoniec,
          'zsrVzdialenost1': _zsrVzdialenost1,
          'zsrVzdialenost2': _zsrVzdialenost2,
        },
        if (_zsrStavbaTyp == 'Stavba križuje') ...{
          'zsrKilometer': _zsrKilometer,
          'zsrStanica1': _zsrStanica1,
          'zsrStanica2': _zsrStanica2,
        },
      },

      // Cesty údaje
      if (_cestyI) 'cestyITyp': _cestyITyp,
      if (_cestyII) 'cestyIITyp': _cestyIITyp,
    };
  }

  // Import z JSON
  void fromJson(Map<String, dynamic> json) {
    _orhazz = json['orhazz'] ?? false;
    _svp = json['svp'] ?? false;
    _ruvz = json['ruvz'] ?? false;
    _mestoObec = json['mestoObec'] ?? false;
    _zsr = json['zsr'] ?? false;
    _cestyI = json['cestyI'] ?? false;
    _cestyII = json['cestyII'] ?? false;

    if (json['buildingPurpose'] != null) {
      _selectedBuildingPurpose = BuildingPurpose.fromJson(json['buildingPurpose']);
    }

    _zsrStavbaTyp = json['zsrStavbaTyp'] ?? 'Stavba zasahuje do ochranného pásma';
    _zsrZeleznicnaTrat = json['zsrZeleznicnaTrat'] ?? '';
    _zsrCisloTrate = json['zsrCisloTrate'] ?? '';
    _zsrAnoNie = json['zsrAnoNie'] ?? true;
    _zsrZaciatok = json['zsrZaciatok'] ?? '';
    _zsrKoniec = json['zsrKoniec'] ?? '';
    _zsrVzdialenost1 = json['zsrVzdialenost1'] ?? '0.000';
    _zsrVzdialenost2 = json['zsrVzdialenost2'] ?? '0.000';
    _zsrKilometer = json['zsrKilometer'] ?? '0.000';
    _zsrStanica1 = json['zsrStanica1'] ?? '';
    _zsrStanica2 = json['zsrStanica2'] ?? '';

    _cestyITyp = json['cestyITyp'] ?? 'Bez prílohy';
    _cestyIITyp = json['cestyIITyp'] ?? 'Bez prílohy';

    notifyListeners();
  }
}