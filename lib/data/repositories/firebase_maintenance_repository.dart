import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class FirebaseMaintenanceRepository implements IMaintenanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('maintenancePayments');

  IPropertyRepository get _properties => Get.find<IPropertyRepository>();

  @override
  Future<String> getMonthlyAmountForProperty(String propertyId) async {
    final p = await _properties.getPropertyById(propertyId);
    if (p == null) return '0';
    if (p.maintenanceBy == 'society_admin') {
      return p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '300';
    }
    return p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '0';
  }

  @override
  Future<List<MaintenancePaymentModel>> getHistoryForProperty(
    String propertyId, {
    int limit = 6,
  }) async {
    final snap = await _col.where('propertyId', isEqualTo: propertyId).get();
    final list = snap.docs.map((d) => _fromMap(d.id, d.data())).toList()
      ..sort((a, b) => (b.year * 12 + b.month).compareTo(a.year * 12 + a.month));
    return list.take(limit).toList();
  }

  @override
  Future<List<MaintenancePaymentModel>> getOwnerOverview(
    String ownerUserId,
  ) async {
    final snap =
        await _col.where('ownerUserId', isEqualTo: ownerUserId).get();
    final list = snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markPaid(String paymentId) async {
    if (paymentId.isEmpty) return;
    await _col.doc(paymentId).set(
      {
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> ensureCurrentMonthPending({
    required String propertyId,
    required String tenantUserId,
    required String ownerUserId,
    required String amount,
  }) async {
    final now = DateTime.now();
    final existing = await _col
        .where('propertyId', isEqualTo: propertyId)
        .where('year', isEqualTo: now.year)
        .where('month', isEqualTo: now.month)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final id = 'maint_${propertyId}_${now.year}_${now.month}';
    await _col.doc(id).set(
      {
        'propertyId': propertyId,
        'tenantUserId': tenantUserId,
        'ownerUserId': ownerUserId,
        'amount': amount,
        'year': now.year,
        'month': now.month,
        'status': 'pending',
        'tenantName': '',
        'propertyLabel': '',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> markCurrentMonthPaidForProperty({
    required String propertyId,
    required String ownerUserId,
    required String tenantUserId,
    required String amount,
    String tenantName = '',
    String propertyLabel = '',
  }) async {
    final now = DateTime.now();
    final id = 'maint_${propertyId}_${now.year}_${now.month}';

    await _col.doc(id).set(
      {
        'propertyId': propertyId,
        'tenantUserId': tenantUserId,
        'ownerUserId': ownerUserId,
        'amount': amount,
        'year': now.year,
        'month': now.month,
        'status': 'paid',
        'tenantName': tenantName,
        'propertyLabel': propertyLabel,
        'paidAt': FieldValue.serverTimestamp(),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  MaintenancePaymentModel _fromMap(String id, Map<String, dynamic> d) {
    return MaintenancePaymentModel(
      id: id,
      propertyId: d['propertyId'] ?? '',
      tenantUserId: d['tenantUserId'] ?? '',
      ownerUserId: d['ownerUserId'] ?? '',
      amount: d['amount']?.toString() ?? '0',
      year: (d['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (d['month'] as num?)?.toInt() ?? DateTime.now().month,
      status: d['status'] ?? 'pending',
      paidAt: (d['paidAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tenantName: d['tenantName'] ?? '',
      propertyLabel: d['propertyLabel'] ?? '',
    );
  }
}