import 'package:apart_mate/data/models/maintenance_payment_model.dart';

abstract class IMaintenanceRepository {
  Future<String> getMonthlyAmountForProperty(String propertyId);
  Future<List<MaintenancePaymentModel>> getHistoryForProperty(
    String propertyId, {
    int limit = 3,
  });
  Future<List<MaintenancePaymentModel>> getOwnerOverview(String ownerUserId);
  Future<void> markPaid(String paymentId);
  Future<void> ensureCurrentMonthPending({
    required String propertyId,
    required String tenantUserId,
    required String ownerUserId,
    required String amount,
  });
}