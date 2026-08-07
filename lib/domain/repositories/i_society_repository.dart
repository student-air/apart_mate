// lib/domain/repositories/i_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';

abstract class ISocietyRepository {
  /// Looks up a society by its join code. Returns null if no society
  /// matches — the UI decides how to surface that as an error.
  Future<SocietyModel?> getSocietyByJoinCode(String code);

  /// Links the current user to [societyId] (join request/membership).
  Future<void> joinSociety({
    required String userId,
    required String societyId,
  });
}