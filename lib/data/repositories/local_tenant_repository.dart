  import 'dart:math';
  import 'package:apart_mate/data/models/tenant_model.dart';
  import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

  class LocalTenantRepository implements ITenantRepository {
    //final Map<String, TenantModel> _tenants = {};

      /// userId → tenantId (joined tenants for the current app user)
  final Map<String, String> _userTenantIds = {};

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
    ),
  };
  }