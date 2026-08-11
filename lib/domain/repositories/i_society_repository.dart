// lib/domain/repositories/i_society_repository.dart

import 'package:apart_mate/data/models/society_model.dart';

enum Joinrequeststatus { pending, approved, rejected }

class JoinRequestInfo {
  final Joinrequeststatus status;
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

  /// Returns the ID of the society this user has an active join
  /// request/membership with, or null if they haven't joined one yet.
  Future<String?> getSocietyIdForUser(String userId);
}