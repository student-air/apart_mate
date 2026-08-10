// lib/data/repositories/local_dashboard_repository.dart

import 'package:apart_mate/data/models/dashboard_models.dart';
import 'package:apart_mate/domain/repositories/i_dashboard_repository.dart';

class LocalDashboardRepository implements IDashboardRepository {
  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<DashboardData> getDashboardData(String userId) async {
    await _simulateLatency();

    final now = DateTime.now();

    return DashboardData(
      societyName: 'Gulshan Heights',
      flatNumber: 'A-203',
      block: 'Block A',
      tower: 'Tower 2',
      status: const DashboardStatus(
        ownerVerified: true,
        propertyApproved: true,
        tenantStatus: 'Occupied',
        documentsVerified: true,
      ),
      currentTenant: TenantInfo(
        name: 'Ahmed Ali',
        phone: '+92 300 1234567',
        agreementStart: DateTime(2026, 1, 1),
        agreementEnd: DateTime(2026, 12, 31),
      ),
      propertyType: 'Apartment',
      flatType: '3 Bed',
      areaSqFt: '1350',
      electricityType: 'Government Meter',
      gasType: 'Available',
      furnishing: 'Furnished',
      updates: [
        UpdateItem(
          id: 'u1',
          title: 'Water supply maintenance on 15 May 2026',
          postedBy: 'Admin',
          postedAt: now.subtract(const Duration(hours: 2)),
          type: UpdateType.announcement,
        ),
        UpdateItem(
          id: 'u2',
          title: 'Your property update has been approved',
          postedBy: 'Admin',
          postedAt: now.subtract(const Duration(days: 1)),
          type: UpdateType.propertyUpdate,
        ),
        UpdateItem(
          id: 'u3',
          title: 'Tenancy agreement for Flat A-203 verified',
          postedBy: 'Admin',
          postedAt: now.subtract(const Duration(days: 2)),
          type: UpdateType.verification,
        ),
      ],
    );
  }
}