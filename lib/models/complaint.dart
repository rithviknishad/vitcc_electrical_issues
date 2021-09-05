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

  factory ResolvedComplaint.fromJson(Map<String, dynamic> json) =>
      _$ResolvedComplaintFromJson(json);
}
