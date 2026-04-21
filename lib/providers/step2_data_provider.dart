// ========================================
// STEP 2 DATA PROVIDER - AKTUALIZOVANÁ VERZIA S DESIGNER TEAM MEMBER
// Uložiť ako: lib/providers/step2_data_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import '../models/project_designer_model.dart';
import '../models/designer_team_member_model.dart';
import '../models/builder_model.dart';
import '../services/user_service.dart';

class BuildingObject {
  String id;
  String name;

  BuildingObject({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory BuildingObject.fromJson(Map<String, dynamic> json) {
    return BuildingObject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class OperationalSet {
  String id;
  String name;

  OperationalSet({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory OperationalSet.fromJson(Map<String, dynamic> json) {
    return OperationalSet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Step2DataProvider with ChangeNotifier {
  Step2DataProvider() {
    tryAutoFillTeamMember();
  }

  // ========== ZÁKLADNÉ ÚDAJE ==========
  String _znacka = '';
  String _nazovStavby = '';
  String _miestoStavby = '';

  // ✅ Builder model s VSD ako default
  BuilderModel _builder = BuilderModel.defaultVSD();
  bool _isCustomBuilder = false;

  // ========== TECHNICKÉ ÚDAJE ==========
  String _katastralneUzemie = '';
  int _pocetSituacii = 1;
  String _mierka = '1:500';
  String _parcelneCislo = '';
  String _listVlastnictva = '';
  String _idStavby = '';
  String _kodStavby = '2315';

  // ========== VSTUPNÉ ÚDAJE ==========
  DateTime? _datumDokumentacie;

  // ✅ NOVÉ: Vedúci projektant (s osvedčením)
  ProjectDesigner? _selectedProjektant;

  // ✅ NOVÉ: Člen tímu, ktorý vypracoval projekt
  DesignerTeamMember? _selectedTeamMember;

  String _typZiadosti = 'Stavebný zámer';
  String _ziadatel = 'Právnická osoba';
  String _suborStavieb = 'Samostatná stavba';
  String _projektovaDokumentacia = 'Príloha listina';
  String _poplatok = 'Nie je prílohou žiadosti';

  // Objekty a prevádzkové súbory
  List<BuildingObject> _objektyStavby = [];
  List<OperationalSet> _prevadzkoveSubory = [];

  // ========== GETTERS ==========
  String get znacka => _znacka;
  String get nazovStavby => _nazovStavby;
  String get miestoStavby => _miestoStavby;

  BuilderModel get builder => _builder;
  bool get isCustomBuilder => _isCustomBuilder;
  String get investor => _builder.investorString;

  String get katastralneUzemie => _katastralneUzemie;
  int get pocetSituacii => _pocetSituacii;
  String get mierka => _mierka;
  String get parcelneCislo => _parcelneCislo;
  String get listVlastnictva => _listVlastnictva;
  String get idStavby => _idStavby;
  String get kodStavby => _kodStavby;
  DateTime? get datumDokumentacie => _datumDokumentacie;

  // ✅ Vedúci projektant
  ProjectDesigner? get selectedProjektant => _selectedProjektant;
  String get projektant => _selectedProjektant?.name ?? '';

  // ✅ NOVÉ: Člen tímu
  DesignerTeamMember? get selectedTeamMember => _selectedTeamMember;
  String get teamMemberName => _selectedTeamMember?.name ?? '';

  String get typZiadosti => _typZiadosti;
  String get ziadatel => _ziadatel;
  String get suborStavieb => _suborStavieb;
  String get projektovaDokumentacia => _projektovaDokumentacia;
  String get poplatok => _poplatok;
  List<BuildingObject> get objektyStavby => _objektyStavby;
  List<OperationalSet> get prevadzkoveSubory => _prevadzkoveSubory;

  Map<String, String> _fieldWarnings = {};

  Map<String, String> get fieldWarnings => _fieldWarnings;

  void setFieldWarnings(Map<String, String> warnings) {
    _fieldWarnings = warnings;
    notifyListeners();
  }

  String? getWarning(String fieldKey) => _fieldWarnings[fieldKey];

  // Dropdown options
  List<String> get typZiadostiOptions => [
    'Ohlásenie stavby',
    'Ohlásenie stavebných úprav',
    'Stavebný zámer',
    'Rozhodnutie o zmene stavebného zámeru',
    'Predčasné užívanie stavby',
    'Dočasné užívanie stavby',
    'Kolaudačné osvedčenie',
    'Zmena v užívaní stavby',
  ];

  List<String> get ziadatelOptions => [
    'Právnická osoba',
    'Fyzická osoba',
    'Fyzická osoba podnikateľ',
  ];

  List<String> get suborStaviebOptions => [
    'Samostatná stavba',
    'Súbor stavieb',
  ];

  List<String> get projektovaDokumentaciaOptions => [
    'Uložená v informačnom systéme',
    'Príloha listina',
  ];

  List<String> get poplatokOptions => [
    'Nie je prílohou žiadosti',
    'Je prílohou žiadosti',
  ];

  List<String> get mierkaOptions => [
    '1:250',
    '1:500',
    '1:1000',
    '1:2000',
  ];

  // ========== SETTERS ==========
  void setZnacka(String value) {
    _znacka = value;
    notifyListeners();
  }

  void setNazovStavby(String value) {
    _nazovStavby = value;
    notifyListeners();
  }

  void setMiestoStavby(String value) {
    _miestoStavby = value;
    notifyListeners();
  }

  void setIsCustomBuilder(bool value) {
    _isCustomBuilder = value;
    if (!value) {
      _builder = BuilderModel.defaultVSD();
    }
    notifyListeners();
  }

  void setBuilder(BuilderModel builder) {
    _builder = builder;
    _isCustomBuilder = true;
    notifyListeners();
  }

  @Deprecated('Use setBuilder instead')
  void setInvestor(String value) {
    notifyListeners();
  }

  void setKatastralneUzemie(String value) {
    _katastralneUzemie = value;
    notifyListeners();
  }

  void setPocetSituacii(int value) {
    _pocetSituacii = value;
    notifyListeners();
  }

  void setMierka(String value) {
    _mierka = value;
    notifyListeners();
  }

  void setParcelneCislo(String value) {
    _parcelneCislo = value;
    notifyListeners();
  }

  void setListVlastnictva(String value) {
    _listVlastnictva = value;
    notifyListeners();
  }

  void setIdStavby(String value) {
    _idStavby = value;
    notifyListeners();
  }

  void setKodStavby(String value) {
    _kodStavby = value;
    notifyListeners();
  }

  void setDatumDokumentacie(DateTime? date) {
    _datumDokumentacie = date;
    notifyListeners();
  }

  // ✅ Setter pre vedúceho projektanta
  void setSelectedProjektant(ProjectDesigner? designer) {
    _selectedProjektant = designer;
    notifyListeners();
  }

  // ✅ NOVÝ: Setter pre člena tímu
  void setSelectedTeamMember(DesignerTeamMember? member) {
    _selectedTeamMember = member;
    notifyListeners();
  }

  @Deprecated('Use setSelectedProjektant instead')
  void setProjektant(String value) {
    notifyListeners();
  }

  void setTypZiadosti(String value) {
    _typZiadosti = value;
    notifyListeners();
  }

  void setZiadatel(String value) {
    _ziadatel = value;
    notifyListeners();
  }

  void setSuborStavieb(String value) {
    _suborStavieb = value;
    notifyListeners();
  }

  void setProjektovaDokumentacia(String value) {
    _projektovaDokumentacia = value;
    notifyListeners();
  }

  void setPoplatok(String value) {
    _poplatok = value;
    notifyListeners();
  }

  // ========== OBJEKTY STAVBY ==========
  void addObjektStavby(BuildingObject obj) {
    _objektyStavby.add(obj);
    notifyListeners();
  }

  void removeObjektStavby(int index) {
    if (index >= 0 && index < _objektyStavby.length) {
      _objektyStavby.removeAt(index);
      notifyListeners();
    }
  }

  void updateObjektStavby(int index, BuildingObject obj) {
    if (index >= 0 && index < _objektyStavby.length) {
      _objektyStavby[index] = obj;
      notifyListeners();
    }
  }

  // ========== PREVÁDZKOVÉ SÚBORY ==========
  void addPrevadzkovySubor(OperationalSet set) {
    _prevadzkoveSubory.add(set);
    notifyListeners();
  }

  void removePrevadzkovySubor(int index) {
    if (index >= 0 && index < _prevadzkoveSubory.length) {
      _prevadzkoveSubory.removeAt(index);
      notifyListeners();
    }
  }

  void updatePrevadzkovySubor(int index, OperationalSet set) {
    if (index >= 0 && index < _prevadzkoveSubory.length) {
      _prevadzkoveSubory[index] = set;
      notifyListeners();
    }
  }

  // ========== VALIDÁCIA ==========
  bool isValid() {
    return _znacka.isNotEmpty &&
        _nazovStavby.isNotEmpty &&
        _miestoStavby.isNotEmpty &&
        _datumDokumentacie != null &&
        _selectedProjektant != null &&
        _selectedTeamMember != null; // ✅ POVINNÝ: Člen tímu, ktorý projekt vypracoval
  }

  // ========== RESET ==========
  void reset() {
    _znacka = '';
    _nazovStavby = '';
    _miestoStavby = '';
    _builder = BuilderModel.defaultVSD();
    _isCustomBuilder = false;
    _katastralneUzemie = '';
    _pocetSituacii = 1;
    _mierka = '1:500';
    _parcelneCislo = '';
    _listVlastnictva = '';
    _idStavby = '';
    _kodStavby = '2315';
    _datumDokumentacie = null;
    _selectedProjektant = null;
    _selectedTeamMember = null; // ✅ NOVÉ
    _typZiadosti = 'Ohlásenie stavby';
    _ziadatel = 'Právnická osoba';
    _suborStavieb = 'Samostatná stavba';
    _projektovaDokumentacia = 'Uložená v informačnom systéme';
    _poplatok = 'Nie je prílohou žiadosti';
    _objektyStavby = [];
    _prevadzkoveSubory = [];
    notifyListeners();
    tryAutoFillTeamMember();
  }

  Future<void> tryAutoFillTeamMember() async {
    try {
      final service = UserService();
      final member = await service.getAutoFillDesignerTeamMember();
      if (member != null && _selectedTeamMember == null) {
        _selectedTeamMember = member;
        notifyListeners();
      }
    } catch (e) {
      // Ignorovať chybu, buď 400 (nastavenie vypnuté) alebo iný problém
    }
  }

  // ========== EXPORT DATA ==========
  Map<String, dynamic> toJson() {
    return {
      'znacka': _znacka,
      'nazovStavby': _nazovStavby,
      'miestoStavby': _miestoStavby,
      'builder': _builder.toJson(),
      'isCustomBuilder': _isCustomBuilder,
      'katastralneUzemie': _katastralneUzemie,
      'pocetSituacii': _pocetSituacii,
      'mierka': _mierka,
      'parcelneCislo': _parcelneCislo,
      'listVlastnictva': _listVlastnictva,
      'idStavby': _idStavby,
      'kodStavby': _kodStavby,
      'datumDokumentacie': _datumDokumentacie?.toIso8601String(),
      'projektant': _selectedProjektant?.toJson(),
      'teamMember': _selectedTeamMember?.toJson(), // ✅ NOVÉ
      'typZiadosti': _typZiadosti,
      'ziadatel': _ziadatel,
      'suborStavieb': _suborStavieb,
      'projektovaDokumentacia': _projektovaDokumentacia,
      'poplatok': _poplatok,
      'objektyStavby': _objektyStavby.map((obj) => obj.toJson()).toList(),
      'prevadzkoveSubory': _prevadzkoveSubory.map((set) => set.toJson()).toList(),
    };
  }

  // ========== IMPORT DATA ==========
  void fromJson(Map<String, dynamic> json) {
    _znacka = json['znacka'] ?? '';
    _nazovStavby = json['nazovStavby'] ?? '';
    _miestoStavby = json['miestoStavby'] ?? '';

    if (json['builder'] != null) {
      _builder = BuilderModel.fromJson(json['builder']);
    }
    _isCustomBuilder = json['isCustomBuilder'] ?? false;

    _katastralneUzemie = json['katastralneUzemie'] ?? '';
    _pocetSituacii = json['pocetSituacii'] ?? 1;
    _mierka = json['mierka'] ?? '1:500';
    _parcelneCislo = json['parcelneCislo'] ?? '';
    _listVlastnictva = json['listVlastnictva'] ?? '';
    _idStavby = json['idStavby'] ?? '';
    _kodStavby = json['kodStavby'] ?? '2315';

    if (json['datumDokumentacie'] != null) {
      _datumDokumentacie = DateTime.parse(json['datumDokumentacie']);
    }

    if (json['projektant'] != null) {
      _selectedProjektant = ProjectDesigner.fromJson(json['projektant']);
    }

    // ✅ NOVÉ: Import team member
    if (json['teamMember'] != null) {
      _selectedTeamMember = DesignerTeamMember.fromJson(json['teamMember']);
    }

    _typZiadosti = json['typZiadosti'] ?? 'Ohlásenie stavby';
    _ziadatel = json['ziadatel'] ?? 'Právnická osoba';
    _suborStavieb = json['suborStavieb'] ?? 'Samostatná stavba';
    _projektovaDokumentacia = json['projektovaDokumentacia'] ?? 'Uložená v informačnom systéme';
    _poplatok = json['poplatok'] ?? 'Nie je prílohou žiadosti';

    if (json['objektyStavby'] != null) {
      _objektyStavby = (json['objektyStavby'] as List)
          .map((obj) => BuildingObject.fromJson(obj))
          .toList();
    }

    if (json['prevadzkoveSubory'] != null) {
      _prevadzkoveSubory = (json['prevadzkoveSubory'] as List)
          .map((set) => OperationalSet.fromJson(set))
          .toList();
    }

    notifyListeners();
  }
}