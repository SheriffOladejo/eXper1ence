import 'package:experience/models/match.dart';
import 'package:experience/models/user.dart';
import 'package:experience/utils/constants.dart';
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/utils/widgets.dart';
import 'package:flutter/material.dart';

class SelectTeam extends StatefulWidget {

  Match match;
  SelectTeam({this.match});

  @override
  State<SelectTeam> createState() => _SelectTeamState();
}

class _SelectTeamState extends State<SelectTeam> {

  User user;
  DbHelper db_helper = DbHelper();

  bool is_loading = false;

  bool opp1_selected = false;
  bool opp2_selected = false;

  @override
  Widget build(BuildContext context) {
    String date = "26.06.2022";
    return Scaffold(
      backgroundColor: HexColor("#0F324F"),
      appBar: AppBar(
        title: Text(date, style: primaryTextStyle(15, Colors.white, FontWeight.bold),),
        centerTitle: true,
        backgroundColor: HexColor("#0F324F"),
      ),
      resizeToAvoidBottomInset: true,
      body: is_loading ? loadingPage() : mainPage(),
    );
  }

  Future<void> init() async {
    user = await db_helper.getUser();
    setState(() {

    });
  }

  @override
  void initState(){
    super.initState();
    init();
  }

  Widget mainPage(){
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height/2.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    if(opp2_selected){
                      opp2_selected = false;
                    }
                    opp1_selected = true;
                    widget.match.selected_team = widget.match.opp1_name;
                  });
                },
                child: Container(
                  decoration: opp1_selected ? BoxDecoration(
                      border: Border.all(color: Colors.white)
                  ) : null,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Column(
                    children: [
                      Container(height: 15,),
                      Container(
                          width: 120,
                          height: 100,
                          child: Text(widget.match.opp1_name, textAlign: TextAlign.center, style: primaryTextStyle(16, Colors.white, FontWeight.bold),)
                      ),
                      Container(height: 15,),
                      Image.network(
                        "${Constants.team_icon_api}/${widget.match.opp1_icon}.png", width: 100, height: 100,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Image.asset("assets/images/user.png", width: 100, height: 100,);
                        },
                      ),
                      //Image.network(widget.bet.opp1_icon, width: 70, height: 60,),
                      Container(height: 15,),
                      Container(
                        decoration: opp1_selected ? BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: HexColor("#9ABAD1"),
                        ) : BoxDecoration(color: HexColor("#9ABAD1"),),
                        alignment: Alignment.center,
                        width: 70,
                        height: 30,
                        child: Text(
                          widget.match.opp1_odds.toString(),
                          style: primaryTextStyle(18, opp1_selected ? Colors.white : HexColor("#0F324F"), FontWeight.bold),
                        ),
                      ),
                      Container(height: 15,),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Container(height: 80,),
                  Text("VS", style: primaryTextStyle(20, Colors.white, FontWeight.bold),),
                  Container(height: 20,),
                  Image.asset("assets/images/vs.png")
                ],
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    if(opp1_selected){
                      opp1_selected = false;
                    }
                    widget.match.selected_team = widget.match.opp2_name;
                    opp2_selected = true;
                  });
                },
                child: Container(
                  decoration: opp2_selected ? BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ) : BoxDecoration(),
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Column(
                    children: [
                      Container(height: 15,),
                      Container(
                          height: 100,
                          width: 120,
                          child: Text(widget.match.opp2_name, textAlign: TextAlign.center, style: primaryTextStyle(16, Colors.white, FontWeight.bold),)
                      ),
                      Container(height: 15,),
                      Image.network(
                        "${Constants.team_icon_api}/${widget.match.opp2_icon}.png", width: 100, height: 100,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Image.asset("assets/images/user.png", width: 100, height: 100,);
                        },
                      ),
                      //Image.network(widget.bet.opp1_icon, width: 70, height: 60,),
                      Container(height: 15,),
                      Container(
                        decoration: opp2_selected ? BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: HexColor("#9ABAD1"),
                        ) : BoxDecoration(color: HexColor("#9ABAD1"),),
                        alignment: Alignment.center,
                        width: 70,
                        height: 30,
                        child: Text(
                          widget.match.opp2_odds.toString(),
                          style: primaryTextStyle(18, opp2_selected ? Colors.white : HexColor("#0F324F"), FontWeight.bold),
                        ),
                      ),
                      Container(height: 15,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          color: HexColor("#33536E"),
        ),
        GestureDetector(
          onTap: () async {
            await selectTeam();
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            alignment: Alignment.center,
            width: 200,
            height: 30,
            child: Text(
              "Select team",
              style: primaryTextStyle(18, Colors.white, FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> selectTeam() async {
    if(opp1_selected || opp2_selected){
      List<Match> match_list = await db_helper.getUserMatches();
      bool is_exist = false;
      match_list.removeWhere((element){
        if(element.id == widget.match.id){
          return is_exist = true;
        }
        return false;
      });
      if(is_exist){
        await db_helper.deleteUserMatch(widget.match.id);
      }
      await db_helper.saveUserMatch(widget.match);
    }
    Navigator.pop(context);
  }

}
