// lib/data/models/manager_model.dart

class ManagerModel {
  final String id;
  final String fullName;
  final String phone;
  final String cnic;
  final List<String> propertyIds;
  final String propertyLabel; // e.g. "Flat A-203 · Block A, Flat B-101 · Block B"
  final String inviteCode;
  final String status; // pending | joined
  final DateTime createdAt;

  const ManagerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.cnic,
    required this.propertyIds,
    required this.propertyLabel,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
  });
}