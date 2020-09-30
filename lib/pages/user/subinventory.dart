import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class SubinventoryPage extends StatefulWidget {
  SubinventoryPage({Key key}) : super(key: key);

  @override
  _SubinventoryPageState createState() => _SubinventoryPageState();
}

class _SubinventoryPageState extends State<SubinventoryPage> {

  bool _isLoading = false;
  List subinventory;
  int _isSelected = 1;

  Future<String> getData() async {

    print("USER_ID");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var orgID = preferences.get('ORGANIZATION_ID');
    var subID = preferences.get('SUBINVENTORY_ID');

    final response = await http.get("${APIKey.apiURL}/subinventory/$orgID", 
      headers: Header.headers
    );

    var datauser = json.decode(response.body);
    var responseData = datauser['data'];
    print(responseData);

    this.setState(() {
      subinventory = responseData;
      _isLoading = true;
      _isSelected = subID;
    });

  
  return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subinventarios"),
        backgroundColor: ColorsStyle.continoPrimary,
        ),
      body:
     Container(
       child:
      _isLoading? 
       Column(
         children: [
      new ListView.builder(
        shrinkWrap: true,
         physics: BouncingScrollPhysics(),
        itemCount: subinventory == null ? 0 : subinventory.length,
        itemBuilder: (BuildContext context, int index) {
        return new RadioListTile(
          activeColor: ColorsStyle.continoSecondary,
          value: int.parse(subinventory[index]["SUBINVENTORY_ID"]),
          groupValue: _isSelected,
          title: Text(subinventory[index]["NAME"]),
          onChanged: (value) {
            print(value);
            this.setState(() {
              _isSelected = value;
            });
          }
          );
        
       },
      ),
      Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                SizedBox(
                width: double.infinity,
                child:
                RaisedButton(
                  color: ColorsStyle.continoSecondary,
                  child: Text("Seleccionar Organización", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  onPressed: () async {
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      preferences.setInt('SUBINVENTORY_ID',_isSelected);
                      return Navigator.pop(context, "success");
                  },
                ),
                )
              ),
            ),
    ],):Center(child: CircularProgressIndicator(),),
    )
    );
  }
}

class Subinventory extends StatelessWidget {
  const Subinventory({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SubinventoryPage(),
    );
  }
}