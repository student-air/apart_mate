// lib/data/models/society_model.dart

class SocietyModel {
  final String id;
  final String name;
  final String joinCode;
  final String address;
  final String city;
  final bool isVerified;
  final int buildingsCount;
  final int unitsCount;
  final int foundedYear;

  const SocietyModel({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.address,
    required this.city,
    required this.isVerified,
    required this.buildingsCount,
    required this.unitsCount,
    required this.foundedYear,
  });
}