import 'dart:convert';
import 'dart:math';

import 'package:experience/adapters/match_adapter.dart';
import 'package:experience/models/user.dart';
import 'package:experience/models/match.dart';
import 'package:experience/utils/constants.dart';
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/utils/widgets.dart';
import 'package:experience/views/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyMatches extends StatefulWidget {

  @override
  State<MyMatches> createState() => _MyMatchesState();
}

class _MyMatchesState extends State<MyMatches> {

  User user;
  DbHelper db_helper = DbHelper();

  List<Match> my_future_match_list = [];
  List<Match> my_past_match_list = [];

  int wins = 0;

  bool is_loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#9ABAD1"),
      drawer: DrawerLayout(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("My matches", style: primaryTextStyle(16, Colors.white, FontWeight.bold),),
        backgroundColor: HexColor("#0F324F"),
      ),
      resizeToAvoidBottomInset: false,
      body: is_loading ? loadingPage() : mainPage(),
    );
  }

  Future<void> getFutureMatches() async {
    my_future_match_list = await db_helper.getUserMatches();
  }

  Future<void> getPastMatches() async {
    print("my_matches.getPastMatches winner ${user.points}");
    for(var i = 0; i<my_future_match_list.length; i++) {
      Match m = my_future_match_list[i];
      String game_id = my_future_match_list[i].id.toString();
      int game_time = int.parse(my_future_match_list[i].match_date);
      int now = DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000;
      if (now > game_time) {
        print("my_matches.getPastMatches match winner is ${m.winner} and loser is ${m.loser}");
        if(m.winner == "" && m.loser ==""){
          double winner_odds = 0;
          int winner = Random().nextInt(2);
          print("my_matches.getPastMatches winner ${user.points}");
          if (winner == 0) {
            if(m.selected_team == m.opp1_name){
              winner_odds = m.opp1_odds;
              double points = user.points;
              points += (winner_odds * 10);
              user.points = points;
              await db_helper.deleteUser();
              await db_helper.saveUser(user);
              m.winner = m.opp1_name;
              m.loser = m.opp2_name;
            }
            else{
              m.winner = m.opp1_name;
              m.loser = m.opp2_name;
            }
          }
          else if(winner == 1){
            if(m.selected_team == m.opp2_name){
              winner_odds = m.opp2_odds;
              double points = user.points;
              points += (winner_odds * 10);
              user.points = points;
              await db_helper.deleteUser();
              await db_helper.saveUser(user);
              m.winner = m.opp2_name;
              m.loser = m.opp1_name;
            }
            else{
              m.winner = m.opp2_name;
              m.loser = m.opp1_name;
            }
          }
        }

        if(m.winner == m.selected_team){
          wins++;
        }
        await db_helper.deleteUserMatch(m.id);
        await db_helper.saveUserMatch(m);
        my_past_match_list.add(m);
      }
    }
    for(var i = 0; i<my_past_match_list.length; i++){
      Match m = my_past_match_list[i];
      my_future_match_list.removeWhere((element){
        if(element.id == m.id){
          return true;
        }
        return false;
      });
    }
  }

  Future<void> init() async {
    setState(() {
      is_loading = true;
    });
    user = await db_helper.getUser();
    await getFutureMatches();
    await getPastMatches();
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
    return Container(
      child: Column(
        children: [
          Container(height: 1, width: MediaQuery.of(context).size.width, color: HexColor("#9ABAD1"),),
          Container(
            height: 30,
            alignment: Alignment.center,
            color: HexColor("#0F324F"),
            child: Text("Future matches", style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
          ),
          Container(
            color: HexColor("#9ABAD1"),
            height: MediaQuery.of(context).size.height/2.5,
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: my_future_match_list.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                Match m = my_future_match_list[index];
                return MatchAdapter(match: m,);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: HexColor("#0F324F"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Past matches", style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
                Text(wins == 1 ? "1 Win" : "$wins Wins", style: primaryTextStyle(14, Colors.white, FontWeight.bold),)
              ],
            ),
          ),
          Container(
            color: HexColor("#9ABAD1"),
            height: MediaQuery.of(context).size.height/2.5,
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: my_past_match_list.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                Match m = my_past_match_list[index];
                return MatchAdapter(match: m,);
              },
            ),
          ),
        ],
      ),
    );
  }

}
