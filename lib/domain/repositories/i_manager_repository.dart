import 'package:apart_mate/data/models/manager_model.dart';

abstract class IManagerRepository {
  Future<void> saveManager(ManagerModel manager);
  Future<List<ManagerModel>> getManagersForOwner(String ownerId);
  Future<ManagerModel?> getManagerByCode(String code);
}