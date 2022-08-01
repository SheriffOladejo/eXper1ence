import 'package:experience/models/match.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/utils/widgets.dart';
import 'package:experience/views/select_team.dart';
import 'package:flutter/material.dart';

class MatchAdapter extends StatefulWidget {

  Match match;
  MatchAdapter({this.match});

  @override
  State<MatchAdapter> createState() => _MatchAdapterState();
}

class _MatchAdapterState extends State<MatchAdapter> {
  @override
  Widget build(BuildContext context) {

    bool opp1_win = false;
    bool opp2_win = false;

    bool win = false;
    if(widget.match.winner == widget.match.selected_team){
      win = true;
    }


    //print(widget.match.winner + " and " + widget.match.opp1_name);
    if(widget.match.winner == widget.match.opp1_name){
      opp1_win = true;
    }
    if(widget.match.winner == widget.match.opp2_name){
      opp2_win = true;
    }

    print("opp1_win $opp1_win opp2_win $opp2_win win $win");

    if(widget.match.id == -1){
      return Container(
        color: HexColor("#33536E"),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text("Today", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
      );
    }
    else if(widget.match.id == -2){
      return Container(
        color: HexColor("#33536E"),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text("Tomorrow", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
      );
    }
    else if(widget.match.id == -3){
      return Container(
        color: HexColor("#33536E"),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text("Past matches", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
      );
    }
    else if(opp1_win || opp2_win){
      return Container(
        width: MediaQuery.of(context).size.width,
        color: HexColor("#9ABAD1"),
        alignment: Alignment.center,
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  children: [
                    Text(widget.match.opp1_name, style: primaryTextStyle(16, Colors.white, FontWeight.bold),textAlign: TextAlign.center,),
                    Container(height: 5,),
                    Text(widget.match.opp2_name, style: primaryTextStyle(16, Colors.white, FontWeight.bold),textAlign: TextAlign.center,),
                  ],
                ),
                Column(
                  children: [
                    Text(widget.match.opp1_odds.toString(), style: primaryTextStyle(16, Colors.white, FontWeight.bold),textAlign: TextAlign.center,),
                    Container(height: 5,),
                    Text(widget.match.opp2_odds.toString(), style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
                    Container(height: 3,),
                  ],
                ),
                Text(win ? "WIN" : "LOSE", style: primaryTextStyle(16, HexColor("#0F324F"), FontWeight.bold),)
              ],
            ),
            Container(
              width: 300,
              color: HexColor("#0F324F"),
              height: 1,
            ),
          ],
        ),
      );
    }
    else{
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SelectTeam(match: widget.match,)));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: HexColor("#9ABAD1"),
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 120,
                    child: Column(
                      children: [
                        Text(widget.match.opp1_name, style: primaryTextStyle(16, Colors.white, FontWeight.bold),textAlign: TextAlign.center,),
                        Container(height: 5,),
                        Text(widget.match.opp1_odds.toString(), style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
                        Container(height: 3,),
                      ],
                    ),
                  ),
                  Text("VS", style: primaryTextStyle(18, HexColor("#0F324E"), FontWeight.bold),),
                  Container(
                    width: 120,
                    child: Column(
                      children: [
                        Text(widget.match.opp2_name, style: primaryTextStyle(16, Colors.white, FontWeight.bold),textAlign: TextAlign.center,),
                        Container(height: 5,),
                        Text(widget.match.opp2_odds.toString(), style: primaryTextStyle(14, Colors.white, FontWeight.bold),),
                        Container(height: 3,),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                color: HexColor("#0F324F"),
                height: 1,
              ),
            ],
          ),
        ),
      );
    }
  }
}
