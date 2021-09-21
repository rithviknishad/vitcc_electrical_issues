import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'issue.freezed.dart';

typedef IssueSnapshot = DocumentSnapshot<Issue>;

@freezed
class Issue with _$Issue {
  const Issue._();

  const factory Issue._create({
    required DocumentReference raisedBy,
    required Timestamp raisedOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,

    // The following are specific to resolved issues.
    required Timestamp? resolvedOn,
    required DocumentReference? resolvedBy,
    required String? remarks,
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

          return Issue._create(
            raisedBy: data[_RaisedByKey],
            raisedOn: data[_RaisedOnKey],
            description: data[_DescriptionKey],
            isImportant: data[_IsImportantKey],
            isUrgent: data[_IsUrgentKey],
            resolvedOn: data[_ResolvedOnKey],
            resolvedBy: data[_ResolvedByKey],
            remarks: data[_RemarksKey],
          );
        },
        // Issue -> Map<String, dynamic>
        toFirestore: (issue, setOptions) {
          return {
            _RaisedByKey: issue.raisedBy,
            _RaisedOnKey: issue.raisedOn,
            _DescriptionKey: issue.description,
            _IsImportantKey: issue.isImportant,
            _IsUrgentKey: issue.isUrgent,
            _ResolvedOnKey: issue.resolvedOn,
            _ResolvedByKey: issue.resolvedBy,
            _RemarksKey: issue.remarks,
          };
        },
      );

  static const _RaisedByKey = 'raised-by';
  static const _RaisedOnKey = 'raised-on';
  static const _DescriptionKey = 'description';
  static const _IsImportantKey = 'is-important';
  static const _IsUrgentKey = 'is-urgent';
  static const _ResolvedOnKey = 'resolved-on';
  static const _ResolvedByKey = 'resolved-by';
  static const _RemarksKey = 'remarks';
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.

  static final activeIssues = _activeRef.snapshots();

  /// Watch the specified issue reference.
  ///
  /// Throws exception if [ref] does not belong to active or resolved issue
  /// collection.
  static Stream<IssueSnapshot> watch(DocumentReference ref) {
    // Check if ref belongs to active issues.
    if (ref.parent == _activeRef) {
      return _activeRef.doc(ref.id).snapshots();
    }

    // Check if ref belongs to resolved issues.
    if (ref.parent == _resolvedRef) {
      return _resolvedRef.doc(ref.id).snapshots();
    }

    // If the passed ref does not belong to any of the supported collections.
    throw Exception(
      "$ref's parent is not $_activeRef or $_resolvedRef. Unable to decide how to watch $ref.",
    );
  }

  /// Creates a new active issue and returns a snapshot of it.
  ///
  /// This future throws an exception if the user has no permission to create
  /// an issue.
  static Future<IssueSnapshot> create({
    required UserSnapshot creatorSnapshot,
    required String description,
    required bool isImportant,
    required bool isUrgent,
  }) async {
    // Throw exception if user has no permission to create an issue.
    if (creatorSnapshot.user.scope.canCreateIssue == false) {
      throw Exception('Not enough permission to create an issue.');
    }

    // Creates a document ref. w/ auto generated id in active issues collection.
    final doc = _activeRef.doc();

    // Sets the issue document w/ the specified info.
    await doc.set(
      Issue._create(
        raisedBy: creatorSnapshot.reference,
        raisedOn: Timestamp.now(),
        description: description,
        isImportant: isImportant,
        isUrgent: isUrgent,
        // Resolved issue attributes are null, as this is an active issue.
        resolvedBy: null,
        resolvedOn: null,
        remarks: null,
      ),
    );

    // Updates the document w/ server timestamp for 'rasied-on' attribute.
    await doc.update({
      _RaisedOnKey: FieldValue.serverTimestamp(),
    });

    // Update's the creator's active issues index w/ the newly created doc. ref.
    await creatorSnapshot.addActiveIssue(doc);

    // Returns the document snapshot.
    return doc.get();
  }
}

extension IssueSnapshotExtension on IssueSnapshot {
  Issue get issue => this.data()!;

  /// Whether this issue belongs to resolved issues collection or not.
  bool get isResolved => this.reference.parent.id == Issue._ResolvedIssuesKey;

  /// Purges an active issue.
  ///
  /// This future can throw exception if purge operation was forbidden.
  Future<void> purge(UserSnapshot userSnapshot) async {
    // Disallow purge for resolved issued.
    if (this.isResolved) {
      throw Exception(
        'A resolved issue cannot be purged.',
      );
    }

    // Permit if the issue being purged is owned by the user.
    bool permitted = userSnapshot.reference == issue.raisedBy;

    // Permit if user has permission to delete any issue.
    permitted |= userSnapshot.user.scope.canPurgeIssue;

    // Throws exception if user has no permission to perform this operation.
    if (!permitted) {
      throw Exception(
        'This account does not have enough permissions to perform this operation. You shall either be the creator of this issue or have enough permissions to purge issues not owned by the creator.',
      );
    }

    // Remove reference from user's document issues index.
    issue.raisedBy.update({
      PlatformUser.ActiveIssuesKey: FieldValue.arrayRemove([reference]),
    });

    await reference.delete();
  }

  /// Resolves the issue by moving the document from `active-issues` collection
  /// to `resolved-issues` collection.
  ///
  /// Returns this instance if already resolved otherwise returns the newly
  /// created resolved issue.
  ///
  /// This future may throw an exception if [resolverSnapshot] does not have enough
  /// permission to resolve the issue.
  Future<IssueSnapshot> resolve({
    required UserSnapshot resolverSnapshot,
    required String remarks,
  }) async {
    // Return self if already resolved.
    if (isResolved) {
      return this;
    }

    // Throw exception if resolver has no permission to resolve the issue.
    if (resolverSnapshot.user.scope.canResolveIssue == false) {
      throw Exception('Not enough permission to resolve this issue.');
    }

    // Creates a document ref. in resolved issues collection with same ID.
    final doc = Issue._resolvedRef.doc(reference.id);

    // Set's the new ref. with issue details along with resolve details.
    await doc.set(issue.copyWith(
      resolvedOn: Timestamp.now(),
      resolvedBy: resolverSnapshot.reference,
      remarks: remarks,
    ));

    // Updates the document w/ server timestamp for 'resolved-on' attribute.
    await doc.update({
      Issue._ResolvedOnKey: FieldValue.serverTimestamp(),
    });

    // Updates the user's document with change in issue from active to resolved.
    await issue.raisedBy.update({
      PlatformUser.ActiveIssuesKey: FieldValue.arrayRemove([this.reference]),
      PlatformUser.ResolvedIssuesKey: FieldValue.arrayUnion([doc]),
    });

    // Delete the issue from active issues collection.
    await reference.delete();

    // Returns the newly created resolved issue.
    return doc.get();
  }

  /// Revokes a resolved issue back to an active issue.
  ///
  /// Does nothing if already in active issues collection.
  Future<void> revoke() async {
    throw UnimplementedError();

    if (isResolved) {
      // TODO: write to active collection

      await reference.delete();

      // TODO: return the newly created document's ref.
    }
  }
}
