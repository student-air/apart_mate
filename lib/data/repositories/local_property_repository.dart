// lib/data/repositories/local/local_property_repository.dart

import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalPropertyRepository implements IPropertyRepository {
  late final Map<String, PropertyModel> _properties = {
    LocalAuthRepository.demoGoogleUserId: PropertyModel(
      id: 'property_demo_google',
      userId: LocalAuthRepository.demoGoogleUserId,
      societyId: 'society_001',
      building: 'Block A',
      floor: '2nd Floor',
      flatNumber: 'A-203',
      isOccupied: true,
      occupiedBy: 'tenant',
      propertyType: 'Apartment',
      areaSqFt: '1350',
      bathrooms: '2',
      flatType: '3 Bed',
      hasBalcony: true,
      hasElectricity: true,
      hasGas: true,
      meterType: 'WAPDA Meter',
      waterConnection: 'Municipal',
      furnishing: 'Furnished',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    LocalAuthRepository.demoAppleUserId: PropertyModel(
      id: 'property_demo_apple',
      userId: LocalAuthRepository.demoAppleUserId,
      societyId: 'society_001',
      building: 'Block A',
      floor: '2nd Floor',
      flatNumber: 'A-203',
      isOccupied: true,
      occupiedBy: 'tenant',
      propertyType: 'Apartment',
      areaSqFt: '1350',
      bathrooms: '2',
      flatType: '3 Bed',
      hasBalcony: true,
      hasElectricity: true,
      hasGas: true,
      meterType: 'WAPDA Meter',
      waterConnection: 'Municipal',
      furnishing: 'Furnished',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  };

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