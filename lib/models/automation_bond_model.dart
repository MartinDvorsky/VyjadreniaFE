import 'automation_condition_model.dart';

/// Model pre automation bond (väzba úrad + automatizácia)
///
/// Reprezentuje automatické priraďovanie úradu k mestám
/// Jeden bond môže mať viacero podmienok (conditions)
class AutomationBond {
  final int id;
  final int applicationId;
  final bool active;
  final List<AutomationCondition> conditions;

  // Voliteľné - načítané z joined query
  final String? applicationName;
  final String? applicationDepartment;
  final String? applicationCity;

  AutomationBond({
    required this.id,
    required this.applicationId,
    required this.active,
    this.conditions = const [],
    this.applicationName,
    this.applicationDepartment,
    this.applicationCity,
  });

  /// Vytvor z JSON (detail response s podmienkami)
  factory AutomationBond.fromJson(Map<String, dynamic> json) {
    return AutomationBond(
      id: json['id'] as int,
      applicationId: json['application_id'] as int,
      active: json['active'] as bool? ?? true,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((c) => AutomationCondition.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      applicationName: json['application_name'] as String?,
      applicationDepartment: json['application_department'] as String?,
      applicationCity: json['application_city'] as String?,
    );
  }

  /// Konvertuj na JSON (pre API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'active': active,
      'conditions': conditions.map((c) => c.toJson()).toList(),
    };
  }

  /// Vytvor kópiu s novými hodnotami
  AutomationBond copyWith({
    int? id,
    int? applicationId,
    bool? active,
    List<AutomationCondition>? conditions,
    String? applicationName,
    String? applicationDepartment,
    String? applicationCity,
  }) {
    return AutomationBond(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      active: active ?? this.active,
      conditions: conditions ?? this.conditions,
      applicationName: applicationName ?? this.applicationName,
      applicationDepartment: applicationDepartment ?? this.applicationDepartment,
      applicationCity: applicationCity ?? this.applicationCity,
    );
  }

  /// Počet podmienok
  int get conditionsCount => conditions.length;

  /// Zoznam všetkých okresov (pre quick display)
  String get districtsSummary {
    if (conditions.isEmpty) return 'Žiadne podmienky';

    final districts = conditions
        .map((c) => c.displayText)
        .take(3)
        .join(', ');

    if (conditions.length > 3) {
      return '$districts (+${conditions.length - 3})';
    }
    return districts;
  }

  /// Status ikona
  String get statusIcon => active ? '✅' : '❌';

  /// Status text
  String get statusText => active ? 'Aktívne' : 'Neaktívne';

  @override
  String toString() {
    return 'AutomationBond(id: $id, applicationId: $applicationId, active: $active, conditions: ${conditions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationBond &&
        other.id == id &&
        other.applicationId == applicationId &&
        other.active == active;
  }

  @override
  int get hashCode {
    return Object.hash(id, applicationId, active);
  }
}