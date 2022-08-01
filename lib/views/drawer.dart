import 'package:experience/models/user.dart';
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/views/my_matches.dart';
import 'package:experience/views/profile.dart';
import 'package:experience/views/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerLayout extends StatefulWidget{

  BuildContext context;
  DrawerLayout({this.context});

  @override
  _DrawerLayoutState createState() => _DrawerLayoutState();

}

class _DrawerLayoutState extends State<DrawerLayout> {

  bool is_loading = false;
  User user;
  DbHelper db_helper = new DbHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: is_loading ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ) : mainPage(),
    );
  }

  Future<void> init() async{
    setState(() {
      is_loading = true;
    });
    //user = await db_helper.getUserSQLite();
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState(){
    init();
    super.initState();
  }

  Widget mainPage(){
    return SingleChildScrollView(
      child: Container(
          color: HexColor("#33536E"),
          width: 220,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.fromLTRB(0, 32.5, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  height: 55,
                  color: HexColor("#0F324F"),
                  child: const Icon(CupertinoIcons.back, color: Colors.white, size: 24,),
                  alignment: Alignment.centerLeft,
                ),
              ),
              option(CupertinoIcons.person_alt_circle,"Match list", onClickMatchlist),
              option(CupertinoIcons.bookmark_fill,"My matches", onClickMyMatches),
              option(CupertinoIcons.settings_solid,"Settings", onClickSettings),
              option(CupertinoIcons.info,"Privacy policy", onClickPrivacyPolicy),
            ],
          )
      ),
    );
  }

  void onClickMatchlist() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
  }

  void onClickMyMatches() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyMatches()));
  }

  void onClickPrivacyPolicy() async {
    var url = Uri.https("pages.flycricket.io", "/sporting-exper1ence/privacy.html");
    if(await canLaunchUrl(url)){
      await launchUrl(url);
    }
  }

  void onClickSettings() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Settings()));
  }

  Widget option(IconData icon, String title,VoidCallback function){
    return GestureDetector(
      onTap:function,
      child:Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: const EdgeInsets.fromLTRB(5, 5, 30, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: Colors.white,),
              Container(width: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Text(title, style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'aventa_regular'
                  )),
                  Container(height: 5,),
                ],
              )
            ],
          )
      ),
    );
  }

  Widget showOptionDialog(BuildContext context, String text){
    Dialog dialog = Dialog(
      child: Container(
          padding: EdgeInsets.all(15),
          child: Text(
            text,
          )
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

}
