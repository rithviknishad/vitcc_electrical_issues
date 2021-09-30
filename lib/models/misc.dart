import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'misc.freezed.dart';

typedef MiscSnapshot = DocumentSnapshot<Misc>;

@freezed
class Misc with _$Misc {
  const Misc._();

  const factory Misc._create({
    required List<String> locationBlocks,
    required int activeIssuesCount,
    required int resolvedIssuesCount,
  }) = _Misc;

  static const _LocationBlocksKey = 'location-blocks';
  static const _ActiveIssuesCountKey = 'active-issues-count';
  static const _ResolvedIssuesCountKey = 'resolved-issues-count';

  static final _ref =
      FirebaseFirestore.instance.collection('misc').withConverter<Misc>(
    fromFirestore: (snapshot, options) {
      final data = snapshot.data()!;

      return Misc._create(
          locationBlocks: data[_LocationBlocksKey].cast<String>(),
          activeIssuesCount: data[_ActiveIssuesCountKey],
          resolvedIssuesCount: data[_ResolvedIssuesCountKey]);
    },
    toFirestore: (value, options) {
      return {
        _LocationBlocksKey: value.locationBlocks,
      };
    },
  ).doc('default');

  static get ref => _ref;

  static Stream<MiscSnapshot> get watch => _ref.snapshots();

  static Future<MiscSnapshot> get read => _ref.get();

  static Future<void> informIssueCreated() async {
    await _ref.update({
      _ActiveIssuesCountKey: FieldValue.increment(1),
    });
  }

  static Future<void> informIssueResolved() async {
    await _ref.update({
      _ActiveIssuesCountKey: FieldValue.increment(-1),
      _ResolvedIssuesCountKey: FieldValue.increment(1),
    });
  }
}
