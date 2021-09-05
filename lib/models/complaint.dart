import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';

part 'complaint.freezed.dart';
part 'complaint.g.dart';

@freezed
class Complaint with _$Complaint {
  @Assert(
    'urgencyLevel >= 0 && urgencyLevel < 5',
    'Urgency level must be in between 0 and 5!',
  )
  const factory Complaint({
    /// The user who issued the complaint.
    required Author author,

    /// Date and time when the complaint was issued.
    required DateTime dateTime,

    /// Description of this complaint.
    required String description,

    /// How important this complaint is.
    required int urgencyLevel,
  }) = _Complaint;

  static Future<void> add() async {}

  static Future<void> remove() async {}

  static Future<ResolvedComplaint> resolve(Complaint complaint) async =>
      ResolvedComplaint._(
        complaint: complaint,
        resolvedDataTime: DateTime.now(),
      );

  static final reference = FirebaseFirestore.instance
      .collection('active-complaints')
      .withConverter<Complaint>(
        fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
        toFirestore: (complaint, _) => complaint.toJson(),
      );

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
