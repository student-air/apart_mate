// lib/data/repositories/local/local_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class LocalSocietyRepository implements ISocietyRepository {
  final List<SocietyModel> _societies = [
    const SocietyModel(
      id: 'society_001',
      name: 'Gulshan Heights',
      joinCode: 'RVXBJA',
      address: 'Gulshan-e-Iqbal',
      city: 'Karachi',
      isVerified: true,
      buildingsCount: 3,
      unitsCount: 120,
      foundedYear: 1998,
    ),
    const SocietyModel(
      id: 'society_002',
      name: 'Riverview Enclave',
      joinCode: 'GH842K',
      address: 'DHA Phase 6',
      city: 'Lahore',
      isVerified: true,
      buildingsCount: 5,
      unitsCount: 210,
      foundedYear: 2005,
    ),
  ];

  // Maps "userId:societyId" -> status. Mock always resolves to pending
  // on submit — flip a value in here manually during dev/testing to
  // simulate approval/rejection.
  final Map<String, JoinRequestStatus> _requestStatuses = {};

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
  Future<void> joinSociety({
    required String userId,
    required String societyId,
  }) async {
    await _simulateLatency();
    _requestStatuses[_key(userId, societyId)] = JoinRequestStatus.pending;
  }

  @override
  Future<JoinRequestStatus> getJoinRequestStatus({
    required String userId,
    required String societyId,
  }) async {
    await _simulateLatency();
    return _requestStatuses[_key(userId, societyId)] ?? JoinRequestStatus.pending;
  }

  // lib/data/repositories/local/local_society_repository.dart — add this,
// replacing the earlier non-interface helper:

  @override
  Future<SocietyModel?> getSocietyById(String id) async {
    await _simulateLatency();
    try {
      return _societies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}