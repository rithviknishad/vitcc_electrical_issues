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

    // The following are not stored in firestore
    required bool isResolved,
    required DocumentReference reference,
  }) = _Complaint;

  static final _activeComplaintsRef = FirebaseFirestore.instance
      .collection('active-complaints')
      .withConverter<Complaint>(
        fromFirestore: (snapshot, _) => Complaint._activeFrom(snapshot),
        toFirestore: (complaint, _) => complaint._toFirestore(),
      );

  static final _resolvedComplaintsRef = FirebaseFirestore.instance
      .collection('resolved-complaints')
      .withConverter<Complaint>(
        fromFirestore: (snapshot, _) => Complaint._resolvedFrom(snapshot),
        toFirestore: (complaint, _) => complaint._toFirestore(),
      );

  factory Complaint._activeFrom(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return Complaint._(
      author: snapshot[_AuthorKey],
      createdOn: snapshot[_CreatedOnKey],
      description: snapshot[_DescriptionKey],
      isImportant: snapshot[_IsImportantKey],
      isUrgent: snapshot[_IsUrgentKey],
      isResolved: false,
      reference: snapshot.reference,
    );
  }

  factory Complaint._resolvedFrom(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return Complaint._(
      author: snapshot[_AuthorKey],
      createdOn: snapshot[_CreatedOnKey],
      description: snapshot[_DescriptionKey],
      isImportant: snapshot[_IsImportantKey],
      isUrgent: snapshot[_IsUrgentKey],
      isResolved: true,
      reference: snapshot.reference,
    );
  }

  Map<String, Object> _toFirestore() => {
        _AuthorKey: author,
        _CreatedOnKey: createdOn,
        _DescriptionKey: description,
        _IsImportantKey: isImportant,
        _IsUrgentKey: isUrgent,
      };

  static const _AuthorKey = 'author';
  static const _CreatedOnKey = 'created-on';
  static const _DescriptionKey = 'description';
  static const _IsImportantKey = 'is-important';
  static const _IsUrgentKey = 'is-urgent';

  static final activeComplaints = _activeComplaintsRef.snapshots();

  /// Creates a complaint stored in `active-collection` and returns the created
  /// reference.
  static Future<DocumentReference<Complaint>> create({
    required DocumentReference<Author> author,
    required String description,
    required bool isImportant,
    required bool isUrgent,
  }) async {
    final doc = _activeComplaintsRef.doc();

    await doc.set(
      Complaint._(
        author: author,
        createdOn: DateTime.now(),
        description: description,
        isImportant: isImportant,
        isUrgent: isUrgent,
        isResolved: false,
        reference: doc,
      ),
    );

    return doc;
  }

  /// Purges an active complaint. Returns `true` if purge was successfull, else
  /// `false`.
  ///
  /// Purging a resolved complaint is not allowed. Therefore, returns `false`.
  Future<bool> purge() async {
    if (isResolved) {
      // Purge operation not allowed on resolved complaints.
      // TODO: in firestore rules, disallow delete for this collection
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

      // TODO: return the newly created document's ref.
    }
  }

  /// Revokes a resolved complaint back to an active complaint.
  ///
  /// Does nothing if already in active complaints collection.
  Future<void> revoke() async {
    if (isResolved) {
      // TODO: write to active collection

      await reference.delete();

      // TODO: return the newly created document's ref.
    }
  }
}
