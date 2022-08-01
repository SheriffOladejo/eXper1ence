import 'dart:convert';

import 'package:experience/models/sport.dart';
import 'package:experience/utils/constants.dart';
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/utils/widgets.dart';
import 'package:experience/views/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectSportScreen extends StatefulWidget {

  @override
  State<SelectSportScreen> createState() => _SelectSportScreenState();
}

class _SelectSportScreenState extends State<SelectSportScreen> {

  DbHelper db_helper = DbHelper();

  List<Sport> sport_list = [];
  List<Sport> selected_sports = [];
  String selected_sport = "";

  bool is_loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: is_loading ? null : FloatingActionButton(
        backgroundColor: HexColor("#0F324F"),
        onPressed: () async {
          if(selected_sports.isEmpty){
            selected_sports.add(sport_list[0]);
            await saveSports();
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
        child: CircleAvatar(
            backgroundColor: HexColor("#0F324F"),
            child: const Icon(CupertinoIcons.chevron_forward, size: 24, color: Colors.white,)
        ),
      ),
      body: is_loading ? loadingPage() : Container(
        color: HexColor(Constants.background_color),
        child: GestureDetector(
          onTap: () async {
            await showAlertDialog(context);
          },
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Choose sports", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
                      const Icon(CupertinoIcons.chevron_down, color: Colors.white, size: 18,),
                    ],
                  ),
                ),
                Container(width: 200, color: Colors.white,height: 1,),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Select sports", style: primaryTextStyle(16, Colors.white, FontWeight.bold),),
        backgroundColor: HexColor("#0F324F"),
      ),
    );
  }

  Future<void> getSports() async {
    setState(() {
      is_loading = true;
    });
    sport_list.clear();
    var url = Uri.https(Constants.api_url, '/v1/sports/Line/en');
    var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
    if(response.statusCode == 200){
      var json = jsonDecode(response.body.toString());
      //print("select_sport.getSports response ${response.body.toString()}");
      List<dynamic> list = json["body"];
      //print("select_sport.getSports list ${list.toString()}");
      for(var i = 0; i<list.length; i++){
        var id = list[i]["id"];
        var name = list[i]["name_en"];

        Sport s = Sport(
          id: int.parse(id.toString()),
          name: name,
          is_selected: false,
        );
        sport_list.add(s);

        sport_list.sort((a,b){
          return a.name.compareTo(b.name);
        });
      }
      setState(() {
        is_loading = false;
      });
    }
    else{
      setState(() {
        is_loading = false;
      });
      print("select_sports.getSports: status code is not 200");
    }

  }

  Future<void> init() async {
    await getSports();
  }

  @override
  void initState(){
    init();
    super.initState();
  }

  Future<void> saveSports() async {
    await db_helper.deleteSports();
    await db_helper.saveSports(selected_sports);
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: HexColor("#0F324F"),
      content: SelectSportDialog(
        sport_list: sport_list,
        selected_sports: selected_sports,
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}

class SelectSportDialog extends StatefulWidget {

  List<Sport> sport_list = [];
  List<Sport> selected_sports = [];

  SelectSportDialog({
    this.sport_list,
    this.selected_sports,
  });

  @override
  State<SelectSportDialog> createState() => _SelectSportDialogState();
}

class _SelectSportDialogState extends State<SelectSportDialog> {

  bool select_all = false;

  DbHelper db_helper = DbHelper();

  bool is_loading = false;

  Widget sportItem(Sport sport, int index) {
    return ListTile(
      title: Text(
        sport.name,
        style: primaryTextStyle(15, Colors.white, FontWeight.normal),
      ),
      trailing: sport.is_selected
          ? const Icon(
        Icons.check_circle,
        color: Colors.blue,
      )
          : const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      onTap: () {
        setState(() {
          widget.sport_list[index].is_selected = !widget.sport_list[index].is_selected;
          if (widget.sport_list[index].is_selected == true) {
            widget.selected_sports.add(sport);
          } else if (widget.sport_list[index].is_selected == false) {
            widget.selected_sports
                .removeWhere((element) => element.name == widget.sport_list[index].name);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return is_loading ? loadingPage() : mainPage();
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    //sport_list = await db_helper.getUsersSQLite();

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
    return SafeArea(
      child: Container(
        color: HexColor("#0F324F"),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: widget.sport_list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Sport s = widget.sport_list[index];
                    return sportItem(s,index);
                  }),
            ),
            widget.selected_sports.isNotEmpty ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 10,
              ),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    "Save (${widget.selected_sports.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    await db_helper.deleteSports();
                    //print("settings.build selected_sports ${widget.selected_sports.length}");
                    await db_helper.saveSports(widget.selected_sports);
                    Navigator.pop(context);
                    //print("select_country.mainPage : Saved List Length: ${widget.selected_sports.length}");
                  },
                ),
              ),
            ): Container(),
          ],
        ),
      ),
    );
  }

}

