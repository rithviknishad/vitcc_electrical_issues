import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint.freezed.dart';

@freezed
class Complaint with _$Complaint {
  @Assert(
    'urgencyLevel >= 0 && urgencyLevel < 5',
    'Urgency level must be in between 0 and 5!',
  )
  const factory Complaint({
    /// The user who issued the complaint.
    required User user,

    /// A uuid value issued for the complaint.
    required UuidValue uuid,

    /// Date and time when the complaint was issued.
    required DateTime dateTime,

    /// Description of this complaint.
    required String description,

    /// How important this complaint is.
    required int urgencyLevel,
  }) = _Complaint;
}

// class Complaint {
//   final User user;

//   final UuidValue uuid;

//   final DateTime dateTime;

//   final String description;

//   final int urgencyLevel;

//   const Complaint({
//     required this.uuid,
//     required this.user,
//     required this.dateTime,
//     required this.urgencyLevel,
//     required this.description,
//   });
// }
