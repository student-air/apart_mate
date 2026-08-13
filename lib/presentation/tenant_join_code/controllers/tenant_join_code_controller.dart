import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class TenantJoinCodeController extends GetxController {
  static const codeLength = 6;

  final digitCtrls = List.generate(codeLength, (_) => TextEditingController());
  final focusNodes = List.generate(codeLength, (_) => FocusNode());

  final tenant = Rxn<TenantModel>();
  final property = Rxn<PropertyModel>();
  final isLookingUp = false.obs;
  final isContinuing = false.obs;
  final lookupFailed = false.obs;

  late final ITenantRepository _tenantRepo;
  late final IPropertyRepository _propertyRepo;

  String get _enteredCode => digitCtrls.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    _tenantRepo = Get.find<ITenantRepository>();
    _propertyRepo = Get.find<IPropertyRepository>();
  }

  void onDigitChanged(int index, String value) {
    lookupFailed.value = false;

    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (_enteredCode.length == codeLength) {
      FocusScope.of(Get.context!).unfocus();
      _lookupInvite();
    } else {
      tenant.value = null;
      property.value = null;
    }
  }

  void onBackspace(int index) {
    if (digitCtrls[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      digitCtrls[index - 1].clear();
    }
  }

  Future<void> _lookupInvite() async {
    isLookingUp.value = true;
    try {
      final result = await _tenantRepo.getTenantByCode(_enteredCode);
      if (result == null) {
        tenant.value = null;
        property.value = null;
        lookupFailed.value = true;
        AppSnackbar.error('Invalid code', 'No invitation found for that code');
        return;
      }

      final prop = await _propertyRepo.getPropertyById(result.propertyId);
      if (prop == null) {
        tenant.value = null;
        property.value = null;
        lookupFailed.value = true;
        AppSnackbar.error('Property missing', 'Linked property could not be loaded');
        return;
      }

      tenant.value = result;
      property.value = prop;
      lookupFailed.value = false;
    } finally {
      isLookingUp.value = false;
    }
  }

  Future<void> continueWithInvite() async {
    final t = tenant.value;
    final p = property.value;
    if (t == null || p == null) return;

    isContinuing.value = true;
    try {
      Get.toNamed(
        AppRoutes.tenantConfirm,
        arguments: {'tenant': t, 'property': p},
      );
    } finally {
      isContinuing.value = false;
    }
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    for (final c in digitCtrls) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}