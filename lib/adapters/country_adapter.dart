import 'package:experience/models/country.dart';
import 'package:experience/utils/widgets.dart';
import 'package:flutter/material.dart';

class CountryAdapter extends StatefulWidget {

  List<String> list;
  Country country;
  CountryAdapter({this.list, this.country});

  @override
  State<CountryAdapter> createState() => _CountryAdapterState();
}

class _CountryAdapterState extends State<CountryAdapter> {

  @override
  Widget build(BuildContext context) {
    bool is_selected = false;
    if(widget.list.contains(widget.country)){
      is_selected = true;
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: is_selected,
            onChanged: (value){
              if(value){
                widget.list.removeWhere((element){
                  if(element == widget.country.name){
                    return true;
                  }
                  return false;
                });
              }
            }
          ),
          Container(width: 10,),
          Text(widget.country.name, style: primaryTextStyle(16, Colors.black, FontWeight.normal),)
        ],
      ),
    );
  }
}
