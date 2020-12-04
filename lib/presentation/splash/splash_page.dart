import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            child: Center(
              child: SizedBox(
                  width: 350,
                  height: 350,
                  child: FadeInImage.assetNetwork(
                      //placeholder: SizedBox(),
                      image: 'https://firebasestorage.googleapis.com/v0/b/charaven-app.appspot.com/o/splash.gif?alt=media&token=6d4c92c4-8f47-4319-ac7c-e64f8e469efc',
                    fit: BoxFit.cover),
                  ),
              ),
            ),
          ),
        ),
      );
  }
}
