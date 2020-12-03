import 'package:charaben_app/presentation/account_setting/account_setting_page.dart';
import 'package:charaben_app/presentation/recipe_edit/recipe_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/presentation/recipe_detail/recipe_detail_model.dart';

class RecipeDetailPage extends StatelessWidget {
  RecipeDetailPage(this.recipe);

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeDetailModel>(
      create: (_) => RecipeDetailModel(recipe),
      child: Consumer<RecipeDetailModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(36.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  if (model.user != null &&
                      recipe.author['id'] == model.user.uid)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20.0,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeEditPage(model.recipe),
                            fullscreenDialog: true,
                          ),
                        );
                        await model.fetchRecipe();
                        await ImageCache().clear();
                      },
                    ),
                ],
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                '${model.userStoragePath}${recipe.author['id']}?alt=media'),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(recipe.author['name']),
                        ]),
                      ),
                      Image.network(
                          '${model.imageStoragePath}${recipe.documentId}?alt=media'),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            alignment: Alignment.topLeft,
                            child: IconButton(
                                icon: model.likes != null && model.isMyLike
                                    ? Icon(Icons.favorite,
                                        size: 30, color: Colors.red)
                                    : Icon(Icons.favorite_border, size: 30),
                                onPressed: () async {
                                  // いつかここでもいいねできるようにする
//                              try {
//                                await model.changeLike(index);
//                                if (model.guideToLogin) {
//                                  const message =
//                                      'いいねはログイン後にご利用になることができます。\nMyPageからログインしてください。';
//                                  showTextDialog(context, message);
//                                }
//                              } catch (e) {
//                                showTextDialog(context, e);
//                              }
                                }),
                          ),
                          Text(
                              '${model.likes == null ? 0 : model.likes.length}人がいいねしています')
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${model.recipe.caption}'),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      if (model.recipe.reference.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '参考にしたキャラ弁のURLや書籍名',
                                style: TextStyle(fontSize: 12,
                                                 fontWeight: FontWeight.bold),
                              ),
                              Text(model.recipe.reference),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(),
              ],
            ));
      }),
    );
  }
}
