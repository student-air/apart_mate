import 'package:get/get.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/data/models/update_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_update_repository.dart';

class TenantDashboardController extends GetxController {
  final tenant = Rxn<TenantModel>();
  final property = Rxn<PropertyModel>();
  final society = Rxn<SocietyModel>();
  final latestUpdates = <UpdateModel>[].obs;
  final isLoading = true.obs;

  // Initialize immediately — NOT late
  final IAuthRepository _auth = Get.find<IAuthRepository>();
  final IPropertyRepository _propertyRepo = Get.find<IPropertyRepository>();
  final ISocietyRepository _societyRepo = Get.find<ISocietyRepository>();
  final IUpdateRepository _updateRepo = Get.find<IUpdateRepository>();

  String get userName =>
      tenant.value?.fullName ?? _auth.currentUser?.fullName ?? '';

  String get roleLabel => 'Tenant';

  String get societyName => society.value?.name ?? '';

  String get propertyLabel {
    final t = tenant.value;
    if (t != null && t.propertyLabel.isNotEmpty) return t.propertyLabel;
    final p = property.value;
    if (p == null) return '—';
    return 'Flat ${p.flatNumber} · ${p.building}';
  }

  String get greetingName {
    final name = userName.trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final args = Get.arguments;
      TenantModel? t;
      PropertyModel? p;

      if (args is Map) {
        if (args['tenant'] is TenantModel) t = args['tenant'] as TenantModel;
        if (args['property'] is PropertyModel) {
          p = args['property'] as PropertyModel;
        }
      }

      if (t != null && p == null && t.propertyId.isNotEmpty) {
        p = await _propertyRepo.getPropertyById(t.propertyId);
      }

      tenant.value = t;
      property.value = p;

      if (p != null) {
        society.value = await _societyRepo.getSocietyById(p.societyId);
      }

      if (Get.isRegistered<AppSession>()) {
        final session = Get.find<AppSession>();
        if (!session.hasTenantRole.value) {
          session.registerTenant();
        } else {
          session.setRole('tenant');
        }
      }

      final updates = await _updateRepo.getUpdates();
      updates.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      latestUpdates.assignAll(updates.take(5).toList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();
}