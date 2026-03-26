// lib/models/builder_model.dart
class BuilderModel {
  final String name;
  final String obec;
  final String ulica;
  final String cisloDomu;
  final String psc;
  final String ico;
  final String email;
  final String telefon;
  final String typ; // 'Fyzická osoba', 'Právnická osoba', 'Fyzická osoba podnikateľ'
  final String? menoLegalEntity;
  final String? emailLegalEntity;
  final String? typOpravnenia;

  BuilderModel({
    required this.name,
    required this.obec,
    required this.ulica,
    required this.cisloDomu,
    required this.psc,
    required this.ico,
    required this.email,
    required this.telefon,
    required this.typ,
    this.menoLegalEntity,
    this.emailLegalEntity,
    this.typOpravnenia,
  });

  // ✅ Factory konštruktor pre VSD default hodnoty
  factory BuilderModel.defaultVSD() {
    return BuilderModel(
      name: 'Východoslovenská distribučná, a. s.',
      obec: 'Košice',
      ulica: 'Mlynská',
      cisloDomu: '31',  // Doplň ak máš číslo domu
      psc: '042 91',
      ico: '36599361',  // Doplň správne IČO ak vieš
      email: 'mital@elprokan.sk',  // Doplň ak máš email
      telefon: '0948 042 013',  // Doplň ak máš telefón
      typ: 'Právnická osoba',
    );
  }

  // Vypočítaná property pre plnú adresu
  String get fullAddress => '$ulica, $psc $obec';

  // Vypočítaná property pre úplný investor string (ako máš teraz)
  String get investorString => '$name, $ulica, $psc $obec';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'obec': obec,
      'ulica': ulica,
      'cisloDo mu': cisloDomu,
      'psc': psc,
      'ico': ico,
      'email': email,
      'telefon': telefon,
      'typ': typ,
      'menoLegalEntity': menoLegalEntity,
      'emailLegalEntity': emailLegalEntity,
      'typOpravnenia': typOpravnenia,
    };
  }

  factory BuilderModel.fromJson(Map<String, dynamic> json) {
    return BuilderModel(
      name: json['name'] ?? '',
      obec: json['obec'] ?? '',
      ulica: json['ulica'] ?? '',
      cisloDomu: json['cisloDo mu'] ?? '',
      psc: json['psc'] ?? '',
      ico: json['ico'] ?? '',
      email: json['email'] ?? '',
      telefon: json['telefon'] ?? '',
      typ: json['typ'] ?? 'Fyzická osoba',
      menoLegalEntity: json['menoLegalEntity'],
      emailLegalEntity: json['emailLegalEntity'],
      typOpravnenia: json['typOpravnenia'],
    );
  }
}