import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/login/login_model.dart';
import 'package:charaben_app/presentation/signup/signup_page.dart';
import 'package:charaben_app/presentation/top/top_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account_setting_model.dart';

class AccountSettingPage extends StatelessWidget {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountSettingModel>(
        create: (_) => AccountSettingModel(),
        child: Scaffold(
          appBar:
          AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
              ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "ユーザーネームを作成",
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
          body: Consumer<AccountSettingModel>(
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
                          controller: nameController,
                          onChanged: (text) {
                            model.changeName(text);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            errorText:
                            model.errorName == '' ? null : model.errorName,
                            labelText: 'ユーザーネーム',
                            border: OutlineInputBorder(),
                            ),
                          ),
                        SizedBox(
                          height: 16,
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            elevation: 0,
                            child: Text('登録'),
                            color: Colors.lightBlue,
                            textColor: Colors.white,
                            onPressed: () async {
                              model.startLoading();
                              try {
                                await model.register();
                                model.endLoading();
                                await Navigator.pop(context, true);
                              } catch (e) {
                                showEmailNotVerifyTextDialog(context);
                                model.endLoading();
                              }
                            },
                            ),
                          ),
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
          title: Text('ログインできない場合',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)
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
                        'パスワードリセットメールをお送りします\nメールに記載されているアドレスをクリックして登録を完了してください。'
                        )
                    )
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
                  child: Text('OK',
                                  style: TextStyle(color: Colors.red)
                              ),
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
}
