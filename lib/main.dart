import 'package:charaben_app/app.dart';
import 'package:charaben_app/presentation/login/login_page.dart';
import 'package:charaben_app/presentation/recipe_add/recipe_add_page.dart';
import 'package:charaben_app/presentation/signup/signup_page.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

enum Flavor {
  development,
  staging,
  production,
}

void main() async {
  debugPaintSizeEnabled = false;
  // main()の中で非同期処理を行う際には、下記を実行
  WidgetsFlutterBinding.ensureInitialized();
//  ErrorWidget.builder = (FlutterErrorDetails details) {
//    bool inDebug = false;
//    assert(() {
//      inDebug = true;
//      return true;
//    }());
//    // In debug mode, use the normal error widget which shows
//    // the error message:
//    if (inDebug) return ErrorWidget(details.exception);
//    // In release builds, show a yellow-on-blue message instead:
//    return Container(
//      alignment: Alignment.center,
//      child: Text(
//        'Error!',
//        style: TextStyle(color: Colors.yellow),
//        textDirection: TextDirection.ltr,
//        ),
//      );
//  };

  final flavor = EnumToString.fromString(
    Flavor.values,
    const String.fromEnvironment('FLAVOR'),
    );

  final SimpleLogger logger = SimpleLogger()
    ..setLevel(
      Level.FINEST,
      includeCallerInfo: true,
      );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    await Firebase.initializeApp();
    print('---');
    logger.info('FLAVOR: $flavor');
    print("FLAVOR: ${const String.fromEnvironment('FLAVOR')}");
    print('---');
    runApp(App());
  });
}
