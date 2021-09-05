import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';

part 'complaint.freezed.dart';
part 'complaint.g.dart';

@freezed
class Complaint with _$Complaint {
  /// Complaint created by [author] on [dateTime]
  const factory Complaint({
    required DocumentSnapshot<Author> author,
    required DateTime createdOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,
  }) = _Complaint;

  static Future<void> add() async {}

  static Future<void> remove() async {}

  static Future<ResolvedComplaint> resolve(Complaint complaint) async =>
      ResolvedComplaint._(
        complaint: complaint,
        resolvedDataTime: DateTime.now(),
      );

  static final collectionReference = FirebaseFirestore.instance
      .collection('active-complaints')
      .withConverter<Complaint>(
        fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
        toFirestore: (complaint, _) => complaint.toJson(),
      );

  static final collectionStream = collectionReference.snapshots();

  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
}

@freezed
class ResolvedComplaint with _$ResolvedComplaint {
  const factory ResolvedComplaint._({
    required Complaint complaint,
    required DateTime resolvedDataTime,
  }) = _ResolvedComplaint;

  static final reference = FirebaseFirestore.instance
      .collection('resolved-complaints')
      .withConverter<ResolvedComplaint>(
        fromFirestore: (snapshot, _) =>
            ResolvedComplaint.fromJson(snapshot.data()!),
        toFirestore: (complaint, _) => complaint.toJson(),
      );

  static Future<Complaint> revoke(ResolvedComplaint resolvedComplaint) async =>
      resolvedComplaint.complaint;

  factory ResolvedComplaint.fromJson(Map<String, dynamic> json) =>
      _$ResolvedComplaintFromJson(json);
}
