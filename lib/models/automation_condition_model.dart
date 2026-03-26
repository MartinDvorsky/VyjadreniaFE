/// Model pre podmienku automatizácie
///
/// Reprezentuje jednu podmienku priraďovania úradu k mestám
/// - NULL region, NULL district -> celá SR
/// - region='KE', district=NULL -> celý Košický kraj
/// - region='KE', district='MI' -> len okres Michalovce
class AutomationCondition {
  final int id;
  final int bondId;
  final String? region;  // NULL = všetky kraje
  final String? district; // NULL = všetky okresy

  AutomationCondition({
    required this.id,
    required this.bondId,
    this.region,
    this.district,
  });

  /// Vytvor z JSON
  factory AutomationCondition.fromJson(Map<String, dynamic> json) {
    return AutomationCondition(
      id: json['id'] as int,
      bondId: json['bond_id'] as int,
      region: json['region'] as String?,
      district: json['district'] as String?,
    );
  }

  /// Konvertuj na JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bond_id': bondId,
      'region': region,
      'district': district,
    };
  }

  /// Vráti popisný text podmienky
  String get displayText {
    if (region == null && district == null) {
      return 'Celá SR';
    } else if (region != null && district == null) {
      return '$region kraj (všetky okresy)';
    } else if (region != null && district != null) {
      return '$region - $district';
    }
    return 'Neznáma podmienka';
  }

  /// Vráti ikonu podľa typu podmienky
  String get icon {
    if (region == null && district == null) {
      return '🇸🇰'; // Celá SR
    } else if (region != null && district == null) {
      return '🗺️'; // Celý kraj
    }
    return '📍'; // Konkrétny okres
  }

  @override
  String toString() {
    return 'AutomationCondition(id: $id, bondId: $bondId, region: $region, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationCondition &&
        other.id == id &&
        other.bondId == bondId &&
        other.region == region &&
        other.district == district;
  }

  @override
  int get hashCode {
    return Object.hash(id, bondId, region, district);
  }
}