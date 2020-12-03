import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/common/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '';
import '../introduction_edit/introduction_edit_page.dart';
import 'my_edit_model.dart';

class MyEditPage extends StatelessWidget {
  MyEditPage(this.user) {}
  UserData user;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyEditModel>(
      create: (_) => MyEditModel(user),
      child: Consumer<MyEditModel>(
        builder: (context, model, child) {
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
                  'アカウント情報編集',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
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
                ListView(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 150.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () async {
                          await model.showImagePicker();
                          if (model.imageFile != null) {
                            final result = await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text('画像を変更してよろしいですか？\n※画像変更の反映には時間がかかる場合があります'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('キャンセル'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      ),
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      ),
                                  ],
                                  );
                              },
                              );
                            if (result) {
                              model.updateImage();
                              imageCache.clear();
                            } else {
                              model.clearImage();
                            }
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: model.imageFile == null ? NetworkImage(
                              '${model.userStoragePath}${model.user.userId}?alt=media'
                              ) : FileImage(model.imageFile),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: new BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('名前',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.user.name,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          '※名前は変更できません',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: new BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('自己紹介',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.user.introduction,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IntroductionEditPage(model.user),
                            ),
                          );
                        await model.getUser();
                      }),
                  Container(
                    decoration: new BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
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
                      elevation: 0,
                      child: Text('ログアウト'),
                      color: Colors.lightBlue,
                      textColor: Colors.white,
                      onPressed: () async {
                        model.startLoading();
                        try {
                          await model.logout();
                          model.endLoading();
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
//                                    Container(
//                                      child: Text('レシピを保存しています...'),
//                                    ),
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
        },
      ),
    );
  }
}
