// lib/data/repositories/local_tenant_repository.dart

import 'dart:math';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class LocalTenantRepository implements ITenantRepository {
  /// userId → tenantId (joined tenants for the current app user)
  final Map<String, String> _userTenantIds = {};

  final Map<String, TenantModel> _tenants = {
    'tenant_demo_1': TenantModel(
      id: 'tenant_demo_1',
      fullName: 'Sara Ahmed',
      phone: '03001234567',
      cnic: '35202-1234567-8',
      propertyId: 'property_demo_google_2',
      propertyLabel: 'Flat B-501 · Block B',
      inviteCode: 'T4QWE5',
      status: 'pending',
      createdAt: DateTime.now(),
      // Demo owner contact (shown on tenant profile after join)
      ownerName: 'Armaghan',
      ownerPhone: '03001112233',
      ownerEmail: 'owner@example.com',
    ),
  };

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
    // Later: filter by ownerId / property ownership
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

  @override
  Future<void> linkTenantToUser({
    required String userId,
    required TenantModel tenant,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _tenants[tenant.id] = tenant;
    _userTenantIds[userId] = tenant.id;
  }

  @override
  Future<TenantModel?> getTenantForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final tenantId = _userTenantIds[userId];
    if (tenantId == null) return null;
    return _tenants[tenantId];
  }

  @override
Future<void> deleteTenant(String tenantId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  _tenants.remove(tenantId);
}

  /// Create + save invite (owner contact exported for tenant profile)
  Future<TenantModel> createTenant({
    required String fullName,
    required String phone,
    required String cnic,
    required String propertyId,
    required String propertyLabel,
    required String ownerName,
    required String ownerPhone,
    required String ownerEmail,
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
      ownerName: ownerName.trim(),
      ownerPhone: ownerPhone.trim(),
      ownerEmail: ownerEmail.trim(),
    );
    await saveTenant(tenant);
    return tenant;
  }
}