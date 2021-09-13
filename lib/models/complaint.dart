import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'complaint.freezed.dart';

@freezed
class Complaint with _$Complaint {
  const Complaint._();

  const factory Complaint._createObject({
    required String creatorId,
    required DateTime raisedOn,
    required String description,
    required bool isImportant,
    required bool isUrgent,

    // The following are specific to resolved complaints
    required DateTime? resolvedOn,
    required DocumentReference<PlatformUser>? resolvedBy,
    required String? remarks,

    // The following are not stored in firestore
    required bool isResolved,
    required DocumentReference reference,
  }) = _Complaint;

  static final _activeRef =
      _convert(FirebaseFirestore.instance.collection('active-complaints'));

  static final _resolvedRef =
      _convert(FirebaseFirestore.instance.collection('resolved-complaints'));

  static CollectionReference<Complaint> _convert(
    CollectionReference<Map<String, dynamic>> collection,
  ) =>
      collection.withConverter<Complaint>(
        // Map<String, dynamic> -> Complaint
        fromFirestore: (snapshot, snapshotOptions) {
          final data = snapshot.data()!;

          return Complaint._createObject(
            creatorId: data[_CreatorIdKey],
            raisedOn: data[_CreatedOnKey],
            description: data[_DescriptionKey],
            isImportant: data[_IsImportantKey],
            isUrgent: data[_IsUrgentKey],
            resolvedOn: data[_ResolvedOnKey],
            resolvedBy: data[_ResolvedByKey],
            remarks: data[_RemarksKey],
            reference: snapshot.reference,
            isResolved: snapshot.reference.parent.id == 'resolved-complaints',
          );
        },
        // Complaint -> Map<String, dynamic>
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

  // Stream<DocumentSnapshot<Complaint>> listen() {}

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

  static final activeComplaints = _activeRef.snapshots();

  /// Creates a complaint stored in `active-collection` and returns the created
  /// reference.
  static Future<DocumentReference<Complaint>> create({
    required DocumentReference<PlatformUser> creatorRef,
    required String description,
    required bool isImportant,
    required bool isUrgent,
  }) async {
    final doc = _activeRef.doc();

    await doc.set(
      Complaint._createObject(
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

    return doc;
  }

  /// Purges an active complaint. Returns `true` if purge was successfull, else
  /// `false`.
  ///
  /// Purging a resolved complaint is not allowed. Therefore, returns `false`.
  Future<bool> purge(PlatformUser user) async {
    // Permit if user has permission to delete complaints not owned by the user.
    bool permitted = user.scope.canPurgeComplaint;

    // Permit if the complaint being purged is owned by the user.
    permitted |= user.user.uid == this.creatorId;

    if (isResolved || !permitted) {
      // TODO: in firestore rules, disallow delete for this collection
      assert(!isResolved, '`purge` invoked on a resolved complaint.');
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
  Future<DocumentReference<Complaint>?> resolve() async {
    if (isResolved) {
      assert(false, '`resolve` invoked on an already resolved complaint.');
      return null;
    }

    final doc = _resolvedRef.doc(reference.id);
    await doc.set(this);

    await reference.delete();

    return doc;
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
