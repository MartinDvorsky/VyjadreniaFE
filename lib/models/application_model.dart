// ========================================
// APPLICATION MODEL - OPRAVENÝ
// Uložiť ako: lib/models/application_model.dart
// ========================================

class Application {
  final int id;
  final int applicationId;
  final int cityId;

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

  Application({
    required this.id,
    required this.applicationId,
    required this.cityId,
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

  factory Application.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final applicationId = json['application_id'] as int? ?? id; // ✅ fallback na id

    return Application(
      id: id,
      applicationId: applicationId,
      cityId: json['city_id'] as int? ?? 0,

      // String polia s fallback na prázdny string
      name: json['name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      streetAddress: json['street_address'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      textType: json['text_type'] as String? ?? '',
      submission: json['submission'] as String? ?? '',
      envelope: json['envelope'] as String?,

      // Boolean polia zostávajú ako boli
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'city_id': cityId,
      'name': name,
      'department': department,
      'street_address': streetAddress,
      'postal_code': postalCode,
      'city': city,
      'district': district,
      'text_type': textType,
      'submission': submission,
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

  /// Kópia s novým filename
  Application copyWith({String? filename}) {
    return Application(
      id: id,
      applicationId: applicationId,
      cityId: cityId,
      name: name,
      department: department,
      streetAddress: streetAddress,
      postalCode: postalCode,
      city: city,
      district: district,
      textType: textType,
      submission: submission,
      envelope: envelope,
      technicalSituation: technicalSituation,
      situation: situation,
      situationA3: situationA3,
      broaderRelations: broaderRelations,
      fireProtection: fireProtection,
      waterManagement: waterManagement,
      publicHealth: publicHealth,
      railways: railways,
      roads1: roads1,
      roads2: roads2,
      municipality: municipality,
      filename: filename ?? this.filename,
      senderIco: senderIco,
      senderUri: senderUri,
    );
  }
}