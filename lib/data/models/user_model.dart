class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? photoPath;
  final String? propertyType; // 'society' | 'independent' | null

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.photoPath,
    this.propertyType,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((e) => e.isNotEmpty ? e[0] : '').join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? photoPath,
    String? propertyType,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoPath: photoPath ?? this.photoPath,
      propertyType: propertyType ?? this.propertyType,
    );
  }
}