class UserModel {
  final int id;
  final String firebaseUid;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isSuperuser;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.fullName,
    required this.isActive,
    required this.isSuperuser,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool,
      isSuperuser: json['is_superuser'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'created_at': createdAt.toIso8601String(),
    };
  }
}