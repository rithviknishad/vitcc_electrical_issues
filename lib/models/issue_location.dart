import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue_location.freezed.dart';

/// Encapsulates a location attribute to make the data more structured.
/// Designed for use with [Issue] class.
///
/// Includes the following attributes:
/// * `block`
/// * `floor`
/// * `room`
///
/// Usage example:
/// ```dart
/// var location = IssueLocation(
///   block: 'Academic Block 1',
///   floor: '3',
///   room: '300',
/// );
/// ```
@freezed
class IssueLocation with _$IssueLocation {
  const IssueLocation._();

  const factory IssueLocation({
    required String block,
    required String floor,
    required String room,
  }) = _IssueLocation;

  /// Serializes the location information specified in [source] to an instance
  /// of [IssueLocation].
  factory IssueLocation.fromJson(Map<String, dynamic> source) {
    return IssueLocation(
      block: source['block'],
      floor: source['floor'],
      room: source['room'],
    );
  }

  /// Serializes this location to `Map<String, String>` for use in firestore.
  Map<String, String> toJson() {
    return {
      'block': block,
      'floor': floor,
      'room': room,
    };
  }
}
