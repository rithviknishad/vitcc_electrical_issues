import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vitcc_electrical_issues/models/user_scope.dart';

part 'user.freezed.dart';

@freezed
class PlatformUser with _$PlatformUser {
  const factory PlatformUser._createObject({
    required User user,
    required UserScope scope,
  }) = _PlatformUser;

  static Future<PlatformUser> get(User user) async {
    // The document reference w/ converter of the user.
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .withConverter<PlatformUser>(
          fromFirestore: (snapshot, snapshotOptions) {
            return PlatformUser._createObject(
              user: user,
              scope: UserScope(snapshot['scope'] as int),
            );
          },
          toFirestore: (user, setOptions) => {
            'scope': user.scope.value,
          },
        );

    var snapshot = await doc.get();

    // Checks if document associated w/ user exists.
    if (snapshot.exists) {
      return snapshot.data()!;
    }

    await doc.set(PlatformUser._createObject(
      user: user,
      scope: UserScope.defaultScope,
    ));

    return (await doc.get()).data()!;
  }
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.

  static final emailPattern = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
}
