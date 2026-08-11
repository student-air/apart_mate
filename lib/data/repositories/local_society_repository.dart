// lib/data/repositories/local/local_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class LocalSocietyRepository implements ISocietyRepository {
  final List<SocietyModel> _societies = [
    const SocietyModel(
      id: 'society_001',
      name: 'Gulshan Heights',
      joinCode: 'GH842K',
      address: 'Gulshan-e-Iqbal',
      city: 'Karachi',
      isVerified: true,
      buildingsCount: 3,
      unitsCount: 120,
      foundedYear: 2010,
    ),
    const SocietyModel(
      id: 'society_002',
      name: 'Riverview Enclave',
      joinCode: 'RVXBJA',
      address: 'DHA Phase 6',
      city: 'Lahore',
      isVerified: true,
      buildingsCount: 5,
      unitsCount: 210,
      foundedYear: 2012,
    ),
  ];

  late final Map<String, JoinRequestInfo> _requests = {
    // Demo accounts are pre-approved members of Gulshan Heights.
    '${LocalAuthRepository.demoGoogleUserId}:society_001': JoinRequestInfo(
      status: Joinrequeststatus.approved,
      submittedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    '${LocalAuthRepository.demoAppleUserId}:society_001': JoinRequestInfo(
      status: Joinrequeststatus.approved,
      submittedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  };

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 600));

  String _key(String userId, String societyId) => '$userId:$societyId';

  @override
  Future<SocietyModel?> getSocietyByJoinCode(String code) async {
    await _simulateLatency();
    final normalized = code.trim().toUpperCase();
    try {
      return _societies.firstWhere((s) => s.joinCode == normalized);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SocietyModel?> getSocietyById(String id) async {
    await _simulateLatency();
    try {
      return _societies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> joinSociety({
    required String userId,
    required String societyId,
  }) async {
    await _simulateLatency();
    _requests[_key(userId, societyId)] = JoinRequestInfo(
      status: Joinrequeststatus.approved,
      submittedAt: DateTime.now(),
    );
  }

  @override
  Future<JoinRequestInfo> getJoinRequestInfo({
    required String userId,
    required String societyId,
  }) async {
    await _simulateLatency();
    return _requests[_key(userId, societyId)] ??
        JoinRequestInfo(status: Joinrequeststatus.pending, submittedAt: DateTime.now());
  }

  @override
  Future<String?> getSocietyIdForUser(String userId) async {
    await _simulateLatency();
    for (final entry in _requests.entries) {
      final parts = entry.key.split(':');
      if (parts.first == userId) return parts.last;
    }
    return null;
  }
}