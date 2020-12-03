import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/Home/home_page.dart';
import 'package:charaben_app/presentation/account_setting/account_setting_page.dart';
import 'package:charaben_app/presentation/login/login_page.dart';
import 'package:charaben_app/presentation/my/my_page.dart';
import 'package:charaben_app/presentation/my_edit/my_edit_page.dart';
import 'package:charaben_app/presentation/recipe_add/recipe_add_page.dart';
import 'package:charaben_app/presentation/search/search_page.dart';
import 'package:charaben_app/presentation/top/top_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
            return Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar (
                      expandedHeight: model.hederHeight,
                      titleSpacing: 0,
                      backgroundColor: Colors.white,

                      flexibleSpace: FlexibleSpaceBar (
                        //title: Text('ImagePicker'),
                        background: Column (
                          children: [
                            SizedBox (height: 40.0),
                            model.currentIndex != 1 ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('charaben',
                                       style: GoogleFonts.sawarabiMincho(
                                         fontSize: 20,
                                         fontWeight: FontWeight.w800,
                                       )
                                       ),
                                ),
                                SizedBox(width: 10,),
                                if(model.userState == UserState.registered) IconButton (
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RecipeAddPage(),
                                        fullscreenDialog: true,
                                        ),
                                      );
                                    await model.refreshUpdateTime();
                                    await ImageCache().clear();
                                  },
                                  icon: Icon (Icons.add)
                                  ),
                      ]
                              ) : Container(),
                            model.currentIndex == 1 ? Column(
                              children: [
                                //SizedBox (height: 50.0),
                                Container (
                                  padding: EdgeInsets.only(right: 20.0, left: 20),
                                  height: 70.0,
                                  width: double.infinity,
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    onChanged: (text) {
                                      model.changeMySearchWords(text);
                                      model.filterMyRecipe(text);
                                    },
                                    //minLines: 6,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      labelText: '検索',
                                      alignLabelWithHint: true,
                                      errorText: model.errorText == ''
                                          ? null
                                          : model.errorText,
                                      ),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      height: 0.6,
                                      ),
                                    ),
                                  ),
                              ],
                            ) : Column(),
                            model.currentIndex == 2 ? Padding(
                              padding: const EdgeInsets.only(left: 10.0,top: 0.0,right: 10.0,bottom: 10.0),
                              child: Column(

                                children: [
                                  if (model.userState!= null && model.userState == UserState.registered) Row(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                          NetworkImage('${model.userStoragePath}${model.user.userId}?alt=media'),
                                          )
                                      ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                  if (model.userState != null && model.userState == UserState.registered) Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(model.user.name,
                                               style: TextStyle(
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.bold
                                               ),),
                                          Text(model.user.introduction,
                                               maxLines: 3,)
                                        ],
                                      ),
                                  ),
                                  if (model.userState != UserState.registered) Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 60),
                                      Text(model.detailMessage,
                                             style: TextStyle(
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.bold
                                                 ),),
                                    ],
                                    ),
                                  Container(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      child: Text(model.message),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.black,
//                                        shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(10),
//                                          ),
                                        side: const BorderSide(
                                          color: Colors.grey
                                        ),
                                        ),
                                      onPressed: () async {
                                        if (model.userState == UserState.signedOut) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                              ),
                                            );
                                          await model.fetchUser();
                                        } else if (model.userState == UserState.registered) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MyEditPage(model.user),
                                              ),
                                            );
                                          await model.fetchUser();
                                          await ImageCache().clear();
                                        } else if (model.userState == UserState.signedIn) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AccountSettingPage(),
                                              ),
                                            );
                                          await model.fetchUser();
                                          //model.currentIndex = 1;
                                          await ImageCache().clear();
                                        }
                                      },
                                      ),
                                  ),
                                ],
                                ),
                            ): Column()
                          ],
                          )
                        ),
                      ),
                  ];
                },
                body: _topPageBody (context),
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
                          title: Text('search'),
                          ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_circle_outlined),
                          title: Text('Mypage'),
                          ),
                      ],
                      currentIndex: model.currentIndex,
                      onTap: (index) async {
                        model.changeScreen(index);
                      }
                      ),
              );//Theme.of(context).primaryColor,
          },
          )
        );
  }


  Widget _topPageBody(BuildContext context) {
    final model = Provider.of<TopModel>(context);
    final currentIndex = model.currentIndex;
    return Stack(
      children: <Widget>[
        _tabPage(currentIndex, 0, HomePage(model.userState, model.updateTime)),
        _tabPage(currentIndex, 1, SearchPage(model.serchedCharabenList)),
        _tabPage(currentIndex, 2, MyPage(model.userState, model.updateTime)),
      ],
      );
  }

  Widget _tabPage(int currentIndex, int tabIndex, StatelessWidget page) {
    return Visibility(
      visible: currentIndex == tabIndex,
      maintainState: true,
      child: page,
      );
  }

  _addButtonTapped(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeAddPage(),
        fullscreenDialog: true,
        ),
      );
  }
}