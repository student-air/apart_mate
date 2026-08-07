// lib/domain/repositories/i_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';

enum JoinRequestStatus { pending, approved, rejected }

abstract class ISocietyRepository {
  Future<SocietyModel?> getSocietyByJoinCode(String code);
  Future<SocietyModel?> getSocietyById(String id);

  Future<void> joinSociety({
    required String userId,
    required String societyId,
  });

  /// Checks the current status of a previously submitted join request.
  Future<JoinRequestStatus> getJoinRequestStatus({
    required String userId,
    required String societyId,
  });
}