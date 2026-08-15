import 'package:get/get.dart';
import 'package:apart_mate/data/models/maintenance_payment_model.dart';
import 'package:apart_mate/domain/repositories/i_maintenance_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalMaintenanceRepository implements IMaintenanceRepository {
  final Map<String, MaintenancePaymentModel> _payments = {};

  IPropertyRepository get _properties => Get.find<IPropertyRepository>();

  @override
  Future<String> getMonthlyAmountForProperty(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final p = await _properties.getPropertyById(propertyId);
    if (p == null) return '0';

    if (p.maintenanceBy == 'society_admin') {
      // Stub until admin app is connected
      return p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '300';
    }
    return p.maintenanceAmount.isNotEmpty ? p.maintenanceAmount : '0';
  }

  @override
  Future<List<MaintenancePaymentModel>> getHistoryForProperty(
    String propertyId, {
    int limit = 3,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _payments.values
        .where((e) => e.propertyId == propertyId)
        .toList()
      ..sort((a, b) {
        final ay = a.year * 12 + a.month;
        final by = b.year * 12 + b.month;
        return by.compareTo(ay);
      });
    return list.take(limit).toList();
  }

  @override
  Future<List<MaintenancePaymentModel>> getOwnerOverview(
    String ownerUserId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _payments.values
        .where((e) => e.ownerUserId == ownerUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markPaid(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
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
}