import 'package:get/get.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class LocalComplaintRepository implements IComplaintRepository {
  final Map<String, ComplaintModel> _complaints = {};

  IPropertyRepository get _properties => Get.find<IPropertyRepository>();

  @override
  Future<void> saveComplaint(ComplaintModel complaint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _complaints[complaint.id] = complaint;
  }

  @override
  Future<List<ComplaintModel>> getComplaintsRaisedBy(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _complaints.values
        .where((c) => c.raisedByUserId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<ComplaintModel>> getComplaintsForOwner(String ownerUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final owned = await _properties.getPropertiesForUser(ownerUserId);
    final ownedIds = owned.map((p) => p.id).toSet();

    return _complaints.values
        .where(
          (c) => c.assignedTo == 'owner' && ownedIds.contains(c.propertyId),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> updateStatus(String complaintId, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = _complaints[complaintId];
    if (existing == null) return;
    _complaints[complaintId] = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }
@override
Future<void> deleteComplaint(String complaintId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  _complaints.remove(complaintId);
}
  
}