import 'dart:math';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class LocalTenantRepository implements ITenantRepository {
  final Map<String, TenantModel> _tenants = {};

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<void> saveTenant(TenantModel tenant) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _tenants[tenant.id] = tenant;
  }

  @override
  Future<List<TenantModel>> getTenantsForOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For now return all (later filter by ownerId)
    return _tenants.values.toList();
  }

  @override
  Future<TenantModel?> getTenantByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _tenants.values.firstWhere(
        (t) => t.inviteCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper used by the controller to create + save
  Future<TenantModel> createTenant({
    required String fullName,
    required String phone,
    required String cnic,
    required String propertyId,
    required String propertyLabel,
  }) async {
    final tenant = TenantModel(
      id: 'tenant_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      phone: phone.trim(),
      cnic: cnic.trim(),
      propertyId: propertyId,
      propertyLabel: propertyLabel,
      inviteCode: _generateCode(),
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await saveTenant(tenant);
    return tenant;
  }
}