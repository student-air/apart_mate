import 'package:get/get.dart';

/// Tracks how many updates have been sent since the Updates screen was
/// last opened, so [AppBottomNav] can show a small "new" badge on the
/// Updates icon from anywhere else in the app (Dashboard, etc.).
///
/// Registered as permanent in InitialBinding — it needs to live for the
/// whole app session, not just while the Updates screen happens to be on
/// screen, since the badge must be visible from other tabs too.
class UpdatesBadgeController extends GetxController {
  final unreadCount = 0.obs;

  /// Called by [SendUpdateController] right after a notice is sent.
  void increment() => unreadCount.value++;

  /// Called by [UpdatesController] when the Updates screen opens.
  void markSeen() => unreadCount.value = 0;
}