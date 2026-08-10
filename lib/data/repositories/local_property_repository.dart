// lib/data/repositories/local_property_repository.dart

import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalPropertyRepository implements IPropertyRepository {
  final Map<String, PropertyModel> _properties = {}; // keyed by userId

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 700));

  @override
  Future<void> saveProperty(PropertyModel property) async {
    await _simulateLatency();
    _properties[property.userId] = property;
  }

  @override
  Future<PropertyModel?> getPropertyForUser(String userId) async {
    await _simulateLatency();
    return _properties[userId];
  }
}