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
  final String phone;   // from admin app
  final String email;   // from admin app

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
    this.phone = '',
    this.email = '',
  });

  String get fullAddress {
    final parts = [
      if (address.isNotEmpty) address,
      if (city.isNotEmpty) city,
    ];
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}