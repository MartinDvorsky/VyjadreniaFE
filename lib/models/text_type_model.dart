// ========================================
// TEXT TYPE MODEL
// lib/models/text_type_model.dart
// ========================================

class TextType {
  final int id;
  final String type;
  final String text;

  TextType({
    required this.id,
    required this.type,
    required this.text,
  });

  factory TextType.fromJson(Map<String, dynamic> json) {
    return TextType(
      id: json['id'] as int,
      type: json['type'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'TextType(id: $id, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
