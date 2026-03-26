// ========================================
// APPLICATION EDIT MODEL
// Uložiť ako: lib/models/application_edit_model.dart
// ========================================

/// Model pre editáciu úradov v databázovej sekcii
/// (samostatný od Application model používaného pri generovaní)
class ApplicationEdit {
  final int id;

  // Základné údaje úradu
  final String name;
  final String department;
  final String streetAddress;
  final String postalCode;
  final String city;
  final String district;
  final String textType;
  final String submission;
  final String? envelope;

  // Boolean hodnoty (checkboxy)
  final bool technicalSituation;
  final bool situation;
  final bool situationA3;
  final bool broaderRelations;
  final bool fireProtection;
  final bool waterManagement;
  final bool publicHealth;
  final bool railways;
  final bool roads1;
  final bool roads2;
  final bool municipality;

  final String? filename;

  final String? senderIco;
  final String? senderUri;

  ApplicationEdit({
    required this.id,
    required this.name,
    required this.department,
    required this.streetAddress,
    required this.postalCode,
    required this.city,
    required this.district,
    required this.textType,
    required this.submission,
    this.envelope,
    required this.technicalSituation,
    required this.situation,
    required this.situationA3,
    required this.broaderRelations,
    required this.fireProtection,
    required this.waterManagement,
    required this.publicHealth,
    required this.railways,
    required this.roads1,
    required this.roads2,
    required this.municipality,
    this.filename,
    this.senderIco,
    this.senderUri,
  });

  /// Mapovanie text_type z API na UI
  static String mapTextTypeFromApi(String? apiValue) {
    switch (apiValue) {
      case 'N': return 'SPP';
      case 'R': return 'MVSR';
      case 'S': return 'Siete';
      case 'U': return 'Urady';
      case 'V': return 'RUVZ';
      default: return 'Štandardný';
    }
  }

  /// Mapovanie text_type z UI na API
  static String mapTextTypeToApi(String uiValue) {
    switch (uiValue) {
      case 'SPP': return 'N';
      case 'MVSR': return 'R';
      case 'Siete': return 'S';
      case 'Urady': return 'U';
      case 'RUVZ': return 'V';
      default: return 'R';
    }
  }

  /// Mapovanie submission z API na UI
  static String mapSubmissionFromApi(String? apiValue) {
    switch (apiValue) {
      case 'E': return 'Slovensko.sk';
      case 'P': return 'Poštou';
      case 'online': return 'Webová aplikacia';
      case 'M': return 'Mailom';
      default: return 'Email';
    }
  }

  /// Mapovanie submission z UI na API
  static String mapSubmissionToApi(String uiValue) {
    switch (uiValue) {
      case 'Slovensko.sk': return 'E';
      case 'Poštou': return 'P';
      case 'Webová aplikacia': return 'online';
      case 'Mailom': return 'M';
      default: return 'E';
    }
  }

  /// Vytvor z JSON (z API)
  factory ApplicationEdit.fromJson(Map<String, dynamic> json) {
    return ApplicationEdit(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      textType: mapTextTypeFromApi(json['text_type'] as String?),
      submission: mapSubmissionFromApi(json['submission'] as String?),
      envelope: json['envelope'] as String?,
      technicalSituation: json['technical_situation'] as bool? ?? false,
      situation: json['situation'] as bool? ?? false,
      situationA3: json['situation_A3'] as bool? ?? false,
      broaderRelations: json['broader_relations'] as bool? ?? false,
      fireProtection: json['fire_protection'] as bool? ?? false,
      waterManagement: json['water_management'] as bool? ?? false,
      publicHealth: json['public_health'] as bool? ?? false,
      railways: json['railways'] as bool? ?? false,
      roads1: json['roads_1'] as bool? ?? false,
      roads2: json['roads_2'] as bool? ?? false,
      municipality: json['municipality'] as bool? ?? false,
      filename: json['filename'] as String?,
      senderIco: json['sender_ico'] as String?,
      senderUri: json['sender_uri'] as String?,
    );
  }

  /// Konvertuj na JSON (pre API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'street_address': streetAddress,
      'postal_code': postalCode,
      'city': city,
      'district': district,
      'text_type': mapTextTypeToApi(textType),
      'submission': mapSubmissionToApi(submission),
      'envelope': envelope,
      'technical_situation': technicalSituation,
      'situation': situation,
      'situation_A3': situationA3,
      'broader_relations': broaderRelations,
      'fire_protection': fireProtection,
      'water_management': waterManagement,
      'public_health': publicHealth,
      'railways': railways,
      'roads_1': roads1,
      'roads_2': roads2,
      'municipality': municipality,
      'filename': filename,
      'sender_ico': senderIco,
      'sender_uri': senderUri,
    };
  }

  /// Pomocná metóda: vráti ikonu podľa typu úradu
  String getIconByType() {
    if (fireProtection) return '⚡';
    if (waterManagement) return '💧';
    if (publicHealth) return '🏥';
    if (railways) return '🚂';
    if (roads1 || roads2) return '🛣️';
    if (municipality) return '🏛️';
    return '📋';
  }

  /// Pomocná metóda: vráti farbu podľa typu úradu
  String getColorByType() {
    if (fireProtection) return 'orange';
    if (waterManagement) return 'blue';
    if (publicHealth) return 'green';
    if (railways) return 'deepBlue';
    if (roads1 || roads2) return 'amber';
    if (municipality) return 'purple';
    return 'gray';
  }

  /// Kópia s novými hodnotami
  ApplicationEdit copyWith({
    String? name,
    String? department,
    String? streetAddress,
    String? postalCode,
    String? city,
    String? district,
    String? textType,
    String? submission,
    String? envelope,
    bool? technicalSituation,
    bool? situation,
    bool? situationA3,
    bool? broaderRelations,
    bool? fireProtection,
    bool? waterManagement,
    bool? publicHealth,
    bool? railways,
    bool? roads1,
    bool? roads2,
    bool? municipality,
    String? filename,
  }) {
    return ApplicationEdit(
      id: id,
      name: name ?? this.name,
      department: department ?? this.department,
      streetAddress: streetAddress ?? this.streetAddress,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      district: district ?? this.district,
      textType: textType ?? this.textType,
      submission: submission ?? this.submission,
      envelope: envelope ?? this.envelope,
      technicalSituation: technicalSituation ?? this.technicalSituation,
      situation: situation ?? this.situation,
      situationA3: situationA3 ?? this.situationA3,
      broaderRelations: broaderRelations ?? this.broaderRelations,
      fireProtection: fireProtection ?? this.fireProtection,
      waterManagement: waterManagement ?? this.waterManagement,
      publicHealth: publicHealth ?? this.publicHealth,
      railways: railways ?? this.railways,
      roads1: roads1 ?? this.roads1,
      roads2: roads2 ?? this.roads2,
      municipality: municipality ?? this.municipality,
      filename: filename ?? this.filename,
      senderIco: senderIco ?? this.senderIco,
      senderUri: senderUri ?? this.senderUri,
    );
  }
}