import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/common/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'introduction_edit_model.dart';

class IntroductionEditPage extends StatelessWidget {
  IntroductionEditPage(this.user){}
  UserData user;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IntroductionEditModel>(
        create: (_) => IntroductionEditModel(user),
        child: Consumer<IntroductionEditModel>(builder: (context, model, child) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(32.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                centerTitle: true,
                title: Text(
                  '自己紹介編集',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            body: Stack(
              children: [
                Column(
                    children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      initialValue: model.user.introduction,
                      onChanged: (text) {
                        model.changeIntroduction(text);
                      },
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: '自己紹介',
                        alignLabelWithHint: true,
                        errorText:
                            model.errorIntroduction == '' ? null : model.errorIntroduction,
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10, top: 0.0, right: 10.0, bottom: 0.0),
                    width: double.infinity,
                    height: 50,
                    child: RaisedButton(
                      elevation: 0.0,
                      child: Text('変更する'),
                      color: Colors.lightBlue,
                      textColor: Colors.white,
                      onPressed: () async {
                        model.startLoading();
                        try {
                          await model.updateIntroduction();
                          await model.endLoading();
                          await Navigator.pop(context, true);
                        } catch (e) {
                          showTextDialog(context, e);
                          model.endLoading();
                        }
                      },
                    ),
                  ),
                ]),
                model.isUploading
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.withOpacity(0.7),
                        child: Center(
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
        }));
  }
}
