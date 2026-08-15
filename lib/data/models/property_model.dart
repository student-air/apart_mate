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
  final String maintenanceBy;

  /// active = claimed by an owner (blocks new registration)
  /// released = owner marked sold / gave up (unit free again)
  final String claimStatus; // 'active' | 'released'

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
    required this.maintenanceBy,
    this.claimStatus = 'active',
  });

  bool get isClaimActive => claimStatus == 'active';
  bool get isMaintenanceByOwner => maintenanceBy == 'property_owner';
  bool get isMaintenanceByAdmin => maintenanceBy == 'society_admin';

  PropertyModel copyWith({
    String? id,
    String? userId,
    String? societyId,
    String? building,
    String? floor,
    String? flatNumber,
    bool? isOccupied,
    String? occupiedBy,
    String? propertyType,
    String? areaSqFt,
    String? bathrooms,
    String? flatType,
    bool? hasBalcony,
    bool? hasElectricity,
    bool? hasGas,
    String? meterType,
    String? waterConnection,
    String? furnishing,
    DateTime? createdAt,
    String? claimStatus,
    String? maintenanceBy,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      societyId: societyId ?? this.societyId,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      flatNumber: flatNumber ?? this.flatNumber,
      isOccupied: isOccupied ?? this.isOccupied,
      occupiedBy: occupiedBy ?? this.occupiedBy,
      propertyType: propertyType ?? this.propertyType,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      bathrooms: bathrooms ?? this.bathrooms,
      flatType: flatType ?? this.flatType,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      hasElectricity: hasElectricity ?? this.hasElectricity,
      hasGas: hasGas ?? this.hasGas,
      meterType: meterType ?? this.meterType,
      waterConnection: waterConnection ?? this.waterConnection,
      furnishing: furnishing ?? this.furnishing,
      createdAt: createdAt ?? this.createdAt,
      claimStatus: claimStatus ?? this.claimStatus,
      maintenanceBy: maintenanceBy ?? this.maintenanceBy,
    );
  }
}