class ComplaintModel {
  final String id;
  final String propertyId;
  final String societyId;
  final String raisedByUserId;
  final String raisedByRole; // tenant | owner
  final String raisedByName;
  final String title;
  final String description;
  final String category;
  final String status; // open | reviewed | resolved
  final String assignedTo; // owner | society_admin
  final String propertyLabel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.id,
    required this.propertyId,
    required this.societyId,
    required this.raisedByUserId,
    required this.raisedByRole,
    required this.raisedByName,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.assignedTo,
    required this.propertyLabel,
    required this.createdAt,
    this.updatedAt,
  });

  ComplaintModel copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id,
      propertyId: propertyId,
      societyId: societyId,
      raisedByUserId: raisedByUserId,
      raisedByRole: raisedByRole,
      raisedByName: raisedByName,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      assignedTo: assignedTo,
      propertyLabel: propertyLabel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}