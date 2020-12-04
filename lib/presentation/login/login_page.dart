import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/account_setting/account_setting_page.dart';
import 'package:charaben_app/presentation/login/login_model.dart';
import 'package:charaben_app/presentation/signup/signup_page.dart';
import 'package:charaben_app/common/convert_error_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final sendMailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>(
        create: (_) => LoginModel(),
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "ユーザー登録",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.close,
                size: 30.0,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Consumer<LoginModel>(
            builder: (context, model, child) {
              return Stack(children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: mailController,
                          onChanged: (text) {
                            model.changeMail(text);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            errorText:
                                model.errorMail == '' ? null : model.errorMail,
                            labelText: 'メールアドレス',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: passwordController,
                          onChanged: (text) {
                            model.changePassword(text);
                          },
                          obscureText: true,
                          maxLines: 1,
                          decoration: InputDecoration(
                            errorText: model.errorPassword == ''
                                ? null
                                : model.errorPassword,
                            labelText: 'パスワード',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(),
                            FlatButton(
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'ログインできない場合',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Container(
                                          height: 150,
                                          child: Column(
                                            children: [
                                              Icon(Icons.mail, size: 30),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'パスワードリセットメールをお送りします\nメールアドレスを入力してください。',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                controller: sendMailController,
                                                onChanged: (text) {
                                                  model.changeSendMail(text);
                                                },
                                                obscureText: true,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  errorText:
                                                      model.errorSendMail == ''
                                                          ? null
                                                          : model.errorSendMail,
                                                  labelText: 'メールアドレス',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              FlatButton(
                                                child: Text('キャンセル'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('送信',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  model.sendPasswordResetEmail();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (model.existsError != null) {
                                    showTextDialog(context, model.existsError);
                                  }
                                },
                                child: Text(
                                  'パスワードを忘れた場合',
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        FlatButton(
                          onPressed: () async {
                            _launchURL();
                          },
                          child: Text('利用規約に同意して',
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                            ),
                          textAlign: TextAlign.left,)
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            elevation: 0,
                            child: Text('ログイン'),
                            color: Colors.lightBlue,
                            textColor: Colors.white,
                            onPressed: () async {
                              model.startLoading();
                              try {
                                await model.login();
                                model.endLoading();
                                await Navigator.pop(context, true);
                              } catch (e) {
                                if (e == 'isNotVerified') {
                                  showEmailNotVerifyTextDialog(context);
                                } else {
                                  showTextDialog(context, convertErrorMessage(e.code));
                                }
                                model.endLoading();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        FlatButton(
                          child: Text(
                            '新規登録はこちらから',
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox()
              ]);
            },
          ),
        ));
  }

  showPasswordResetTextDialog(context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ログインできない場合',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                        'パスワードリセットメールをお送りします\nメールに記載されているアドレスをクリックして登録を完了してください。'))
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  child: Text('キャンセル'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                FlatButton(
                  child: Text('OK', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  _launchURL() async {
    const url = "https://charaven-app.web.app/";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not Launch $url';
    }
  }
}
