import 'package:apart_mate/data/models/tenant_model.dart';

abstract class ITenantRepository {
  Future<void> saveTenant(TenantModel tenant);
  Future<List<TenantModel>> getTenantsForOwner(String ownerId);
  Future<TenantModel?> getTenantByCode(String code);
}