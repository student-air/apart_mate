import 'dart:math';
import 'package:apart_mate/data/models/manager_model.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';

class LocalManagerRepository implements IManagerRepository {
  final Map<String, ManagerModel> _managers = {};

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<void> saveManager(ManagerModel manager) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _managers[manager.id] = manager;
  }

  @override
  Future<List<ManagerModel>> getManagersForOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For now return all (later filter by ownerId)
    return _managers.values.toList();
  }

  @override
  Future<ManagerModel?> getManagerByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _managers.values.firstWhere(
        (m) => m.inviteCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper used by the controller to create + save
  Future<ManagerModel> createManager({
  required String fullName,
  required String phone,
  required String cnic,
  required List<String> propertyIds,
  required String propertyLabel,
}) async {
  final manager = ManagerModel(
    id: 'manager_${DateTime.now().millisecondsSinceEpoch}',
    fullName: fullName.trim(),
    phone: phone.trim(),
    cnic: cnic.trim(),
    propertyIds: propertyIds,
    propertyLabel: propertyLabel,
    inviteCode: _generateCode(),
    status: 'pending',
    createdAt: DateTime.now(),
  );
  await saveManager(manager);
  return manager;
}
}