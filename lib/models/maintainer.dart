import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintainer.freezed.dart';

@freezed
class Maintainer with _$Maintainer {
  const Maintainer._();

  const factory Maintainer.__({
    required String username,
    required String uri,
    required String photoURL,
  }) = _Maintainer;

  static const all = [
    Maintainer.__(
      username: 'rithviknishad',
      uri: 'https://github.com/rithviknishad',
      photoURL: 'https://avatars.githubusercontent.com/u/25143503?v=4',
    ),
    Maintainer.__(
      username: 'aswinmurali-io',
      uri: 'https://github.com/aswinmurali-io',
      photoURL: 'https://avatars.githubusercontent.com/u/47299190?v=4',
    ),
  ];
}
