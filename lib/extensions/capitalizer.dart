/// Sourced from https://stackoverflow.com/questions/29628989/how-to-capitalize-the-first-letter-of-a-string-in-dart
extension StringCapitalizer on String {
  String capitalize() => '${this[0].toUpperCase()}${this.substring(1)}';
}
