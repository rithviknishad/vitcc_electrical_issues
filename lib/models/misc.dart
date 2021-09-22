import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'misc.freezed.dart';

typedef MiscSnapshot = DocumentSnapshot<Misc>;

@freezed
class Misc with _$Misc {
  const Misc._();

  const factory Misc._create({
    required List<String> locationBlocks,
  }) = _Misc;

  static const _LocationBlocksKey = 'location-blocks';

  static final _ref =
      FirebaseFirestore.instance.collection('misc').withConverter<Misc>(
    fromFirestore: (snapshot, options) {
      final data = snapshot.data()!;

      return Misc._create(
        locationBlocks: data[_LocationBlocksKey].cast<String>(),
      );
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
}
