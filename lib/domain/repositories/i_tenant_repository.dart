import 'package:apart_mate/data/models/tenant_model.dart';

abstract class ITenantRepository {
  Future<void> saveTenant(TenantModel tenant);
  Future<List<TenantModel>> getTenantsForOwner(String ownerId);
  Future<TenantModel?> getTenantByCode(String code);

  /// Link the logged-in user to a joined tenant (after confirm).
  Future<void> linkTenantToUser({
    required String userId,
    required TenantModel tenant,
  });

  /// Load that user's joined tenant (for dashboard without route args).
  Future<TenantModel?> getTenantForUser(String userId);
  Future<void> deleteTenant(String tenantId);
}