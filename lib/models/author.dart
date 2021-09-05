import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'author.freezed.dart';
part 'author.g.dart';

class AuthorScope {
  static const createComplaint = AuthorScope._(
    'Create Complaint',
  );

  static const purgeComplaint = AuthorScope._(
    'Purge Complaint',
  );

  static const resolveComplaint = AuthorScope._(
    'Resolve Complaint',
  );

  static const viewActiveComplaint = AuthorScope._(
    'View Active Complaints',
  );

  static const viewResolvedComplaint = AuthorScope._(
    'View Resolved Complaints',
  );

  const AuthorScope._(this.label);

  final String label;

  @override
  String toString() => label;
}

@freezed
class Author with _$Author {
  const factory Author({
    /// The user who issued the complaint.
    @JsonKey(ignore: true) required User user,

    /// The display name of the user.
    required String displayName,

    /// Description of this complaint.
    required String email,

    /// How important this complaint is.

    required UnmodifiableListView<AuthorScope> scopes,
  }) = _Author;

  static final mailRegEx = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  static final reference =
      FirebaseFirestore.instance.collection('author').withConverter<Author>(
            fromFirestore: (snapshot, _) => Author.fromJson(snapshot.data()!),
            toFirestore: (author, _) => author.toJson(),
          );

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
}
