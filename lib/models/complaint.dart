import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';

part 'complaint.freezed.dart';

@freezed
class Complaint with _$Complaint {
  const factory Complaint({
    required DocumentReference<Author> author,
    required DateTime createdOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,
    // Not stored in firestore, evaluated by collection origin.
    required bool isActive,
  }) = _Complaint;

  static final _activeComplaintsCollectionReference =
      FirebaseFirestore.instance.collection('active-complaints').withConverter(
            fromFirestore: (snapshot, _) => Complaint(
              author: snapshot[AuthorKey],
              createdOn: snapshot[CreatedOnKey],
              description: snapshot[DescriptionKey],
              isImportant: snapshot[IsImportantKey],
              isUrgent: snapshot[IsUrgentKey],
              isActive: true,
            ),
            toFirestore: (complaint, _) => {
              AuthorKey: complaint.author,
              CreatedOnKey: complaint.createdOn,
              DescriptionKey: complaint.description,
              IsImportantKey: complaint.isImportant,
              IsUrgentKey: complaint.isUrgent,
            },
          );

  static const AuthorKey = 'author';
  static const CreatedOnKey = 'created-on';
  static const DescriptionKey = 'description';
  static const IsImportantKey = 'is-important';
  static const IsUrgentKey = 'is-urgent';

  static final activeComplaints =
      _activeComplaintsCollectionReference.snapshots();

  static Future<void> add() async {}

  static Future<void> remove() async {}

  static Future<void> resolve(Complaint complaint) async {}
}
