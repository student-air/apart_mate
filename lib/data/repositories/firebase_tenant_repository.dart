// lib/data/repositories/firebase_tenant_repository.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class FirebaseTenantRepository implements ITenantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('tenants');

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<void> saveTenant(TenantModel tenant) async {
    final id = tenant.id.isEmpty ? _col.doc().id : tenant.id;
    final toSave = tenant.id.isEmpty
        ? TenantModel(
            id: id,
            fullName: tenant.fullName,
            phone: tenant.phone,
            cnic: tenant.cnic,
            propertyId: tenant.propertyId,
            propertyLabel: tenant.propertyLabel,
            inviteCode: tenant.inviteCode.toUpperCase(),
            status: tenant.status,
            createdAt: tenant.createdAt,
            ownerName: tenant.ownerName,
            ownerPhone: tenant.ownerPhone,
            ownerEmail: tenant.ownerEmail,
          )
        : tenant;

    await _col.doc(toSave.id).set(
          _toMap(toSave),
          SetOptions(merge: true),
        );
  }

  @override
  Future<List<TenantModel>> getTenantsForOwner(String ownerId) async {
    final snap = await _col.where('ownerUserId', isEqualTo: ownerId).get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  @override
  Future<TenantModel?> getTenantByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final snap = await _col
        .where('inviteCode', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return _fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<void> linkTenantToUser({
    required String userId,
    required TenantModel tenant,
  }) async {
    final id = tenant.id.isEmpty ? _col.doc().id : tenant.id;

    await _col.doc(id).set(
      {
        ..._toMap(tenant),
        'linkedUserId': userId,
        'status': 'joined',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<TenantModel?> getTenantForUser(String userId) async {
    final snap =
        await _col.where('linkedUserId', isEqualTo: userId).limit(1).get();

    if (snap.docs.isEmpty) return null;
    return _fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<void> deleteTenant(String tenantId) async {
    await _col.doc(tenantId).delete();
  }

  /// Create invite — used by Add Tenant (owner).
  /// Writes society + unit fields so Pro Residents can show building/floor/flat.
  Future<TenantModel> createTenant({
    required String fullName,
    required String phone,
    required String cnic,
    required String propertyId,
    required String propertyLabel,
    required String ownerName,
    required String ownerPhone,
    required String ownerEmail,
    required String ownerUserId,
    required String societyId,
    required String building,
    required String floor,
    required String flatNumber,
  }) async {
    final doc = _col.doc();
    final tenant = TenantModel(
      id: doc.id,
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

    await doc.set({
      ..._toMap(tenant),
      'ownerUserId': ownerUserId,
      'societyId': societyId,
      'building': building,
      'floor': floor,
      'flatNumber': flatNumber,
      'linkedUserId': null,
      'status': 'pending',
    });

    return tenant;
  }

  Map<String, dynamic> _toMap(TenantModel t) {
    return {
      'fullName': t.fullName,
      'phone': t.phone,
      'cnic': t.cnic,
      'propertyId': t.propertyId,
      'propertyLabel': t.propertyLabel,
      'inviteCode': t.inviteCode.toUpperCase(),
      'status': t.status,
      'ownerName': t.ownerName,
      'ownerPhone': t.ownerPhone,
      'ownerEmail': t.ownerEmail,
      'createdAt': Timestamp.fromDate(t.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TenantModel _fromMap(String id, Map<String, dynamic> d) {
    return TenantModel(
      id: id,
      fullName: d['fullName'] ?? '',
      phone: d['phone'] ?? '',
      cnic: d['cnic'] ?? '',
      propertyId: d['propertyId'] ?? '',
      propertyLabel: d['propertyLabel'] ?? '',
      inviteCode: (d['inviteCode'] as String? ?? '').toUpperCase(),
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerName: d['ownerName'] ?? '',
      ownerPhone: d['ownerPhone'] ?? '',
      ownerEmail: d['ownerEmail'] ?? '',
    );
  }
}