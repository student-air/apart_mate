import 'package:apart_mate/data/models/update_model.dart';

abstract class IUpdateRepository {
  Future<List<UpdateModel>> getUpdates();
  Future<UpdateModel> addUpdate(UpdateModel update);
  Future<void> deleteUpdate(String id);
  Future<void> clearAll();
}