import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

class UserScope {
  final int _value;

  static const BitPosCreateComplaint = 0;
  static const BitPosViewActiveComplaint = 1;
  static const BitPosViewResolvedComplaint = 2;
  static const BitPosResolveComplaint = 3;
  static const BitPosPurgeAnyComplaint = 4;

  bool _check(int permissions) => (_value & (1 << permissions)) != 0;

  bool get canCreateComplaint => _check(BitPosCreateComplaint);
  bool get canViewActiveComplaint => _check(BitPosViewActiveComplaint);
  bool get canViewResolvedComplaint => _check(BitPosViewResolvedComplaint);
  bool get canResolveComplaint => _check(BitPosResolveComplaint);
  bool get canPurgeComplaint => _check(BitPosPurgeAnyComplaint);

  const UserScope._(this._value);

  static const defaultPermissions = UserScope._(1 << BitPosCreateComplaint);

  // Do not include code that can manipulate access to other permissions.
  // Should be handled by Admin Console / Firestore DB directly.

  int toJson() => _value;

  factory UserScope.fromJson(int value) = UserScope._;

  @override
  String toString() => 'UserScope: $_value';
}

@freezed
class PlatformUser with _$PlatformUser {
  const factory PlatformUser._createObject({
    required User user,
    required UserScope scope,
  }) = _PlatformUser;

  static Future<PlatformUser?> get(User user) async {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .withConverter<PlatformUser>(
          // decode from firestore map
          fromFirestore: (snapshot, _) {
            return PlatformUser._createObject(
              user: user,
              scope: UserScope._(snapshot[_ScopeKey] ?? 1),
            );
          },
          // encode to firestore map
          toFirestore: (obj, _) => {
            _ScopeKey: obj.scope.toJson(),
          },
        );

    final snapshot = await doc.get();

    return snapshot.data();
  }

  static const _ScopeKey = 'scope';
  // NOTE: When adding keys, make sure these are added in the `_toFirestore()`
  // method.

  static final emailPattern = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
}
