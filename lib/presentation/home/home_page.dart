import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/home/home_model.dart';
import 'package:charaben_app/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage(UserState this.userState, this.updateTime) {}
  UserState userState;
  DateTime updateTime;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel(userState),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        if (model.userState != this.userState) {
          model.fetchUser();
        }
        if (updateTime != model.updateTime) {
          model.checkIfNeedUpdate(updateTime);
        }
        return model.isLoading
            ? Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        print('Loading New Data');
                        model.checkIfNeedUpdate(DateTime.now());
                      },
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == model.charabenList.length - 1 &&
                              model.canLoadMoreList) {
                            model.fetchCharabenList();
                          }
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                        '${model.userStoragePath}${model.charabenList[index].author['id']}?alt=media'),
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                      model.charabenList[index].author['name']),
                                ]),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailPage(
                                          model.charabenList[index]),
                                    ),
                                  );
                                  await ImageCache().clear();
                                },
                                child: Image.network(
                                    '${model.imageStoragePath}${model.charabenList[index].documentId}?alt=media',
                                    fit: BoxFit.fitWidth),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      child: IconButton(
                                          icon: model.likes != null &&
                                                  model.likes.contains(model
                                                      .charabenList[index]
                                                      .documentId)
                                              ? Icon(Icons.favorite,
                                                  size: 30, color: Colors.red)
                                              : Icon(Icons.favorite_border,
                                                  size: 30),
                                          onPressed: () async {
                                            try {
                                              await model.changeLike(index);
                                              if (model.guideToLogin) {
                                                const message =
                                                    'いいねはログイン後にご利用になることができます。\nMyPageからログインしてください。';
                                                showTextDialog(context, message);
                                              }
                                            } catch (e) {
                                              showTextDialog(context, e);
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: FlatButton(
                                          onPressed: () async {
                                            await model.report(index);
                                            showTextDialog(context,
                                                'お知らせありがとうございます。\n投稿が不適切な内容か確認いたします。');
                                          },
                                          child: Text(
                                            '通報する',
                                            style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.left,
                                          )),
                                    ),
                                  ]),
                              Container(
                                  padding: EdgeInsets.only(
                                      left: 8.0,
                                      top: 4.0,
                                      right: 8.0,
                                      bottom: 4.0),
                                  alignment: Alignment.topLeft,
                                  child:
                                      Text(model.charabenList[index].caption))
                            ],
                          );
                        },
                        itemCount: model.charabenList != null
                            ? model.charabenList.length
                            : 0,
                      ),
                    ),
                  )
                ],
              )
            : Container(
                color: Color(0xFFDADADA),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              );
      }),
    );
  }
}
