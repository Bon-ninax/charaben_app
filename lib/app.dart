import 'package:charaben_app/presentation/splash/splash_page.dart';
import 'package:charaben_app/presentation/top/top_page.dart';
import 'package:flutter/material.dart';


import 'app_model.dart';
import 'common/user_state.dart';

class App extends StatelessWidget {
  final model = AppModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        //primarySwatch: primaryColor,
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      home: StreamBuilder(
        stream: model.userState,
        initialData: UserState.signedOut,
        builder: (context, AsyncSnapshot<UserState> snapshot) {
          final UserState state =
          snapshot.connectionState == ConnectionState.waiting
              ? UserState.waiting
              : snapshot.data;
          print("App(): userState = $state");
          return _convertPage(state);
        },
        ),
      );
  }

  //static const int _primaryValue = white;
  //static const MaterialColor primaryColor = Colors.white;

  // UserState => page
  StatelessWidget _convertPage(UserState state) {
    switch (state) {
      case UserState.waiting:
        return SplashPage();
      case UserState.signedOut:
        return TopPage();
      case UserState.signedIn:
        return TopPage();
      default:
        return TopPage();
    }
  }
}
