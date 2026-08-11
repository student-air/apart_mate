enum UpdateType { general, security, announcement, other }

class UpdateModel {
  final String id;
  final UpdateType type;
  final String title;
  final String description;
  final DateTime postedAt;
  final String? category;

  /// Who this was sent to — mirrors SendUpdateController.sendTo ('All',
  /// 'Building', 'Floor', 'Flat'). Building/floor/flat are only populated
  /// when relevant to that scope.
  final String sendTo;
  final String? buildingName;
  final int? floor;
  final String? flatNumber;

  const UpdateModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.postedAt,
    this.category,
    this.sendTo = 'All',
    this.buildingName,
    this.floor,
    this.flatNumber,
  });

  /// Human-readable reference line shown at the bottom of the update card.
  String get destinationLabel {
    switch (sendTo) {
      case 'Building':
        return buildingName ?? '';
      case 'Floor':
        return '${buildingName ?? ''} · Floor ${floor ?? ''}';
      case 'Flat':
        return '${buildingName ?? ''} · Floor ${floor ?? ''} · Flat ${flatNumber ?? ''}';
      default:
        return 'All Residents';
    }
  }
}