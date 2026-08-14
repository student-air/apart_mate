// lib/data/repositories/local_property_repository.dart

import 'package:apart_mate/core/utils/property_unit_key.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/repositories/local_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalPropertyRepository implements IPropertyRepository {
  // Keyed by property.id — supports multiple per user
  final Map<String, PropertyModel> _properties = {
    'property_demo_google_1': PropertyModel(
      id: 'property_demo_google_1',
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
    'property_demo_google_2': PropertyModel(
      id: 'property_demo_google_2',
      userId: LocalAuthRepository.demoGoogleUserId,
      societyId: 'society_001',
      building: 'Block B',
      floor: '5th Floor',
      flatNumber: 'B-501',
      isOccupied: false,
      occupiedBy: '',
      propertyType: 'Apartment',
      areaSqFt: '1100',
      bathrooms: '2',
      flatType: '2 Bed',
      hasBalcony: true,
      hasElectricity: true,
      hasGas: false,
      meterType: 'WAPDA Meter',
      waterConnection: 'Municipal',
      furnishing: 'Semi-Furnished',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    'property_demo_google_3': PropertyModel(
      id: 'property_demo_google_3',
      userId: LocalAuthRepository.demoGoogleUserId,
      societyId: 'society_002',
      building: 'Tower 1',
      floor: '12th Floor',
      flatNumber: 'T1-1204',
      isOccupied: true,
      occupiedBy: 'owner',
      propertyType: 'Apartment',
      areaSqFt: '1800',
      bathrooms: '3',
      flatType: '4 Bed',
      hasBalcony: true,
      hasElectricity: true,
      hasGas: true,
      meterType: 'WAPDA Meter',
      waterConnection: 'Bore',
      furnishing: 'Furnished',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  };

  String _unitKeyOf(PropertyModel p) => buildPropertyUnitKey(
      societyId: p.societyId,
      building: p.building,
      floor: p.floor,
      flatNumber: p.flatNumber,
    );

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<void> saveProperty(PropertyModel property) async {
    await _simulateLatency();
    _properties[property.id] = property;
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    await _simulateLatency();
    _properties.remove(propertyId);
  }

  @override
  Future<PropertyModel?> getPropertyForUser(String userId) async {
    final list = await getPropertiesForUser(userId);
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    await _simulateLatency();
    return _properties[propertyId];
  }

  @override
Future<PropertyModel?> findActiveClaimByUnitKey(String unitKey) async {
  await _simulateLatency();
  for (final p in _properties.values) {
    if (p.isClaimActive && _unitKeyOf(p) == unitKey) {
      return p;
    }
  }
  return null;
}

@override
Future<void> releaseProperty(String propertyId) async {
  await _simulateLatency();
  final p = _properties[propertyId];
  if (p == null) {
    throw Exception('Property not found');
  }
  // Block if tenant still on the unit
  if (p.isOccupied && p.occupiedBy.toLowerCase() == 'tenant') {
    throw Exception('TENANT_LINKED');
  }
  _properties[propertyId] = p.copyWith(
    claimStatus: 'released',
    // optional: clear occupancy when releasing vacant/owner-occupied
    isOccupied: false,
    occupiedBy: '',
  );
}

@override
Future<List<PropertyModel>> getPropertiesForUser(String userId) async {
  await _simulateLatency();
  // Only active claims show on owner dashboard
  return _properties.values
      .where((p) => p.userId == userId && p.isClaimActive)
      .toList();
}
}