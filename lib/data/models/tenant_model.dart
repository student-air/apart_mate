class TenantModel {
  final String id;
  final String fullName;
  final String phone;
  final String cnic;
  final String propertyId;
  final String propertyLabel; // e.g. "Flat A-203 · Block A"
  final String inviteCode;    // 6-char alphanumeric
  final String status;        // pending | joined
  final DateTime createdAt;

  const TenantModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.cnic,
    required this.propertyId,
    required this.propertyLabel,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
  });
}