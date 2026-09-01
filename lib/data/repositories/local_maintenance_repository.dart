import 'package:get/get.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalMaintenanceRepository implements IMaintenanceRepository {
  final Map<String, MaintenancePaymentModel> _payments = {};

  IPropertyRepository get _properties => Get.find<IPropertyRepository>();

  @override
  Future<String> getMonthlyAmountForProperty(String propertyId) async {
    final p = await _properties.getPropertyById(propertyId);
    if (p == null) return '0';
    return p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '0';
  }

  @override
  Future<List<MaintenancePaymentModel>> getHistoryForProperty(
    String propertyId, {
    int limit = 6,
  }) async {
    final list = _payments.values
        .where((e) => e.propertyId == propertyId)
        .toList()
      ..sort((a, b) =>
          (b.year * 12 + b.month).compareTo(a.year * 12 + a.month));
    return list.take(limit).toList();
  }

  @override
  Future<List<MaintenancePaymentModel>> getOwnerOverview(
    String ownerUserId,
  ) async {
    return _payments.values
        .where((e) => e.ownerUserId == ownerUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markPaid(String paymentId) async {
    final p = _payments[paymentId];
    if (p == null) return;
    _payments[paymentId] = MaintenancePaymentModel(
      id: p.id,
      propertyId: p.propertyId,
      tenantUserId: p.tenantUserId,
      ownerUserId: p.ownerUserId,
      amount: p.amount,
      year: p.year,
      month: p.month,
      status: 'paid',
      paidAt: DateTime.now(),
      createdAt: p.createdAt,
      tenantName: p.tenantName,
      propertyLabel: p.propertyLabel,
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
    final exists = _payments.values.any(
      (e) =>
          e.propertyId == propertyId &&
          e.year == now.year &&
          e.month == now.month,
    );
    if (exists) return;
    final id = 'maint_${propertyId}_${now.year}_${now.month}';
    _payments[id] = MaintenancePaymentModel(
      id: id,
      propertyId: propertyId,
      tenantUserId: tenantUserId,
      ownerUserId: ownerUserId,
      amount: amount,
      year: now.year,
      month: now.month,
      status: 'pending',
      createdAt: now,
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
    final existing = _payments[id];
    _payments[id] = MaintenancePaymentModel(
      id: id,
      propertyId: propertyId,
      tenantUserId: tenantUserId,
      ownerUserId: ownerUserId,
      amount: amount,
      year: now.year,
      month: now.month,
      status: 'paid',
      paidAt: DateTime.now(),
      createdAt: existing?.createdAt ?? now,
      tenantName: tenantName,
      propertyLabel: propertyLabel,
    );
  }
}