import 'package:apart_mate/data/models/manager_model.dart';

abstract class IManagerRepository {
  Future<void> saveManager(ManagerModel manager);
    Future<ManagerModel?> getManagerByUserId(String userId);
  Future<List<ManagerModel>> getManagersForOwner(String ownerId);
  Future<ManagerModel?> getManagerByCode(String code);
    Future<void> markManagerJoined({
    required String managerId,
    required String userId,
  });
}