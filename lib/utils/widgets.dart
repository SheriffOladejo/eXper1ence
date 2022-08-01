import 'dart:async';

import 'package:experience/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loadingPage() {
  return LoadingPage();
}

class LoadingPage extends StatefulWidget {

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  Timer _timer;
  int _start = 10;

  final Image image_10 = Image.asset("assets/images/Football_10.png", width: 40, height: 40,);
  final Image image_20 = Image.asset("assets/images/Football_20.png", width: 40, height: 40,);
  final Image image_30 = Image.asset("assets/images/Football_30.png", width: 40, height: 40,);
  final Image image_40 = Image.asset("assets/images/Football_40.png", width: 40, height: 40,);
  final Image image_50 = Image.asset("assets/images/Football_50.png", width: 40, height: 40,);
  final Image image_60 = Image.asset("assets/images/Football_60.png", width: 40, height: 40,);
  final Image image_70 = Image.asset("assets/images/Football_70.png", width: 40, height: 40,);
  final Image image_80 = Image.asset("assets/images/Football_80.png", width: 40, height: 40,);
  final Image image_90 = Image.asset("assets/images/Football_90.png", width: 40, height: 40,);
  final Image image_100 = Image.asset("assets/images/Football_100.png", width: 40, height: 40,);

  Image image = Image.asset("assets/images/Football.png", width: 40, height: 40,);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor("#0F324F"),
      child: Center(
        child: Stack(
          children: [
            Center(
              child: image
            ),
            const SpinKitRing(
              duration: Duration(milliseconds: 1600),
              size: 70,
              color: Colors.greenAccent
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  @override
  void initState(){
    //startTimer();
    super.initState();
  }

  void startTimer() {
    const half_sec = Duration(seconds: 1);
    _timer = Timer.periodic(
      half_sec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _start = 10;
            startTimer();
          });
        } else {
          setState(() {
            _start--;
            if(_start == 9){
              image = image_10;
            }
            else if(_start == 8){
              image = image_20;
            }
            else if(_start == 7){
              image = image_30;
            }
            else if(_start == 6){
              image = image_40;
            }
            else if(_start == 5){
              image = image_50;
            }
            else if(_start == 4){
              image = image_60;
            }
            else if(_start == 3){
              image = image_70;
            }
            else if(_start == 2){
              image = image_80;
            }
            else if(_start == 1){
              image = image_90;
            }
            else if(_start == 0){
              image = image_100;
            }
          });
        }
      },
    );
  }

}


  Widget noItem(String text, BuildContext context){
  return Container(
    margin: const EdgeInsets.all(15),
    alignment: Alignment.center,
    width: 370,
    height: MediaQuery.of(context).size.height,
    child: Center(
      child: Text(
        text,
        style: primaryTextStyle(16, Colors.white, FontWeight.normal),
      ),
    ),
  );
}

  TextStyle primaryTextStyle(double font_size, Color color, FontWeight weight){
  return TextStyle(
      fontWeight: weight,
      fontSize: font_size,
      color: color,
      fontFamily: 'aventa_regular'
  );
}

  TextStyle secondaryTextStyle(double font_size, Color color){
    return TextStyle(
      fontSize: font_size,
      color: color,
      fontFamily: 'aventa_light'
    );
  }





