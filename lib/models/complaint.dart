import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';

part 'complaint.freezed.dart';

@freezed
class Complaint with _$Complaint {
  const factory Complaint._({
    required DocumentReference<Author> author,
    required DateTime createdOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,
    // Not stored in firestore, evaluated by collection origin.
    required bool isResolved,
    required DocumentReference reference,
  }) = _Complaint;

  static final _activeComplaintsRef =
      FirebaseFirestore.instance.collection('active-complaints').withConverter(
            fromFirestore: (snapshot, _) =>
                Complaint._activeComplaintFromFirestore(snapshot),
            toFirestore: (complaint, _) => complaint._toFirestore(),
          );

  static final _resolvedComplaintsRef = FirebaseFirestore.instance
      .collection('resolved-complaints')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            Complaint._resolvedComplaintFromFirestore(snapshot),
        toFirestore: (complaint, _) => complaint._toFirestore(),
      );

  factory Complaint._activeComplaintFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return Complaint._(
      author: snapshot[AuthorKey],
      createdOn: snapshot[CreatedOnKey],
      description: snapshot[DescriptionKey],
      isImportant: snapshot[IsImportantKey],
      isUrgent: snapshot[IsUrgentKey],
      isResolved: false,
      reference: snapshot.reference,
    );
  }

  factory Complaint._resolvedComplaintFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return Complaint._(
      author: snapshot[AuthorKey],
      createdOn: snapshot[CreatedOnKey],
      description: snapshot[DescriptionKey],
      isImportant: snapshot[IsImportantKey],
      isUrgent: snapshot[IsUrgentKey],
      isResolved: false,
      reference: snapshot.reference,
    );
  }

  Map<String, Object> _toFirestore() => {
        AuthorKey: author,
        CreatedOnKey: createdOn,
        DescriptionKey: description,
        IsImportantKey: isImportant,
        IsUrgentKey: isUrgent,
      };

  static const AuthorKey = 'author';
  static const CreatedOnKey = 'created-on';
  static const DescriptionKey = 'description';
  static const IsImportantKey = 'is-important';
  static const IsUrgentKey = 'is-urgent';

  static final activeComplaints = _activeComplaintsRef.snapshots();

  static Future<void> create() async {}

  /// Purges an active complaint. Returns `true` if purge was successfull, else
  /// `false`.
  ///
  /// Purging a resolved complaint is not allowed. Therefore, returns `false`.
  Future<bool> purge() async {
    if (isResolved) {
      // Purge operation not allowed on resolved complaints.
      return false;
    } else {
      await reference.delete();
      return true;
    }
  }

  /// Resolves the complaint by moving the document from `active-collection`
  /// to `resolved-collection`.
  ///
  /// Does nothing if already resolved.
  Future<void> resolve() async {
    if (!isResolved) {
      // TODO: write to resolved collection.

      // Delete complaint from active collection
      await reference.delete();

      // TODO: return the newly created document's reference
    }
  }

  /// Revokes a resolved complaint back to an active complaint.
  ///
  /// Does nothing if already in active complaints collection.
  Future<void> revoke() async {
    if (isResolved) {}
  }
}
