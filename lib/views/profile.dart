import 'dart:convert';
import 'dart:io';
import 'package:experience/adapters/match_adapter.dart';
import 'package:experience/models/match.dart';
import 'package:experience/models/championship.dart';
import 'package:experience/models/country.dart';
import 'package:experience/models/sport.dart';
import 'package:experience/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/utils/methods.dart';
import 'package:experience/utils/widgets.dart';
import 'package:experience/views/drawer.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  User user;
  DbHelper db_helper = DbHelper();

  File profile_image;

  bool is_loading = false;

  List<Country> country_list = [];
  List<Sport> sport_list = [];
  List<Championship> champ_list = [];

  List<Match> past_match_list = [];

  int match_num = 0;

  List<dynamic> future_match_list = [];
  List<Match> today_match_list = [Match(id: -1)];
  List<Match> tomorrow_match_list = [Match(id: -2)];

  TextEditingController nickname_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#9ABAD1"),
      drawer: is_loading ? null : DrawerLayout(),
      appBar: AppBar(
        backgroundColor: HexColor("#0F324F"),
      ),
      resizeToAvoidBottomInset: false,
      body: is_loading ? loadingPage() : mainPage(),
    );
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    country_list = await db_helper.getCountries();
    sport_list = await db_helper.getSports();
    List<Match> user_match = await db_helper.getUserMatches();
    for(var i = 0; i<user_match.length; i++){
      if(user_match[i].winner == ""){
        match_num = user_match.length;
      }
    }

    await getChampionships();
    await getFutureMatches();
    user = await db_helper.getUser();
    user ??= User(
        nickname: "",
        points: 0,
        profile_picture: ""
    );
    nickname_controller.text = user.nickname;
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState(){
    super.initState();
    init();
  }

  Future<void> getChampionships() async {
    setState(() {
      is_loading = true;
    });
    await db_helper.deleteChampionships();
    champ_list.clear();
    if(country_list.length == 1 && country_list[0].name == "World"){
      for(var j = 0; j<sport_list.length; j++){
        String sport_id = sport_list[j].id.toString();
        String country_id = country_list[0].id.toString();
        var url = Uri.https(Constants.api_url, '/v1/tournaments/$sport_id/$country_id/live/en');
        var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
        if(response.statusCode == 200){
          print("profile.getChampionships response is ${response.body.toString()}");
          var json = jsonDecode(response.body.toString());
          List<dynamic> list = json["body"];
          for(var k = 0; k<list.length; k++){
            var id = list[k]["id"];
            var name = list[k]["name"];
            var name_en = list[k]["name_en"];
            var sport_id = list[k]["sport_id"];
            var country_id = list[k]["country_id"];
            var country = country_list[0].name_en;
            var sport = sport_list[j].name;

            Championship c = Championship(
                id: int.parse(id.toString()),
                name: name,
                name_en: name_en,
                sport_id: sport_id,
                country_id: country_id,
                country: country,
                sport: sport
            );
            champ_list.add(c);
          }
        }
        else{
          print("profile.getChampionships: status code is not 200");
        }
      }
      await db_helper.saveChampionships(champ_list);
      setState(() {
        is_loading = false;
      });
    }
    else{
      for(var i = 0; i<country_list.length; i++){
        for(var j = 0; j<sport_list.length; j++){
          String sport_id = sport_list[j].id.toString();
          String country_id = country_list[i].id.toString();
          var url = Uri.https(Constants.api_url, '/v1/tournaments/$sport_id/$country_id/Line/en');
          var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
          if(response.statusCode == 200){
            print("profile.getChampionships response is ${response.body.toString()}");
            var json = jsonDecode(response.body.toString());
            List<dynamic> list = json["body"];
            if(list.isNotEmpty){
              for(var k = 0; k<list.length; k++){
                var id = list[k]["id"];
                var name = list[k]["name"];
                var name_en = list[k]["name_en"];
                var sport_id = list[k]["sport_id"];
                var country_id = list[k]["country_id"];
                var country = country_list[i].name_en;
                var sport = sport_list[j].name;

                Championship c = Championship(
                    id: int.parse(id.toString()),
                    name: name,
                    name_en: name_en,
                    sport_id: sport_id,
                    country_id: country_id,
                    country: country,
                    sport: sport
                );
                champ_list.add(c);
              }
            }
          }
          else{
            print("profile.getChampionships: status code is not 200");
          }
        }
      }
      print("profile.getChampionships: list length is ${champ_list.length}");
      // setState(() {
      //   is_loading = false;
      // });
    }
  }

  Future<void> getFutureMatches() async {
    setState(() {
      is_loading = true;
    });
    for(var i = 0; i<sport_list.length; i++){
      String sport_id = sport_list[i].id.toString();
      List<Championship> l = await db_helper.getChampionships(sport_list[i].id);
      for(var j = 0; j < l.length; j++){
        String champ_id = l[j].id.toString();
        var url = Uri.https(Constants.api_url, '/v1/events/$sport_id/$champ_id/list/1/Line/en/');
        var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
        if(response.statusCode == 200){
          print("profile.getFutureMatches response is ${response.body.toString()}");
          var json = jsonDecode(response.body.toString());
          List<dynamic> v = json["body"];
          if(v.isNotEmpty){
            List<dynamic> event_list = json["body"];
            if(event_list.isNotEmpty){
              for(var k = 0; k<event_list.length; k++){
                var game_id = event_list[k]["game_id"];
                var game_start = event_list[k]["game_start"];
                var opp1_name = event_list[k]["opp_1_name"];
                var opp2_name = event_list[k]["opp_2_name"];
                var opp1_icon = event_list[k]["opp_1_icon"];
                var opp2_icon = event_list[k]["opp_2_icon"];
                double opp1_odds = 0;
                double opp2_odds = 0;
                var winner = "";
                var loser = "";
                List<dynamic> odds_list = event_list[k]["game_oc_list"];
                for(var l = 0; l < odds_list.length; l++){
                  var odds_name = odds_list[l]["oc_name"];
                  var odds = double.parse(odds_list[l]["oc_rate"].toString());
                  if(odds_name.toString() == opp1_name){
                    opp1_odds = odds;
                  }
                  if(odds_name.toString() == opp2_name){
                    opp2_odds = odds;
                  }
                }
                Match m = Match(
                  id: game_id,
                  opp1_name: opp1_name,
                  opp2_name: opp2_name,
                  opp1_icon: opp1_icon.toString(),
                  opp2_icon: opp2_icon.toString(),
                  opp1_odds: opp1_odds,
                  opp2_odds: opp2_odds,
                  match_date: game_start.toString(),
                  winner: winner,
                  loser: loser,
                );
                if(opp2_odds == 0 || opp1_odds == 0){

                }
                else{
                  future_match_list.add(m);
                }
              }
            }
          }
        }
        else{
          print("profile.getFutureMatches: status code is not 200");
        }
      }
    }
    for(var i = 0; i<future_match_list.length; i++){
      int match_start = int.parse(future_match_list[i].match_date);
      double now = DateTime.now().millisecondsSinceEpoch / 1000;
      double diff = match_start - now;
      if(diff > 86400 && diff < 172800){
        tomorrow_match_list.add(future_match_list[i]);
        var date = DateTime.fromMillisecondsSinceEpoch(match_start * 1000);
        //print("profile.getFutureMatches tomorrow game date ${date.toString()}");
      }
      else if(diff < 86400 && diff > -86400){
        today_match_list.add(future_match_list[i]);
        var date = DateTime.fromMillisecondsSinceEpoch(match_start * 1000);
        //print("profile.getFutureMatches today game date ${date.toString()}");
      }
    }
    future_match_list.clear();
    future_match_list.addAll(today_match_list);
    future_match_list.addAll(tomorrow_match_list);
    future_match_list.addAll(past_match_list);
    print("profile.getFutureMatches future match list is ${future_match_list.length}");
    setState(() {
      is_loading = false;
    });
  }

  Future<void> getPastMatches() async {
    setState(() {
      is_loading = true;
    });
    int now = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    List<int> days = [now];
    for(var i = 1; i<7; i++){
      days.add(now - 86400);
    }

    for(var i = 0; i<days.length; i++){
      String day = days[i].toString();
      for(var i = 0; i<sport_list.length; i++){
        String sport_id = sport_list[i].id.toString();
        List<Championship> l = await db_helper.getChampionships(sport_list[i].id);
        for(var j = 0; j < l.length; j++){
          String champ_id = l[j].id.toString();
          var url = Uri.https(Constants.api_url, '/v1/rez/getgames/en/$day/$sport_id/$champ_id');
          var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
          if(response.statusCode == 200){
            print("profile.getPastMatches response is ${response.body.toString()}");
            var json = jsonDecode(response.body.toString());
            List<dynamic> list = json["body"];
            for(var k = 0; k<list.length; k++){
              var game_id = list[k]["Id"];
              var game_start = list[k]["Start"];
              String name = list[k]["Name"].toString();
              List<String> opps = name.split("-");
              var opp1_name = opps[0];
              var opp2_name = opps[1];
              String score = list[k]["Score"].toString();
              var scores = score.substring(0, score.indexOf("("));
              print("profile.getPastMatches scores is $scores");
              List<String> s = scores.split(":");
              opp1_name = opp1_name + "_${s[0]}";
              opp2_name = opp2_name + "_${s[1]}";
              print("profile.getPastMatches opp1_name $opp1_name");
              print("profile.getPastMatches opp2_name $opp2_name");

              Match result = Match(
                id: game_id,
                match_date: game_start.toString(),
                opp2_name: opp2_name,
                opp1_name: opp1_name
              );
              past_match_list.add(result);
            }
          }
          else{
            print("profile.getFutureMatches: status code is not 200");
          }
        }
      }
    }
    setState(() {
      is_loading = false;
    });
  }

  Widget mainPage(){
    user ??= User(
        nickname: "",
        points: 0,
        profile_picture: ""
    );
    double points = user.points;
    int lvl = points ~/ 100;
    if(lvl == 1){
      lvl = 2;
    }
    double percent = (points % 100) / 100;
    if(points < 100){
      lvl = 1;
      percent = points / 100;
    }

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            color: HexColor("#33536E"),
            height: 180,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 50,
                      backgroundImage: user.profile_picture == "" ? const AssetImage("assets/images/user.png") : NetworkImage(user.profile_picture),
                    ),
                    Container(height: 5,),
                    GestureDetector(
                      onTap: () async {
                        profile_image = await selectImage();
                        if(profile_image != null){
                          setState(() {
                            is_loading = true;
                          });
                          String image_url = await uploadImageToFirebase(context, profile_image);
                          User user_ = User(
                              points: user.points,
                              profile_picture: image_url,
                              nickname: user.nickname.toString()
                          );
                          await db_helper.deleteUser();
                          await db_helper.saveUser(user_);
                          user = user_;
                          setState(() {
                            is_loading = false;
                          });
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Change", style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontFamily: 'aventa_black'
                        )),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 25, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: TextField(
                          onEditingComplete: () async {
                            User user_ = User(
                              points: user.points,
                              profile_picture: user.profile_picture,
                              nickname: nickname_controller.text.toString()
                            );
                            await db_helper.deleteUser();
                            await db_helper.saveUser(user_);
                          },
                          controller: nickname_controller,
                          decoration: InputDecoration(
                            labelStyle: secondaryTextStyle(16, Colors.white),
                            labelText: "Nickname",
                          ),
                          style: primaryTextStyle(16, Colors.white, FontWeight.bold)
                        ),
                      ),
                      Container(height: 3,),
                      Container(margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),height: 1,width: 80, color: Colors.white),
                      Container(height: 8,),
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 130,
                        animation: true,
                        lineHeight: 20.0,
                        animationDuration: 2500,
                        percent: percent,
                        center: Text("Lvl $lvl", style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
                        barRadius: const Radius.circular(5),
                        progressColor: Colors.green,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: HexColor("#0F324F"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Matches: $match_num", style: primaryTextStyle(16, Colors.white, FontWeight.bold),),
              ],
            ),
          ),
          future_match_list.isEmpty ?
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text("No match today", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
          ) :
          Flexible(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: future_match_list.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                Match m = future_match_list[index];
                return MatchAdapter(match: m,);
              },
            ),
          ),
        ],
      ),
    );
  }
}
