import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
import 'package:vitcc_electrical_issues/extensions/firestore_extensions.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';

import 'user.dart';

part 'issue.freezed.dart';

typedef IssueSnapshot = DocumentSnapshot<Issue>;

@freezed
class Issue with _$Issue {
  const Issue._();

  const factory Issue._create({
    required DocumentReference raisedBy,
    required Timestamp raisedOn,
    required String title,
    required String description,
    required IssueLocation location,
    required bool isImportant,
    required bool isUrgent,

    // The following are specific to resolved issues.
    required Timestamp? resolvedOn,
    required DocumentReference? resolvedBy,
    required String? remarks,
  }) = _Issue;

  /// Whether the issue is active.
  bool get isActiveIssue => resolvedOn == null;

  /// Whether the issue is resolved.
  bool get isResolvedIssue => !isActiveIssue;

  static final _activeRef = _convert(
    collection: FirebaseFirestore.instance.collection(IssueKeys.activeIssues),
  );

  static final _resolvedRef = _convert(
    collection: FirebaseFirestore.instance.collection(IssueKeys.resolvedIssues),
  );

  static CollectionReference<Issue> _convert({
    required CollectionReference<Map<String, dynamic>> collection,
  }) =>
      collection.withConverter<Issue>(
        // Map<String, dynamic> -> Issue
        fromFirestore: (snapshot, snapshotOptions) {
          final data = snapshot.data()!;

          return Issue._create(
            raisedBy: data[IssueKeys.raisedBy],
            // TODO: find an alternative solution to this weired fix
            raisedOn: data[IssueKeys.raisedOn] ?? Timestamp.now(),
            title: data[IssueKeys.title],
            description: data[IssueKeys.description],
            location: IssueLocation.fromJson(data[IssueKeys.location]),
            isImportant: data[IssueKeys.isImportant],
            isUrgent: data[IssueKeys.isUrgent],
            resolvedOn: data[IssueKeys.resolvedOn],
            resolvedBy: data[IssueKeys.resolvedBy],
            remarks: data[IssueKeys.remarks],
          );
        },
        // Issue -> Map<String, dynamic>
        toFirestore: (issue, setOptions) {
          return {
            IssueKeys.raisedBy: issue.raisedBy.asOriginalReference,
            IssueKeys.raisedOn: issue.raisedOn,
            IssueKeys.title: issue.title,
            IssueKeys.description: issue.description,
            IssueKeys.location: issue.location.toJson(),
            IssueKeys.isImportant: issue.isImportant,
            IssueKeys.isUrgent: issue.isUrgent,
            IssueKeys.resolvedOn: issue.resolvedOn,
            IssueKeys.resolvedBy: issue.resolvedBy?.asOriginalReference,
            IssueKeys.remarks: issue.remarks,
          };
        },
      );

  static Stream<List<IssueSnapshot>> get activeIssues =>
      _activeRef.snapshots().map((querySnapshot) => querySnapshot.docs);

  static Query<Issue> defaultResolvedIssueQuery(Query<Issue> query) {
    return query.limit(50);
  }

  static Stream<List<IssueSnapshot>> resolvedIssues([
    Query<Issue> Function(Query<Issue> query) queryBuilder =
        defaultResolvedIssueQuery,
  ]) {
    return queryBuilder(_resolvedRef)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  /// Watch the specified issue reference.
  ///
  /// Throws exception if [ref] does not belong to active or resolved issue
  /// collection.
  static Stream<IssueSnapshot> watch(DocumentReference ref) {
    // Check if ref belongs to active issues.
    if (ref.parent.id == _activeRef.id) {
      return _activeRef.doc(ref.id).snapshots();
    }

    // Check if ref belongs to resolved issues.
    if (ref.parent.id == _resolvedRef.id) {
      return _resolvedRef.doc(ref.id).snapshots();
    }

    // If the passed ref does not belong to any of the supported collections.
    throw Exception(
      "$ref's parent is not $_activeRef or $_resolvedRef. Unable to decide how to watch $ref.",
    );
  }

  /// Read the specified issue reference.
  ///
  /// Throws exception if [ref] does not belong to active or resolved issue
  /// collection.
  static Future<IssueSnapshot> read(DocumentReference ref) {
    // Check if ref belongs to active issues.
    if (ref.parent.id == _activeRef.id) {
      return _activeRef.doc(ref.id).get();
    }

    // Check if ref belongs to resolved issues.
    if (ref.parent.id == _resolvedRef.id) {
      return _resolvedRef.doc(ref.id).get();
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
    required String title,
    required String description,
    required IssueLocation location,
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
        title: title,
        description: description,
        location: location,
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
      IssueKeys.raisedOn: FieldValue.serverTimestamp(),
    });

    // Update's the creator's active issues index w/ the newly created doc. ref.
    await creatorSnapshot.addActiveIssue(doc);

    // Inform misc about this action, to update counters.
    await Misc.informIssueCreated();

    // Returns the document snapshot.
    return doc.get();
  }
}

/// Contains all the keys related to [Issue].
///
/// This class is abstract sealed class to discourage creating instances of this
/// class as it contains only static members.
@sealed
abstract class IssueKeys {
  // Issue Collection Keys

  /// Key for the [CollectionReference] of active issues.
  static const activeIssues = 'active-issues';

  /// Key for the [CollectionReference] of resolved issues.
  static const resolvedIssues = 'resolved-issues';

  // Issue Document Keys
  //
  // NOTE: When adding document specific keys, make sure these are used also in
  //       the `fromFirestore` and `toFirestore` methods.

  /// Key for the [DocumentReference] of the user who raised the issue.
  static const raisedBy = 'raised-by';

  /// Key for the [Timestamp] of when the issue was raised.
  static const raisedOn = 'raised-on';

  /// Key for the title of the issue as [String].
  static const title = 'title';

  /// Key for the description of the issue as [String].
  static const description = 'description';

  /// Key for the location of the issue as [IssueLocation].
  static const location = 'location';

  /// Key for whether the issue is important or not as [bool].
  static const isImportant = 'is-important';

  /// Key for whether the issue is urgent or not as [bool].
  static const isUrgent = 'is-urgent';

  /// Key for the [Timestamp] of when the issue was resolved.
  static const resolvedOn = 'resolved-on';

  /// Key for the [DocumentReference] of the user who resolved the issue.
  static const resolvedBy = 'resolved-by';

  /// Key for the remarks of the issue as [String].
  static const remarks = 'remarks';

  const IssueKeys._();
}

extension IssueSnapshotExtension on IssueSnapshot {
  Issue get issue => this.data()!;

  /// Whether this issue belongs to resolved issues collection or not.
  bool get isResolved => this.reference.parent.id == IssueKeys.resolvedIssues;

  /// Whether this issue belongs to active issues collection or not.
  bool get isActive => this.reference.parent.id == IssueKeys.activeIssues;

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
    await issue.raisedBy.update({
      IssueKeys.activeIssues: FieldValue.arrayRemove([
        reference.asOriginalReference,
      ]),
    });

    // Inform misc about this action, to update counters.
    await Misc.informActiveIssuePurged();

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
      resolvedBy: resolverSnapshot.reference.asOriginalReference,
      remarks: remarks,
    ));

    // Updates the document w/ server timestamp for 'resolved-on' attribute.
    await doc.update({
      IssueKeys.resolvedOn: FieldValue.serverTimestamp(),
    });

    // Updates the user's document with change in issue from active to resolved.
    await issue.raisedBy.update({
      IssueKeys.activeIssues: FieldValue.arrayRemove([
        this.reference.asOriginalReference,
      ]),
      IssueKeys.resolvedIssues: FieldValue.arrayUnion([
        doc.asOriginalReference,
      ]),
    });

    // Delete the issue from active issues collection.
    await reference.delete();

    // Inform misc about this action, to update counters.
    await Misc.informIssueResolved();

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
