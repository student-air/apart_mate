import 'package:apart_mate/data/models/complaint_model.dart';

abstract class IComplaintRepository {
  Future<void> saveComplaint(ComplaintModel complaint);
  Future<List<ComplaintModel>> getComplaintsRaisedBy(String userId);
  Future<List<ComplaintModel>> getComplaintsForOwner(String ownerUserId);
  Future<void> updateStatus(String complaintId, String status);
}