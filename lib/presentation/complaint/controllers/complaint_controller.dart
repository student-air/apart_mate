import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ComplaintController extends GetxController {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final isLoading = false.obs;
  final selectedCategory = RxnString();
  final selectedPropertyId = RxnString();
  final properties = <PropertyModel>[].obs;

  static const categories = [
    'Plumbing',
    'Electrical',
    'Noise',
    'Cleaning',
    'Security',
    'Other',
  ];

  late final IComplaintRepository _complaintRepo;
  late final IPropertyRepository _propertyRepo;
  late final IAuthRepository _auth;

  @override
  void onInit() {
    super.onInit();
    _complaintRepo = Get.find<IComplaintRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
    _auth = Get.find<IAuthRepository>();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final list = await _propertyRepo.getPropertiesForUser(user.id);
    properties.assignAll(list);
    if (list.length == 1) {
      selectedPropertyId.value = list.first.id;
    }
  }

  void selectCategory(String value) => selectedCategory.value = value;
  void selectProperty(String id) => selectedPropertyId.value = id;

  Future<void> submit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final title = titleCtrl.text.trim();
    final desc = descriptionCtrl.text.trim();
    final category = selectedCategory.value;
    final propId = selectedPropertyId.value;

    if (title.isEmpty || desc.isEmpty) {
      AppSnackbar.info('Missing fields', 'Please enter title and description');
      return;
    }
    if (category == null) {
      AppSnackbar.info('Category', 'Please select a category');
      return;
    }
    if (propId == null) {
      AppSnackbar.info('Property', 'Please select a property');
      return;
    }

    final property = properties.firstWhere((p) => p.id == propId);
    final assignedTo =
        property.maintenanceBy == 'society_admin' ? 'society_admin' : 'owner';
    final role = AppNavigation.isTenant ? 'tenant' : 'owner';

    isLoading.value = true;
    try {
      final complaint = ComplaintModel(
        id: 'complaint_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: property.id,
        societyId: property.societyId,
        raisedByUserId: user.id,
        raisedByRole: role,
        raisedByName: user.fullName,
        title: title,
        description: desc,
        category: category,
        status: 'open',
        assignedTo: assignedTo,
        propertyLabel: 'Flat ${property.flatNumber} · ${property.building}',
        createdAt: DateTime.now(),
      );

      await _complaintRepo.saveComplaint(complaint);

      AppSnackbar.success(
        'Submitted',
        assignedTo == 'society_admin'
            ? 'Complaint sent to society admin'
            : 'Complaint sent to property owner',
      );

      Get.offNamed(AppRoutes.maintenance);
    } catch (_) {
      AppSnackbar.error('Failed', 'Could not submit complaint');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}