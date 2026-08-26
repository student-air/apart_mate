// lib/data/repositories/firebase_society_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class FirebaseSocietyRepository implements ISocietyRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _societies =>
      _db.collection('societies');

  CollectionReference<Map<String, dynamic>> get _joinRequests =>
      _db.collection('joinRequests');

  @override
  Future<SocietyModel?> getSocietyByJoinCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final snap = await _societies
        .where('joinCode', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return _fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<SocietyModel?> getSocietyById(String id) async {
    final doc = await _societies.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> joinSociety({
    required String userId,
    required String societyId,
  }) async {
    // Block duplicate pending request
    final existing = await _joinRequests
        .where('userId', isEqualTo: userId)
        .where('societyId', isEqualTo: societyId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    final user = await _db.collection('users').doc(userId).get();
    final u = user.data() ?? {};

    await _joinRequests.add({
      'userId': userId,
      'societyId': societyId, // Pro society doc id (= admin uid )
      'role': u['role'] ?? 'owner',
      'status': 'pending',
      'fullName': u['fullName'] ?? '',
      'email': u['email'] ?? '',
      'phone': u['phone'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<JoinRequestInfo> getJoinRequestInfo({
    required String userId,
    required String societyId,
  }) async {
    // No orderBy → avoids composite index; take first match
    final snap = await _joinRequests
        .where('userId', isEqualTo: userId)
        .where('societyId', isEqualTo: societyId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      return JoinRequestInfo(
        status: Joinrequeststatus.pending,
        submittedAt: DateTime.now(),
      );
    }

    final data = snap.docs.first.data();
    final statusStr = (data['status'] as String?)?.toLowerCase() ?? 'pending';
    final status = switch (statusStr) {
      'approved' || 'accepted' => Joinrequeststatus.approved,
      'rejected' => Joinrequeststatus.rejected,
      _ => Joinrequeststatus.pending,
    };

    final ts = data['createdAt'] ?? data['submittedAt'];
    final submittedAt =
        ts is Timestamp ? ts.toDate() : DateTime.now();

    return JoinRequestInfo(status: status, submittedAt: submittedAt);
  }

  /// Society id from the user's join request (pending or approved).
  /// Used so pending users reopen on request status, not join code.
  @override
  Future<String?> getSocietyIdForUser(String userId) async {
    final snap = await _joinRequests
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final id = snap.docs.first.data()['societyId'] as String?;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  @override
  Future<List<SocietyBuildingInfo>> getBuildings(String societyId) async {
    final snap = await _societies.doc(societyId).collection('buildings').get();

    final list = <SocietyBuildingInfo>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final name = (data['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;

      final details = data['details'] as Map<String, dynamic>?;
      final totalFloors = (details?['totalFloors'] as num?)?.toInt() ?? 0;

      list.add(
        SocietyBuildingInfo(
          id: doc.id,
          name: name,
          totalFloors: totalFloors,
        ),
      );
    }

    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<int> getFloorCountForBuilding(
    String societyId,
    String buildingId,
  ) async {
    final doc =
        await _societies.doc(societyId).collection('buildings').doc(buildingId).get();

    if (!doc.exists) return 0;
    final details = doc.data()?['details'] as Map<String, dynamic>?;
    return (details?['totalFloors'] as num?)?.toInt() ?? 0;
  }

  SocietyModel _fromMap(String id, Map<String, dynamic> data) {
  return SocietyModel(
    id: id,
    name: data['name'] ?? '',
    ownerName: data['ownerName'] ?? '',
    joinCode: data['joinCode'] ?? '',
    address: data['address'] ?? '',
    city: data['city'] ?? '',
    isVerified: data['registrationStatus'] == 'approved',
    buildingsCount: 0,
    unitsCount: 0,
    foundedYear: DateTime.now().year,
    phone: data['contactNumber'] ?? '',
    email: '',
  );
}
}