import 'package:cloud_firestore/cloud_firestore.dart';

extension DocumentReferenceExtension on DocumentReference {
  DocumentReference get asOriginalReference {
    final parts = path.split('/');

    if (parts.length % 2 != 0) {
      throw Exception(
        "I don't know how it became odd number of parts, but it became and so cannot proceed.",
      );
    }

    var ref = FirebaseFirestore.instance
        .collection(parts.removeAt(0))
        .doc(parts.removeAt(0));

    while (parts.isNotEmpty) {
      ref = ref.collection(parts.removeAt(0)).doc(parts.removeAt(0));
    }

    return ref;
  }
}
