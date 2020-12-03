import 'package:charaben_app/presentation/recipe_add/recipe_add_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '';

class RecipeAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeAddModel>(
      create: (_) => RecipeAddModel(),
      child: Consumer<RecipeAddModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(32.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black,
                  ),
                elevation: 0.0,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: Text(
                  '新規登録',
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
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, right: 16.0, bottom: 48.0, left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                          ),
                        Container(
                          alignment: Alignment.topLeft,
                          height: 150,
                          child: InkWell(
                            onTap: () {
                              model.showImagePicker();
                            },
                            child: model.imageFile == null
                                ? SizedBox(
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Container(
                                    color: Color(0xFFDADADA),
                                    ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate),
                                        SizedBox(
                                          height: 8,
                                          ),
                                        Text(
                                          'タップして画像を追加',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            ),
                                          ),
                                      ],
                                      ),
                                    ),
                                ],
                                ),
                              )
                                : Image.file(
                              model.imageFile,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 16,
                          ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.caption,
                          onChanged: (text) {
                            model.changeRecipeCaption(text);
                          },
                          minLines: 6,
                          maxLines: 20,
                          decoration: InputDecoration(
                            labelText: '作り方・材料',
                            alignLabelWithHint: true,
                            errorText: model.errorCaption == ''
                                ? null
                                : model.errorCaption,
                            ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.4,
                            ),
                          ),
                        SizedBox(
                          height: 16,
                          ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.reference,
                          onChanged: (text) {
                            model.changeRecipeReference(text);
                          },
                          minLines: 3,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: '参考にしたキャラ弁のURLや書籍名を記入',
                            alignLabelWithHint: true,
                            ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
                            ),
                          ),
                        SizedBox(
                          height: 16,
                          ),
                        SizedBox(
                          height: 16,
                          ),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: RaisedButton(
                              child: Text(
                                '登録',
                                ),
                              color: Colors.lightBlue,
                              textColor: Colors.white,
                              onPressed: model.imageFile != null &&
                                  model.isCaptionValid &&
                                  model.isReferenceValid
                                  ? () async {
                                await addRecipe(model, context);
                              }
                                  : null
                              ),
                            ),
                          ),
                      ],
                      ),
                    ),
                  ),
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
                              Container(
                                child: Text('レシピを保存しています...'),
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
        },
        ),
      );
  }
}

Future addRecipe(RecipeAddModel model, BuildContext context) async {
  model.startLoading();
  try {
    await model.addRecipeToFirebase();
    model.endLoading();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('レシピを追加しました。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
//                await Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    //builder: (context) => TopPage(),
//                    fullscreenDialog: true,
//                    ),
//                  );
                model.fetchRecipeAdd(context);
                Navigator.of(context).pop();
              },
              ),
          ],
          );
      },
      );
  } catch (e) {
    model.endLoading();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(e.toString()),
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
}
