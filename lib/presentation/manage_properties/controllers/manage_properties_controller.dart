// lib/presentation/manage_properties/controllers/manage_properties_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ManagePropertiesController extends GetxController {
  late final DashboardController _dashboard;

  final isLoading = false.obs;

  SocietyModel? get society => _dashboard.society.value;

  String get societyName => society?.name ?? '';

  List<PropertyModel> get properties =>
      _dashboard.propertiesInCurrentSociety;

  PropertyModel? get selectedProperty => _dashboard.property.value;

  @override
  void onInit() {
    super.onInit();
    _dashboard = Get.find<DashboardController>();
  }

  void selectProperty(PropertyModel property) {
    _dashboard.selectProperty(property);
  }

  void editProperty(PropertyModel property) {
    selectProperty(property);
    Get.toNamed(AppRoutes.propertyDetails);
  }

  void addProperty() {
    Get.toNamed(AppRoutes.propertyDetails);
  }

  Future<void> refresh() async {
    isLoading.value = true;
    try {
      await _dashboard.refresh();
    } finally {
      isLoading.value = false;
    }
  }
}