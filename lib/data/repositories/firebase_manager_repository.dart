// lib/data/repositories/firebase_manager_repository.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/manager_model.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';

class FirebaseManagerRepository implements IManagerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('managers');

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<void> saveManager(ManagerModel manager) async {
    final id = manager.id.isEmpty ? _col.doc().id : manager.id;
    final toSave = manager.id.isEmpty
        ? ManagerModel(
            id: id,
            fullName: manager.fullName,
            phone: manager.phone,
            cnic: manager.cnic,
            propertyIds: manager.propertyIds,
            propertyLabel: manager.propertyLabel,
            inviteCode: manager.inviteCode.toUpperCase(),
            status: manager.status,
            createdAt: manager.createdAt,
          )
        : manager;

    await _col.doc(toSave.id).set(
          _toMap(toSave),
          SetOptions(merge: true),
        );
  }

  @override
  Future<List<ManagerModel>> getManagersForOwner(String ownerId) async {
    final snap = await _col
        .where('ownerUserId', isEqualTo: ownerId)
        .get();

    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

    @override
  Future<void> markManagerJoined({
    required String managerId,
    required String userId,
  }) async {
    await _col.doc(managerId).set(
      {
        'status': 'joined',
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

    @override
  Future<ManagerModel?> getManagerByUserId(String userId) async {
    if (userId.isEmpty) return null;
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<ManagerModel?> getManagerByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final snap = await _col
        .where('inviteCode', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return _fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  /// Create + save invite (used by Add Manager)
  Future<ManagerModel> createManager({
    required String fullName,
    required String phone,
    required String cnic,
    required List<String> propertyIds,
    required String propertyLabel,
    required String ownerUserId,
  }) async {
    final doc = _col.doc();
    final manager = ManagerModel(
      id: doc.id,
      fullName: fullName.trim(),
      phone: phone.trim(),
      cnic: cnic.trim(),
      propertyIds: propertyIds,
      propertyLabel: propertyLabel,
      inviteCode: _generateCode(),
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await doc.set({
      ..._toMap(manager),
      'ownerUserId': ownerUserId,
    });

    return manager;
  }

  Map<String, dynamic> _toMap(ManagerModel m) {
    return {
      'fullName': m.fullName,
      'phone': m.phone,
      'cnic': m.cnic,
      'propertyIds': m.propertyIds,
      'propertyLabel': m.propertyLabel,
      'inviteCode': m.inviteCode.toUpperCase(),
      'status': m.status,
      'createdAt': Timestamp.fromDate(m.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ManagerModel _fromMap(String id, Map<String, dynamic> d) {
    final rawIds = d['propertyIds'];
    final propertyIds = rawIds is List
        ? rawIds.map((e) => e.toString()).toList()
        : <String>[];

    return ManagerModel(
      id: id,
      fullName: d['fullName'] ?? '',
      phone: d['phone'] ?? '',
      cnic: d['cnic'] ?? '',
      propertyIds: propertyIds,
      propertyLabel: d['propertyLabel'] ?? '',
      inviteCode: (d['inviteCode'] as String? ?? '').toUpperCase(),
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}