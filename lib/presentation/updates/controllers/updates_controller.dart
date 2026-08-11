import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:apart_mate/presentation/updates/controllers/updates_badge_controller.dart';
import 'package:apart_mate/data/models/update_model.dart';
import 'package:apart_mate/domain/repositories/i_update_repository.dart';

class UpdatesController extends GetxController {
  final IUpdateRepository _updateRepository;
  UpdatesController(this._updateRepository);

  final updates = <UpdateModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUpdates();
    // GetX's onReady() turned out not to reliably defer past the current
    // build in this project's GetX version — it still raced the badge
    // Obx, just with a smaller window. WidgetsBinding.addPostFrameCallback
    // is a Flutter-level guarantee (not a GetX assumption): it only runs
    // after the current frame's build/layout/paint is fully finished, so
    // mutating unreadCount here is always safe, regardless of GetX's
    // internal lifecycle timing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<UpdatesBadgeController>()) {
        Get.find<UpdatesBadgeController>().markSeen();
      }
    });
  }

  Future<void> loadUpdates() async {
    isLoading.value = true;
    try {
      final result = await _updateRepository.getUpdates();
      updates.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadUpdates();

  /// Removes a single update — called when a card is swiped away. The item
  /// is taken out of the list immediately so the swipe animation completes
  /// cleanly, then the delete is persisted; if that fails, the item is put
  /// back where it was.
  Future<void> deleteUpdate(String id) async {
    final index = updates.indexWhere((u) => u.id == id);
    if (index == -1) return;

    final removed = updates[index];
    updates.removeAt(index);
    try {
      await _updateRepository.deleteUpdate(id);
    } catch (_) {
      updates.insert(index, removed);
    }
  }

  /// Clears every update — called from the "Clear All" action.
  Future<void> clearAll() async {
    if (updates.isEmpty) return;
    final previous = List<UpdateModel>.from(updates);
    updates.clear();
    try {
      await _updateRepository.clearAll();
    } catch (_) {
      updates.assignAll(previous);
    }
  }
}