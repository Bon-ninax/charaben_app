import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:charaben_app/presentation/top/top_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  List<Recipe> charabenList;
  SearchPage(this.charabenList){}
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopModel> (
        create: (_) =>
            TopModel (),
        //..init (),
        child: Consumer<TopModel> (
            builder: (context, model, child) {
              return GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400.0,//横割合
                  mainAxisSpacing: 1.0,// 縦間
                  crossAxisSpacing: 1.0,//横間
                  childAspectRatio: 1.0,//縦割合
                  ),
                itemBuilder: (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(charabenList[index]),
                              ),
                            );
                        },
                        child: Image.network('${model.user}${charabenList[index].documentId}?alt=media'),
                      )
                      );
                  },
                itemCount: charabenList.length,
                );
            },
            ),
        );
  }
}