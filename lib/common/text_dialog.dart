import 'package:flutter/material.dart';

showTextDialog(context, message) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            ),
        ],
        );
    },
    );
}

showEmailVerifyTextDialog(context, email) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('メールを確認して登録を続けてください。\n${email}宛にメールを送信しました。'),
        content: Container(
          height: 100,
          child: Column(
            children: [
              Icon(Icons.mail, size: 30),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                  child: Text(
                      'メールに記載されているアドレスをクリックして登録を完了してください。'
                      )
                )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            ),
        ],
        );
    },
    );
}

showEmailNotVerifyTextDialog(context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('メールアドレスが認証されていません'),
        content: Container(
          height: 100,
          child: Column(
            children: [
              Icon(Icons.mail, size: 30),
              SizedBox(
                height: 10,
                ),
              Container(
                  height: 50,
                  child: Text(
                      'ご登録のメールアドレスに届いた認証メールをご確認ください。\nメールに記載されているアドレスをクリックして登録を完了してください。'
                      )
                  )
            ],
            ),
          ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            ),
        ],
        );
    },
    );
}
