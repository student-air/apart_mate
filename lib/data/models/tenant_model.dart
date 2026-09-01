class TenantModel {
  final String id;
  final String fullName;
  final String phone;
  final String cnic;
  final String propertyId;
  final String propertyLabel;
  final String inviteCode;
  final String status;
  final bool maintenancePaid;
  final DateTime createdAt;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;

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
    this.maintenancePaid = false,
    this.ownerName = '',
    this.ownerPhone = '',
    this.ownerEmail = '',
  });
}