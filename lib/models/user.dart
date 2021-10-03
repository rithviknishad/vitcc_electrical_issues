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
    required String? name,
    required String? email,
    required String? phoneNumber,
    required UserScope scope,
    required Iterable<DocumentReference> activeIssueRefs,
    required Iterable<DocumentReference> resolvedIssueRefs,
    required Timestamp onboardTimestamp,
  }) = _PlatformUser;

  static Future<UserSnapshot?> getUserFromId(String id) async {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .withConverter<PlatformUser>(
      // Map<String, dynamic> -> PlatformUser
      fromFirestore: (snapshot, snapshotOptions) {
        final data = snapshot.data()!;

        return PlatformUser._create(
          name: data[_NameKey],
          email: data[_EmailKey],
          phoneNumber: data[_PhoneNumberKey],
          scope: UserScope(data[_ScopeKey] as int),
          activeIssueRefs:
              (data[IssueKeys.activeIssues] as List).cast<DocumentReference>(),
          resolvedIssueRefs: (data[IssueKeys.resolvedIssues] as List)
              .cast<DocumentReference>(),
          onboardTimestamp: data[_OnboardTimestampKey],
        );
      },
      // PlatformUser -> Map<String, dynamic>
      toFirestore: (user, setOptions) {
        throw Exception('Write not permitted');
      },
    );

    final snapshot = await doc.get();

    if (snapshot.exists) {
      return snapshot;
    }

    return null;
  }

  static Stream<UserSnapshot> watch(User firebaseUser) async* {
    // The document reference w/ converter of the user.
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .withConverter<PlatformUser>(
          // Map<String, dynamic> -> PlatformUser
          fromFirestore: (snapshot, snapshotOptions) {
            final data = snapshot.data()!;

            return PlatformUser._create(
              name: data[_NameKey],
              email: data[_EmailKey],
              phoneNumber: data[_PhoneNumberKey],
              scope: UserScope(data[_ScopeKey] as int),
              activeIssueRefs: (data[IssueKeys.activeIssues] as List)
                  .cast<DocumentReference>(),
              resolvedIssueRefs: (data[IssueKeys.resolvedIssues] as List)
                  .cast<DocumentReference>(),
              onboardTimestamp: data[_OnboardTimestampKey],
            );
          },
          // PlatformUser -> Map<String, dynamic>
          toFirestore: (user, setOptions) => {
            _NameKey: user.name,
            _EmailKey: user.email,
            _PhoneNumberKey: user.phoneNumber,
            _ScopeKey: user.scope.value,
            IssueKeys.activeIssues: user.activeIssueRefs,
            IssueKeys.resolvedIssues: user.resolvedIssueRefs,
            _OnboardTimestampKey: user.onboardTimestamp,
          },
        );

    final snapshot = await doc.get();

    // Creates a new document if document does not exist for the user.
    if (!snapshot.exists) {
      await doc.set(PlatformUser._create(
        name: firebaseUser.displayName,
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber,
        scope: UserScope.defaultScope,
        activeIssueRefs: List.empty(),
        resolvedIssueRefs: List.empty(),
        onboardTimestamp: Timestamp.fromDate(DateTime.now()),
      ));
    }

// Returns the snapshot if document associated w/ user exists
    yield* doc.snapshots();
  }

  static const _ScopeKey = 'scope';
  static const _NameKey = 'name';
  static const _EmailKey = 'email';
  static const _PhoneNumberKey = 'phone-number';
  static const _OnboardTimestampKey = 'onboard-timestamp';
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
      IssueKeys.activeIssues: FieldValue.arrayUnion([
        issueReference.asOriginalReference,
      ])
    });
  }
}
