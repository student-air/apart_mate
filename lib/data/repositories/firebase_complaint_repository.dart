// lib/data/repositories/firebase_complaint_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';

class FirebaseComplaintRepository implements IComplaintRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('complaints');

  IPropertyRepository get _properties => Get.find<IPropertyRepository>();

  @override
  Future<void> saveComplaint(ComplaintModel complaint) async {
    final id = complaint.id.isEmpty ? _col.doc().id : complaint.id;
    final toSave = complaint.id.isEmpty
        ? ComplaintModel(
            id: id,
            propertyId: complaint.propertyId,
            societyId: complaint.societyId,
            raisedByUserId: complaint.raisedByUserId,
            raisedByRole: complaint.raisedByRole,
            raisedByName: complaint.raisedByName,
            title: complaint.title,
            description: complaint.description,
            category: complaint.category,
            status: complaint.status,
            assignedTo: complaint.assignedTo,
            propertyLabel: complaint.propertyLabel,
            createdAt: complaint.createdAt,
            updatedAt: complaint.updatedAt,
          )
        : complaint;

    await _col.doc(toSave.id).set(
          _toMap(toSave),
          SetOptions(merge: true),
        );
  }

  @override
  Future<List<ComplaintModel>> getComplaintsRaisedBy(String userId) async {
    final snap = await _col
        .where('raisedByUserId', isEqualTo: userId)
        .get();

    final list = snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<ComplaintModel>> getComplaintsForOwner(String ownerUserId) async {
    // Same rule as local: assigned to owner + property owned by this user
    final owned = await _properties.getPropertiesForUser(ownerUserId);
    final ownedIds = owned.map((p) => p.id).toSet();
    if (ownedIds.isEmpty) return [];

    final snap = await _col
        .where('assignedTo', isEqualTo: 'owner')
        .get();

    final list = snap.docs
        .map((d) => _fromMap(d.id, d.data()))
        .where((c) => ownedIds.contains(c.propertyId))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> updateStatus(String complaintId, String status) async {
    if (complaintId.isEmpty) return;
    await _col.doc(complaintId).set(
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteComplaint(String complaintId) async {
    if (complaintId.isEmpty) return;
    await _col.doc(complaintId).delete();
  }

  Map<String, dynamic> _toMap(ComplaintModel c) {
    return {
      'propertyId': c.propertyId,
      'societyId': c.societyId,
      'raisedByUserId': c.raisedByUserId,
      'raisedByRole': c.raisedByRole,
      'raisedByName': c.raisedByName,
      'title': c.title,
      'description': c.description,
      'category': c.category,
      'status': c.status,
      'assignedTo': c.assignedTo,
      'propertyLabel': c.propertyLabel,
      'createdAt': Timestamp.fromDate(c.createdAt),
      'updatedAt': c.updatedAt != null
          ? Timestamp.fromDate(c.updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ComplaintModel _fromMap(String id, Map<String, dynamic> d) {
    return ComplaintModel(
      id: id,
      propertyId: d['propertyId'] ?? '',
      societyId: d['societyId'] ?? '',
      raisedByUserId: d['raisedByUserId'] ?? '',
      raisedByRole: d['raisedByRole'] ?? '',
      raisedByName: d['raisedByName'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? '',
      status: d['status'] ?? 'open',
      assignedTo: d['assignedTo'] ?? 'owner',
      propertyLabel: d['propertyLabel'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}