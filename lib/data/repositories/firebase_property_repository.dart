// lib/data/repositories/firebase_property_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/core/utils/property_unit_key.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class FirebasePropertyRepository implements IPropertyRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('properties');

  String _unitKeyOf(PropertyModel p) => buildPropertyUnitKey(
        societyId: p.societyId,
        building: p.building,
        floor: p.floor,
        flatNumber: p.flatNumber,
      );

  @override
  Future<void> saveProperty(PropertyModel property) async {
    final id = property.id.isEmpty ? _col.doc().id : property.id;
    final toSave = property.id.isEmpty
        ? property.copyWith(id: id)
        : property;

    await _col.doc(toSave.id).set(_toMap(toSave), SetOptions(merge: true));
  }

  @override
  Future<PropertyModel?> getPropertyForUser(String userId) async {
    final list = await getPropertiesForUser(userId);
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<List<PropertyModel>> getPropertiesForUser(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('claimStatus', isEqualTo: 'active')
        .get();

    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  @override
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    final doc = await _col.doc(propertyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    await _col.doc(propertyId).delete();
  }

  @override
  Future<PropertyModel?> findActiveClaimByUnitKey(String unitKey) async {
    final snap = await _col
        .where('unitKey', isEqualTo: unitKey)
        .where('claimStatus', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return _fromMap(d.id, d.data());
  }

  @override
  Future<void> releaseProperty(String propertyId) async {
    final existing = await getPropertyById(propertyId);
    if (existing == null) throw Exception('Property not found');

    if (existing.isOccupied &&
        existing.occupiedBy.toLowerCase() == 'tenant') {
      throw Exception('TENANT_LINKED');
    }

    await _col.doc(propertyId).set({
      'claimStatus': 'released',
      'isOccupied': false,
      'occupiedBy': '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _toMap(PropertyModel p) {
    return {
      'userId': p.userId,
      'societyId': p.societyId,
      'building': p.building,
      'floor': p.floor,
      'flatNumber': p.flatNumber,
      'isOccupied': p.isOccupied,
      'occupiedBy': p.occupiedBy,
      'propertyType': p.propertyType,
      'areaSqFt': p.areaSqFt,
      'bathrooms': p.bathrooms,
      'flatType': p.flatType,
      'hasBalcony': p.hasBalcony,
      'hasElectricity': p.hasElectricity,
      'hasGas': p.hasGas,
      'meterType': p.meterType,
      'waterConnection': p.waterConnection,
      'furnishing': p.furnishing,
      'maintenanceBy': p.maintenanceBy,
      'maintenanceAmount': p.maintenanceAmount,
      'claimStatus': p.claimStatus,
      'unitKey': _unitKeyOf(p),
      'createdAt': Timestamp.fromDate(p.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PropertyModel _fromMap(String id, Map<String, dynamic> d) {
    return PropertyModel(
      id: id,
      userId: d['userId'] ?? '',
      societyId: d['societyId'] ?? '',
      building: d['building'] ?? '',
      floor: d['floor'] ?? '',
      flatNumber: d['flatNumber'] ?? '',
      isOccupied: d['isOccupied'] ?? false,
      occupiedBy: d['occupiedBy'] ?? '',
      propertyType: d['propertyType'] ?? '',
      areaSqFt: d['areaSqFt']?.toString() ?? '',
      bathrooms: d['bathrooms']?.toString() ?? '',
      flatType: d['flatType'] ?? '',
      hasBalcony: d['hasBalcony'] ?? false,
      hasElectricity: d['hasElectricity'] ?? false,
      hasGas: d['hasGas'] ?? false,
      meterType: d['meterType'] ?? '',
      waterConnection: d['waterConnection'] ?? '',
      furnishing: d['furnishing'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maintenanceBy: d['maintenanceBy'] ?? '',
      maintenanceAmount: d['maintenanceAmount']?.toString() ?? '',
      claimStatus: d['claimStatus'] ?? 'active',
    );
  }
}