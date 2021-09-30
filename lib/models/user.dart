import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/user_scope.dart';
import 'package:vitcc_electrical_issues/models/firestore_extensions.dart';

part 'user.freezed.dart';

typedef UserSnapshot = DocumentSnapshot<PlatformUser>;

@freezed
class PlatformUser with _$PlatformUser {
  const PlatformUser._();

  const factory PlatformUser._create({
    required User user,
    required UserScope scope,
    required Iterable<DocumentReference> activeIssueRefs,
    required Iterable<DocumentReference> resolvedIssueRefs,
  }) = _PlatformUser;

  static Future<UserSnapshot> get(User user) async {
    // The document reference w/ converter of the user.
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .withConverter<PlatformUser>(
          // Map<String, dynamic> -> PlatformUser
          fromFirestore: (snapshot, snapshotOptions) {
            return PlatformUser._create(
              user: user,
              scope: UserScope(snapshot[_ScopeKey] as int),
              activeIssueRefs:
                  (snapshot[ActiveIssuesKey] as List).cast<DocumentReference>(),
              resolvedIssueRefs: (snapshot[ResolvedIssuesKey] as List)
                  .cast<DocumentReference>(),
            );
          },
          // PlatformUser -> Map<String, dynamic>
          toFirestore: (user, setOptions) => {
            _ScopeKey: user.scope.value,
            ActiveIssuesKey: user.activeIssueRefs,
            ResolvedIssuesKey: user.resolvedIssueRefs,
          },
        );

    final snapshot = await doc.get();

    // Returns the snapshot if document associated w/ user exists
    if (snapshot.exists) {
      return snapshot;
    }

    // Creates a new document if document does not exist for the user.
    await doc.set(PlatformUser._create(
      user: user,
      scope: UserScope.defaultScope,
      activeIssueRefs: List.empty(),
      resolvedIssueRefs: List.empty(),
    ));

    return await doc.get();
  }

  static const _ScopeKey = 'scope';
  static const ActiveIssuesKey = 'active-issues';
  static const ResolvedIssuesKey = 'resolved-issues';
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.

  /// Get watch streams of all active issues of this user.
  Iterable<Stream<IssueSnapshot>> get activeIssues =>
      activeIssueRefs.map(Issue.watch);

  /// Read all resolved issues of this user.
  Iterable<Future<IssueSnapshot>> get resolvedIssues =>
      resolvedIssueRefs.map(Issue.read);

  /// Whether this user has any active issues.
  bool get hasActiveIssues => activeIssueRefs.isNotEmpty;

  /// Whether this user has any resolved issues.
  bool get hasResolvedIssues => resolvedIssueRefs.isNotEmpty;
}

extension UserSnapshotExtension on UserSnapshot {
  PlatformUser get user => this.data()!;

  Future<void> addActiveIssue(DocumentReference<Issue> issueReference) {
    return reference.update({
      PlatformUser.ActiveIssuesKey: FieldValue.arrayUnion([
        issueReference.asOriginalReference,
      ])
    });
  }
}
