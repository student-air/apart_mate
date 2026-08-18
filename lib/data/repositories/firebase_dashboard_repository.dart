// lib/data/repositories/firebase_dashboard_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/dashboard_models.dart';
import 'package:apart_mate/domain/repositories/i_dashboard_repository.dart';

/// Builds DashboardData from Firestore (properties, societies, tenants, updates).
/// Prefer the controller’s own property/society loads for the main UI;
/// this fills the legacy DashboardData shape if anything still calls it.
class FirebaseDashboardRepository implements IDashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<DashboardData> getDashboardData(String userId) async {
    // 1) Active properties for owner
    final propSnap = await _db
        .collection('properties')
        .where('userId', isEqualTo: userId)
        .where('claimStatus', isEqualTo: 'active')
        .get();

    final propDocs = propSnap.docs;
    final primary = propDocs.isNotEmpty ? propDocs.first.data() : null;
    final primaryId = propDocs.isNotEmpty ? propDocs.first.id : '';

    final societyId = (primary?['societyId'] as String?) ?? '';
    String societyName = '';
    if (societyId.isNotEmpty) {
      final sDoc = await _db.collection('societies').doc(societyId).get();
      societyName = (sDoc.data()?['name'] as String?) ?? '';
    }

    final isOccupied = primary?['isOccupied'] == true;
    final occupiedBy = (primary?['occupiedBy'] as String?) ?? '';

    // 2) Current tenant for primary property (if occupied)
    TenantInfo? currentTenant;
    if (isOccupied && primaryId.isNotEmpty) {
      final tSnap = await _db
          .collection('tenants')
          .where('propertyId', isEqualTo: primaryId)
          .where('status', isEqualTo: 'joined')
          .limit(1)
          .get();

      if (tSnap.docs.isNotEmpty) {
        final t = tSnap.docs.first.data();
        final now = DateTime.now();
        currentTenant = TenantInfo(
          name: t['fullName'] ?? '',
          phone: t['phone'] ?? '',
          // No agreement dates on TenantModel yet — use year bounds as placeholders
          agreementStart: DateTime(now.year, 1, 1),
          agreementEnd: DateTime(now.year, 12, 31),
        );
      }
    }

    // 3) Recent updates (newest first, max 5)
    final uSnap = await _db.collection('updates').get();
    final updateItems = uSnap.docs.map((d) {
      final data = d.data();
      final postedAt =
          (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      return UpdateItem(
        id: d.id,
        title: data['title'] ?? '',
        postedBy: data['postedBy'] ?? 'Admin',
        postedAt: postedAt,
        type: _mapUpdateType(data['type'] as String?),
      );
    }).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));

    final limitedUpdates = updateItems.take(5).toList();

    final hasProperty = primary != null;

    return DashboardData(
      societyName: societyName.isEmpty ? '—' : societyName,
      flatNumber: primary?['flatNumber'] ?? '—',
      block: primary?['building'] ?? '—',
      tower: '',
      status: DashboardStatus(
        ownerVerified: true,
        propertyApproved: hasProperty,
        tenantStatus: isOccupied
            ? (occupiedBy.isEmpty ? 'Occupied' : occupiedBy)
            : 'Vacant',
        documentsVerified: hasProperty,
      ),
      currentTenant: currentTenant,
      propertyType: primary?['propertyType'] ?? '',
      flatType: primary?['flatType'] ?? '',
      areaSqFt: primary?['areaSqFt']?.toString() ?? '',
      electricityType: primary?['meterType'] ?? '',
      gasType: (primary?['hasGas'] == true) ? 'Available' : 'Not available',
      furnishing: primary?['furnishing'] ?? '',
      updates: limitedUpdates,
    );
  }

  UpdateType _mapUpdateType(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'security':
      case 'announcement':
        return UpdateType.announcement;
      case 'verification':
        return UpdateType.verification;
      default:
        return UpdateType.propertyUpdate;
    }
  }
}