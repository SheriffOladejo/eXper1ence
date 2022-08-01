import 'dart:convert';
import 'package:experience/adapters/country_adapter.dart';
import 'package:experience/models/country.dart';
import 'package:experience/utils/db_helper.dart';
import 'package:experience/utils/widgets.dart';
import 'package:experience/views/select_sport.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/hex_color.dart';
import 'package:http/http.dart' as http;

class SelectCountryScreen extends StatefulWidget {

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {

  DbHelper db_helper = DbHelper();
  
  List<Country> country_list = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
  List<Country> selected_countries = [];
  String selected_country = "World";

  bool is_loading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: is_loading ? null : FloatingActionButton(
        backgroundColor: HexColor("#0F324F"),
        onPressed: () async {
          if(selected_countries.isEmpty){
            selected_countries.add(country_list[3]);
            await saveCountries();
          }
          else if(selected_countries.length == country_list.length-1){
            selected_countries = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
            await saveCountries();
          }
          else{
            bool all_countries = false;
            selected_countries.where((element){
              if(element.name == "World"){
                all_countries = true;
              }
              return false;
            });
            if(all_countries){
              selected_countries.clear();
              selected_countries[0] = Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1");
              await saveCountries();
            }
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectSportScreen()));
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
                      Text("Choose countries", style: primaryTextStyle(16, Colors.white, FontWeight.normal),),
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
        title: Text("Select countries", style: primaryTextStyle(16, Colors.white, FontWeight.bold),),
        backgroundColor: HexColor("#0F324F"),
      ),
    );
  }

  Future<void> getCountries() async {
    setState(() {
      is_loading = true;
    });
    country_list = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
    var url = Uri.https(Constants.api_url, '/v1/countries/0/Line/en');
    var response = await http.get(url, headers: {"Package":"KlUet6y43te8Jg6G9bkDxN36f9X9ZiTkm"});
    if(response.statusCode == 200){
      //print("select_country.getCountries response is ${response.body.toString()}");
      var json = jsonDecode(response.body.toString());
      List<dynamic> list = json["body"];

      for(var i = 0; i<list.length; i++){
        var id = list[i]["id"];
        var name = list[i]["name"];
        var name_en = list[i]["name_en"];
        var sport_id = list[i]["sport_id"];

        Country c;
        try{
          c = Country(
            id: int.parse(id.toString()),
            name: name,
            name_en: name_en,
            sport_id: sport_id.toString(),
            is_selected: false,
          );
        }
        catch(e){

        }

        Country temp_country;
        country_list.removeWhere((element){
          if(element.id == id){
            var temp_sport_id = element.sport_id;
            temp_sport_id += " $sport_id";
            element.sport_id = temp_sport_id;
            temp_country = element;
          }
          return false;
        });
        if(temp_country == null && c!= null){
          if(c.name != "World"){
            country_list.add(c);
          }
        }
        else{

        }
        country_list.sort((a,b){
          if(a.name != "World" && b.name != "World"){
            return a.name.compareTo(b.name);
          }
          return 0;
        });

      }

      List<Country> temp_list = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
      for(var i = 0; i<country_list.length; i++){
        if(country_list[i].name != "World"){
          temp_list.add(country_list[i]);
        }
      }
      //print("select_country.getCountries temp_list length is ${temp_list.length}");
      country_list = [];
      country_list.addAll(temp_list);

      setState(() {
        is_loading = false;
      });
    }
    else{
      setState(() {
        is_loading = false;
      });
      print("select_country.getCountries: status code is not 200");
    }

  }
  
  Future<void> init() async {
    await getCountries();
  }
  
  @override
  void initState(){
    init();
    super.initState();
  }
  
  void onCountrySelected(dynamic value){
    selected_country = value.toString();
    setState(() {

    });
  }

  Future<void> saveCountries() async {
    print("select_country.saveCountries selected country list length: ${selected_countries.length}");
    //print("select_country.saveCountries country list length: ${country_list.length}");
    await db_helper.deleteCountries();
    await db_helper.saveCountries(selected_countries);
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: HexColor("#0F324F"),
      content: SelectCountryDialog(
        country_list: country_list,
        selected_countries: selected_countries,
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

class SelectCountryDialog extends StatefulWidget {

  List<Country> country_list = [];
  List<Country> selected_countries = [];

  SelectCountryDialog({
    this.country_list,
    this.selected_countries,
  });

  @override
  State<SelectCountryDialog> createState() => _SelectCountryDialogState();
}

class _SelectCountryDialogState extends State<SelectCountryDialog> {

  bool select_all = false;

  DbHelper db_helper = DbHelper();

  bool is_loading = false;

  Widget countryItem(Country country, int index) {
    return ListTile(
      title: Text(
        country.name,
        style: primaryTextStyle(15, Colors.white, FontWeight.normal),
      ),
      trailing: country.is_selected
          ? const Icon(
        Icons.check_circle,
        color: Colors.blue,
      )
          : const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      onTap: () {
        if(country.name == "World" && widget.selected_countries.length < widget.country_list.length-1){
          widget.country_list[0].is_selected = true;
          widget.selected_countries.clear();
          for(var i = 1; i<widget.country_list.length; i++){
            widget.country_list[i].is_selected = true;
            widget.selected_countries.add(widget.country_list[i]);
          }
        }
        else if(country.name == "World" && widget.selected_countries.length == widget.country_list.length-1){
          widget.country_list[0].is_selected = false;
          widget.selected_countries.clear();
          for(var i = 1; i<widget.country_list.length; i++){
            widget.country_list[i].is_selected = false;
          }
        }
        setState(() {
          if(country.name != "World"){
            widget.country_list[index].is_selected = !widget.country_list[index].is_selected;
            if (widget.country_list[index].is_selected == true) {
              widget.selected_countries.add(country);
            } else if (widget.country_list[index].is_selected == false) {
              widget.selected_countries
                  .removeWhere((element) => element.name == widget.country_list[index].name);
            }
          }
        });
        if(widget.selected_countries.length == widget.country_list.length-1){
          setState(() {
            widget.country_list[0].is_selected = true;
          });
        }
        else{
          setState(() {
            widget.country_list[0].is_selected = false;
          });
        }
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
    //country_list = await db_helper.getUsersSQLite();

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
                itemCount: widget.country_list.length,
                itemBuilder: (BuildContext context, int index) {
                  Country c = widget.country_list[index];
                  return countryItem(c,index);
                }),
            ),
            widget.selected_countries.isNotEmpty ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 10,
              ),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    "Save (${widget.selected_countries.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    if(widget.selected_countries.isEmpty){
                      widget.selected_countries = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
                    }
                    else if(widget.selected_countries.length == widget.country_list.length-1){
                      widget.selected_countries = [Country(name_en: "World", name: "World", is_selected: false, id: 225, sport_id: "1")];
                    }
                    await db_helper.deleteCountries();
                    print("select_country.build selected_sports ${widget.selected_countries.length}");
                    await db_helper.saveCountries(widget.selected_countries);
                    Navigator.pop(context);
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

