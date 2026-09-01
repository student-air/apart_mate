class MaintenancePaymentModel {
  final String id;
  final String propertyId;
  final String tenantUserId;
  final String ownerUserId;
  final String amount;
  final int year;
  final int month;
  final String status; // paid | pending
  final DateTime? paidAt;
  final DateTime createdAt;
  final String tenantName;
  final String propertyLabel;

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
    this.tenantName = '',
    this.propertyLabel = '',
  });
}