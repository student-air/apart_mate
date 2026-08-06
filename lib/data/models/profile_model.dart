// lib/data/models/profile_model.dart

/// Extended profile data collected during onboarding (profile_setup) and
/// editable later (edit_profile). Kept separate from UserModel, which only
/// holds core auth identity (id, fullName, email, phone, role, photoPath).
class ProfileModel {
  final String userId;
  final String gender;
  final String city;
  final String occupation;
  final String emergencyContact;

  const ProfileModel({
    required this.userId,
    required this.gender,
    required this.city,
    required this.occupation,
    required this.emergencyContact,
  });

  ProfileModel copyWith({
    String? gender,
    String? city,
    String? occupation,
    String? emergencyContact,
  }) {
    return ProfileModel(
      userId: userId,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}