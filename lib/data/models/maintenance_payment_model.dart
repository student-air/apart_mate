class MaintenancePaymentModel {
  final String id;
  final String propertyId;
  final String tenantUserId;
  final String ownerUserId;
  final String amount; // Rs
  final int year;
  final int month; // 1-12
  final String status; // paid | pending
  final DateTime? paidAt;
  final DateTime createdAt;

  const MaintenancePaymentModel({
    required this.id,
    required this.propertyId,
    required this.tenantUserId,
    required this.ownerUserId,
    required this.amount,
    required this.year,
    required this.month,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });
}