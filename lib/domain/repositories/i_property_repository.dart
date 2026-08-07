// lib/domain/repositories/i_property_repository.dart

import 'package:apart_mate/data/models/property_model.dart';

abstract class IPropertyRepository {
  Future<void> saveProperty(PropertyModel property);
  Future<PropertyModel?> getPropertyForUser(String userId);
}