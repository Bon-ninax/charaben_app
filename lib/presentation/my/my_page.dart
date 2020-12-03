import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/login/login_page.dart';
import 'package:charaben_app/presentation/my/my_model.dart';
import 'package:charaben_app/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:charaben_app/presentation/signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget {
  MyPage(this.userState, this.updateTime) {}
  UserState userState;
  DateTime updateTime;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyModel>(
      create: (_) => MyModel(userState),
      child: Consumer<MyModel>(
        builder: (context, model, child) {
          if (model.userState != this.userState) {
            model.fetchUser();
          }
          if (updateTime != model.updateTime) {
            model.checkIfNeedUpdate (updateTime);
          }
          return Container(
            child: Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  print('Loading New Data');
                  model.checkIfNeedUpdate(DateTime.now());
                },
                child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400.0, //横割合
                      mainAxisSpacing: 2.0, // 縦間
                      crossAxisSpacing: 2.0, //横間
                      childAspectRatio: 1.0, //縦割合
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return model.charabenList.length != null
                          ? Container(
                              height: double.infinity,
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Container(
                                height: double.infinity,
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeDetailPage(
                                            model.charabenList[index]),
                                      ),
                                    );
                                    await ImageCache().clearLiveImages();
                                  },
                                  child: Image.network(
                                    '${model.storagePath}${model.charabenList[index].documentId}?alt=media',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    },
                    itemCount: model.charabenList == null ||
                            model.charabenList.length == null
                        ? 0
                        : model.charabenList.length),
              ),
            ),
          );
        },
      ),
    );
  }
}
