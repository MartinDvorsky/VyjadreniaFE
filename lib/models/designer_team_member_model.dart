class DesignerTeamMember {
  final int id;
  final String name;
  final String email;
  final String? phone;

  DesignerTeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory DesignerTeamMember.fromJson(Map<String, dynamic> json) {
    return DesignerTeamMember(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  // For dropdown display
  String get dropdownLabel => '$name - $email';
}