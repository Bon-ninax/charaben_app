import 'package:enum_to_string/enum_to_string.dart';

import '../main.dart';


String ImagesStoragePath() {
  Flavor flaver = EnumToString.fromString(
    Flavor.values,
    const String.fromEnvironment('FLAVOR'),
    );
  switch (flaver) {
    case Flavor.development:
      return 'https://firebasestorage.googleapis.com/v0/b/dev-charaben-app.appspot.com/o/images%2F';
    case Flavor.production:
      return 'https://firebasestorage.googleapis.com/v0/b/charaven-app.appspot.com/o/images%2F';
    default:
      return 'エラーが発生しました。';
  }
}

String UsersStoragePath() {
  Flavor flaver = EnumToString.fromString(
    Flavor.values,
    const String.fromEnvironment('FLAVOR'),
    );
  switch (flaver) {
    case Flavor.development:
      return 'https://firebasestorage.googleapis.com/v0/b/dev-charaben-app.appspot.com/o/users%2F';
    case Flavor.production:
      return 'https://firebasestorage.googleapis.com/v0/b/charaven-app.appspot.com/o/users%2F';
    default:
      return 'エラーが発生しました。';
  }
}