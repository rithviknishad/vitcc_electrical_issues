import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'issue.freezed.dart';

@freezed
class Issue with _$Issue {
  const Issue._();

  const factory Issue._createObject({
    required String creatorId,
    required DateTime raisedOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,

    // The following are specific to resolved issues.
    required DateTime? resolvedOn,
    required DocumentReference<PlatformUser>? resolvedBy,
    required String? remarks,

    // The following are not stored in firestore.
    required bool isResolved,
    required DocumentReference reference,
  }) = _Issue;

  static const _ActiveIssuesKey = 'active-issues';
  static const _ResolvedIssuesKey = 'resolved-issues';

  static final _activeRef = _convert(
    collection: FirebaseFirestore.instance.collection(_ActiveIssuesKey),
  );

  static final _resolvedRef = _convert(
    collection: FirebaseFirestore.instance.collection(_ResolvedIssuesKey),
  );

  static CollectionReference<Issue> _convert({
    required CollectionReference<Map<String, dynamic>> collection,
  }) =>
      collection.withConverter<Issue>(
        // Map<String, dynamic> -> Issue
        fromFirestore: (snapshot, snapshotOptions) {
          final data = snapshot.data()!;

          return Issue._createObject(
            creatorId: data[_CreatorIdKey],
            raisedOn: data[_CreatedOnKey],
            description: data[_DescriptionKey],
            isImportant: data[_IsImportantKey],
            isUrgent: data[_IsUrgentKey],
            resolvedOn: data[_ResolvedOnKey],
            resolvedBy: data[_ResolvedByKey],
            remarks: data[_RemarksKey],
            reference: snapshot.reference,
            isResolved: snapshot.reference.parent.id == _ResolvedIssuesKey,
          );
        },
        // Issue -> Map<String, dynamic>
        toFirestore: (object, setOptions) {
          return {
            _CreatorIdKey: object.creatorId,
            _CreatedOnKey: object.raisedOn,
            _DescriptionKey: object.description,
            _IsImportantKey: object.isImportant,
            _IsUrgentKey: object.isUrgent,
            _ResolvedOnKey: object.resolvedOn,
            _ResolvedByKey: object.resolvedBy,
            _RemarksKey: object.remarks,
          };
        },
      );

  bool get isNotResolved => !isResolved;

  static const _CreatorIdKey = 'creator-id';
  static const _CreatedOnKey = 'raised-on';
  static const _DescriptionKey = 'description';
  static const _IsImportantKey = 'is-important';
  static const _IsUrgentKey = 'is-urgent';
  static const _ResolvedOnKey = 'resolved-on';
  static const _ResolvedByKey = 'resolved-by';
  static const _RemarksKey = 'remarks';
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.

  static final activeIssues = _activeRef.snapshots();

  /// Creates a new active issue.
  static Future<Issue> create({
    required DocumentReference<PlatformUser> creatorRef,
    required String description,
    required bool isImportant,
    required bool isUrgent,
  }) async {
    final doc = _activeRef.doc();

    await doc.set(
      Issue._createObject(
        creatorId: creatorRef.id,
        raisedOn: DateTime.now(),
        description: description,
        isImportant: isImportant,
        isUrgent: isUrgent,
        resolvedBy: null,
        resolvedOn: null,
        remarks: null,
        isResolved: false,
        reference: doc,
      ),
    );

    return (await doc.get()).data()!;
  }

  /// Purges an active issue.
  ///
  /// This future completes with `null` if purging was succesfull. Otherwise
  /// returns a `String` stating the reason why this operation failed.
  Future<String?> purge(PlatformUser user) async {
    if (isResolved) {
      return "A resolved issue cannot be purged.";
    }

    // Permit if the issue being purged is owned by the user.
    bool permitted = user.user.uid == creatorId;

    // Permit if user has permission to delete any issue.
    permitted |= user.scope.canPurgeIssue;

    if (!permitted) {
      return """
This account does not have enough permissions to perform this operation.
You shall either be the author of this issue, or have enough permissions to purge other issues.""";
    }

    await reference.delete();
  }

  /// Resolves the issue by moving the document from `active-issues` collection
  /// to `resolved-issues` collection.
  ///
  /// Returns this instance if already resolved otherwise returns the newly
  /// created resolved issue.
  Future<Issue> resolve() async {
    // Return self if already resolved.
    if (isResolved) {
      return this;
    }

    // Creates a document ref. in resolved issues collection with same ID.
    final doc = _resolvedRef.doc(reference.id);

    // Set's the new ref. with issue details.
    await doc.set(this);

    // Delete the issue from active issues collection.
    await reference.delete();

    // Returns the newly created resolved issue.
    return (await doc.get()).data()!;
  }

  /// Revokes a resolved issue back to an active issue.
  ///
  /// Does nothing if already in active issues collection.
  Future<void> revoke() async {
    if (isResolved) {
      // TODO: write to active collection

      await reference.delete();

      // TODO: return the newly created document's ref.
    }
  }
}
