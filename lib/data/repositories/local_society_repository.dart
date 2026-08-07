// lib/data/repositories/local/local_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class LocalSocietyRepository implements ISocietyRepository {
  final List<SocietyModel> _societies = [
    const SocietyModel(
      id: 'society_001',
      name: 'Riverview Enclave',
      joinCode: 'GH842K',
      address: 'Gulshan-e-Iqbal',
      city: 'Karachi',
      isVerified: true,
      buildingsCount: 3,
      unitsCount: 120,
      foundedYear: 2013,
    ),
    const SocietyModel(
      id: 'society_002',
      name: 'Gulshan Heights',
      joinCode: 'RVXBJA',
      address: 'Nawab Colony',
      city: 'Mian Channu',
      isVerified: true,
      buildingsCount: 3,
      unitsCount: 210,
      foundedYear: 2013,
    ),
  ];

  final Set<String> _memberships = {};

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 600));

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
    _memberships.add('$userId:$societyId');
  }
}