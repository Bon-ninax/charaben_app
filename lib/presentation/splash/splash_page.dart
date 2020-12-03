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
                      image: 'https://firebasestorage.googleapis.com/v0/b/charaven-app.appspot.com/o/splash.gif?alt=media&token=891f048b-39a1-48a1-aa7a-f15dff1a166f',
                    fit: BoxFit.cover),
                  ),
              ),
            ),
          ),
        ),
      );
  }
}
