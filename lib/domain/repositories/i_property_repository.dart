// lib/domain/repositories/i_property_repository.dart

import 'package:apart_mate/data/models/property_model.dart';

abstract class IPropertyRepository {
  Future<void> saveProperty(PropertyModel property);
  Future<PropertyModel?> getPropertyForUser(String userId);
  Future<List<PropertyModel>> getPropertiesForUser(String userId);
  Future<PropertyModel?> getPropertyById(String propertyId);
  Future<void> deleteProperty(String propertyId);

  /// Returns active claim for this unit key, if any.
  Future<PropertyModel?> findActiveClaimByUnitKey(String unitKey);

  /// Owner marks sold / releases claim. Throws/fails if tenant still linked.
  Future<void> releaseProperty(String propertyId);
}