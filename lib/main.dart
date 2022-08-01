import 'package:http/http.dart';
import 'dart:io';
import 'package:experience/models/country.dart';
import 'package:experience/utils/constants.dart';
import 'package:experience/utils/hex_color.dart';
import 'package:experience/views/profile.dart';
import 'package:experience/views/select_country.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  DbHelper db_helper = DbHelper();
  Widget home_screen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(backgroundColor: HexColor(Constants.background_color)),
      home: home_screen,
    );
  }

  Future<void> init() async {
    List<Country> country_list = await db_helper.getCountries();
    print("main.init country_list is ${country_list.length}");
    if(country_list.isEmpty){
      await db_helper.deleteCountries();
      await db_helper.deleteSports();
      home_screen = SelectCountryScreen();
    }
    else{
      home_screen = ProfileScreen();
    }
    setState(() {

    });
  }

  @override
  void initState(){
    init();
    super.initState();
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}