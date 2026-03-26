// ========================================
// BUILDING PURPOSE MODEL
// Uložiť ako: lib/models/building_purpose_model.dart
// ========================================

class BuildingPurpose {
  final int id;
  final String purposeName;
  final String text;
  final String documentForm; // 'old' alebo 'new'

  BuildingPurpose({
    required this.id,
    required this.purposeName,
    required this.text,
    required this.documentForm,
  });

  // Vytvor BuildingPurpose objekt z JSON
  factory BuildingPurpose.fromJson(Map<String, dynamic> json) {
    return BuildingPurpose(
      id: json['id'] as int,
      purposeName: json['purpose_name'] as String,
      text: json['text'] as String,
      documentForm: json['document_form'] as String,
    );
  }

  // Konvertuj BuildingPurpose objekt na JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purpose_name': purposeName,
      'text': text,
      'document_form': documentForm,
    };
  }

  @override
  String toString() {
    return 'BuildingPurpose(id: $id, purposeName: $purposeName, documentForm: $documentForm)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuildingPurpose && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}