// lib/data/models/property_model.dart

class PropertyModel {
  final String id;
  final String userId;
  final String societyId;
  final String building;
  final String floor;
  final String flatNumber;
  final bool isOccupied;
  final String occupiedBy;
  final String propertyType;
  final String areaSqFt;
  final String bathrooms;
  final String flatType;
  final bool hasBalcony;
  final bool hasElectricity;
  final bool hasGas;
  final String meterType;
  final String waterConnection;
  final String furnishing;
  final DateTime createdAt;

  const PropertyModel({
    required this.id,
    required this.userId,
    required this.societyId,
    required this.building,
    required this.floor,
    required this.flatNumber,
    required this.isOccupied,
    required this.occupiedBy,
    required this.propertyType,
    required this.areaSqFt,
    required this.bathrooms,
    required this.flatType,
    required this.hasBalcony,
    required this.hasElectricity,
    required this.hasGas,
    required this.meterType,
    required this.waterConnection,
    required this.furnishing,
    required this.createdAt,
  });
}