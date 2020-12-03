import 'package:charaben_app/common/text_dialog.dart';
import 'package:charaben_app/presentation/recipe_edit/recipe_edit_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipeEditPage extends StatelessWidget {
  RecipeEditPage(this.recipe) {}
  final recipe;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeEditModel>(
      create: (_) => RecipeEditModel(recipe),
      child: Consumer<RecipeEditModel>(
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
                  '編集',
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
                                        Image.network(
                                            '${model.storagePath}${model.recipe.documentId}?alt=media',
                                            fit: BoxFit.fitWidth),
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
                          initialValue: model.recipe.caption,
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
                          initialValue: model.recipe.reference,
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
                                onPressed: model.imageFile != null ||
                                        model.isCaptionValid &&
                                            model.isReferenceValid
                                    ? () async {
                                        await addRecipe(model, context);
                                      }
                                    : null),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton(
                                child: Text('削除',
                                    style: TextStyle(color: Colors.grey)),
                                style: OutlinedButton.styleFrom(
                                  primary: Colors.black,
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                onPressed: () async {
                                  try {
                                    await model.deleteRecipe ();
                                  } catch(e) {
                                    showTextDialog(context, e);
                                  }
                                }),
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

Future addRecipe(RecipeEditModel model, BuildContext context) async {
  model.startLoading();
  try {
    await model.addRecipeToFirebase();
    model.endLoading();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('レシピを編集しました。\n画像の反映に時間がかかる場合があります。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
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
