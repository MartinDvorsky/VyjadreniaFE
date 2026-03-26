class ProjectDesigner {
  final int id;
  final String name;
  final String city;
  final String address;
  final String license;
  final String email;
  final String? phone;

  ProjectDesigner({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.license,
    required this.email,
    this.phone,
  });

  factory ProjectDesigner.fromJson(Map<String, dynamic> json) {
    return ProjectDesigner(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      license: json['license'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'license': license,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  // For dropdown display
  String get dropdownLabel => '$name - $license';
}
