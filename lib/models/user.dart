import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/user_scope.dart';

part 'user.freezed.dart';

typedef UserSnapshot = DocumentSnapshot<PlatformUser>;

@freezed
class PlatformUser with _$PlatformUser {
  const factory PlatformUser._create({
    required User user,
    required UserScope scope,
    required Iterable<DocumentReference> activeIssues,
    required Iterable<DocumentReference> resolvedIssues,
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
              activeIssues: snapshot[ActiveIssuesKey],
              resolvedIssues: snapshot[ResolvedIssuesKey],
            );
          },
          // PlatformUser -> Map<String, dynamic>
          toFirestore: (user, setOptions) => {
            _ScopeKey: user.scope.value,
            ActiveIssuesKey: user.activeIssues,
            ResolvedIssuesKey: user.resolvedIssues,
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
      activeIssues: List.empty(),
      resolvedIssues: List.empty(),
    ));

    return await doc.get();
  }

  static const _ScopeKey = 'scope';
  static const ActiveIssuesKey = 'active-issues';
  static const ResolvedIssuesKey = 'resolved-issues';
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.
}

extension UserSnapshotExtension on UserSnapshot {
  PlatformUser get user => this.data()!;

  Future<void> addActiveIssue(DocumentReference<Issue> issueReference) {
    return reference.update({
      PlatformUser.ActiveIssuesKey: FieldValue.arrayUnion([issueReference])
    });
  }
}
