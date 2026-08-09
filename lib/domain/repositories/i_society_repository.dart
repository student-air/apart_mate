// lib/domain/repositories/i_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';

enum JoinRequestStatus { pending, approved, rejected }

class JoinRequestInfo {
  final JoinRequestStatus status;
  final DateTime submittedAt;

  const JoinRequestInfo({
    required this.status,
    required this.submittedAt,
  });
}

abstract class ISocietyRepository {
  Future<SocietyModel?> getSocietyByJoinCode(String code);

  Future<SocietyModel?> getSocietyById(String id);

  Future<void> joinSociety({
    required String userId,
    required String societyId,
  });

  Future<JoinRequestInfo> getJoinRequestInfo({
    required String userId,
    required String societyId,
  });
}