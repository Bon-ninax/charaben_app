import 'package:charaben_app/presentation/login/login_page.dart';
import 'package:charaben_app/presentation/recipe_add/recipe_add_page.dart';
import 'package:charaben_app/presentation/signup/signup_page.dart';
import 'package:charaben_app/presentation/top/top_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopPage extends StatelessWidget {
  @override
  var imageFile;

  @override
  Widget build(BuildContext context) {
    final Size _size=MediaQuery
        .of(context)
        .size;
    // ページ切り替え用のコントローラを定義
    PageController _pageController;

    return ChangeNotifierProvider<TopModel>(
        create: (_) => TopModel(),
        child: Consumer<TopModel>(
          builder: (context, model, child) {
            final List items = model.charabenList;
            return Scaffold(
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 60,
                    titleSpacing: 0,
                    backgroundColor: Colors.white,

                    flexibleSpace: FlexibleSpaceBar(
                      //title: Text('ImagePicker'),
                      background: Column(
                        children: [
                          SizedBox(height: 50.0),
                          Container(
                            height: 40.0,
                            width: double.infinity,
                            child: CupertinoTextField(

                              //initialValue: model.mySearchWords,
                              //                  onChanged: (text) async {
                              //                    model.changeMySearchWords(text);
                              //                    if (text.isNotEmpty) {
                              //                      model.startMyRecipeFiltering();
                              //                      await model.filterMyRecipe(text);
                              //                    } else {
                              //                      model.endMyRecipeFiltering();
                              //                    }
                              //                  },
                              maxLines: 1,
//                  decoration: InputDecoration(
//                    errorText: model.mySearchErrorText == ''
//                        ? null
//                        : model.mySearchErrorText,
//                    labelText: 'レシピ名 や 材料名 で検索',
//                    border: OutlineInputBorder(),
//                    ),
                              placeholder: '検索',
                              style: TextStyle(
                                fontSize: 12.0,
                                height: 1.0,
                                ),
                              ),
                            ),
                        ],
                        ),
                      ),
                    ),
                  SliverFixedExtentList(
                    itemExtent: model.screen == 0 ? 350.0 : 0,
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return Image.network(items[index].imageURL,
                                                 fit: BoxFit.fitWidth);
                      },
                      childCount: items.length,
                          //semanticIndexOffset: 2,
                          ),
                    //[
                    //              GridView.count(
                    //              crossAxisCount: 1,
                    //              children: List.generate(items.length, (index) {
                    //                return Center(
                    //                  child: Image.network(items[index].imageURL),
                    //                  );
                    //              }),
                    //              ),
                    //],
                    ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,//横割合
                      mainAxisSpacing: 10.0,// 縦間
                      crossAxisSpacing: 10.0,//横間
                      childAspectRatio: 1.0,//縦割合
                      ),
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          color: Colors.teal[100 * (index % 9)],
                          child: Image.network(items[index].imageURL),
                          );
                      },
                      childCount: model.screen == 1 ? items.length : 0,
                          ),
                    ),

                ],
                ),
              bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      title: Text('Home'),
                      ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      title: Text('Search'),
                      ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      title: Text('add'),
                      ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      title: Text('Mypage'),
                      ),
                  ],
                  currentIndex: model.screen,
                  onTap: (index) {
                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeAddPage(),
                          fullscreenDialog: true,
                          ),
                        );
                    }
                    model.changeScreen(index);
                  }
                  ),
              );//Theme.of(context).primaryColor,
          },
          )
        );
  }
}