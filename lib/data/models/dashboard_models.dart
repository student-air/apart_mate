// lib/data/models/dashboard_models.dart

class DashboardStatus {
  final bool ownerVerified;
  final bool propertyApproved;
  final String tenantStatus; // e.g. "Occupied", "Vacant"
  final bool documentsVerified;

  const DashboardStatus({
    required this.ownerVerified,
    required this.propertyApproved,
    required this.tenantStatus,
    required this.documentsVerified,
  });
}

class TenantInfo {
  final String name;
  final String phone;
  final DateTime agreementStart;
  final DateTime agreementEnd;

  const TenantInfo({
    required this.name,
    required this.phone,
    required this.agreementStart,
    required this.agreementEnd,
  });

  int get daysRemaining => agreementEnd.difference(DateTime.now()).inDays;
}

class UpdateItem {
  final String id;
  final String title;
  final String postedBy;
  final DateTime postedAt;
  final UpdateType type;

  const UpdateItem({
    required this.id,
    required this.title,
    required this.postedBy,
    required this.postedAt,
    required this.type,
  });
}

enum UpdateType { announcement, propertyUpdate, verification }

class DashboardData {
  final String societyName;
  final String flatNumber;
  final String block;
  final String tower;
  final DashboardStatus status;
  final TenantInfo? currentTenant;
  final String propertyType;
  final String flatType;
  final String areaSqFt;
  final String electricityType;
  final String gasType;
  final String furnishing;
  final List<UpdateItem> updates;

  const DashboardData({
    required this.societyName,
    required this.flatNumber,
    required this.block,
    required this.tower,
    required this.status,
    this.currentTenant,
    required this.propertyType,
    required this.flatType,
    required this.areaSqFt,
    required this.electricityType,
    required this.gasType,
    required this.furnishing,
    required this.updates,
  });
}