import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class OrganizationsPage extends StatefulWidget {
  OrganizationsPage({Key key}) : super(key: key);

  @override
  _OrganizationsPageState createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {

  bool _isLoading = false;
  List organizations;
  int _isSelected = 1;

  Future<String> getData() async {

    print("USER_ID");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var userID = preferences.get('USER_ID');
    var orgID = preferences.get('ORGANIZATION_ID');

    final response = await http.get("${APIKey.apiURL}/organizations/$userID", 
      headers: Header.headers
    );

    var datauser = json.decode(response.body);
    var responseData = datauser['data'];
    print(responseData);

    this.setState(() {
      organizations = responseData;
      _isLoading = true;
      _isSelected = orgID;
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
        title: Text("Organizaciones"),
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
        itemCount: organizations == null ? 0 : organizations.length,
        itemBuilder: (BuildContext context, int index) {
        return new RadioListTile(
          activeColor: ColorsStyle.continoSecondary,
          value: int.parse(organizations[index]["ORGANIZATION_ID"]),
          groupValue: _isSelected,
          title: Text(organizations[index]["ORGANIZATION_NAME"]),
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
                    final response = await http.get("${APIKey.apiURL}/subinventory/$_isSelected", 
                      headers: Header.headers
                    );
                    var datauser = json.decode(response.body);
                    var responseCode = datauser['code'];
                    var responseMsg = datauser['message'];
                    var responseData = datauser['data'];
                    if(responseCode == 200){
                      print(responseData);
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      preferences.setInt('ORGANIZATION_ID', _isSelected);
                      preferences.setInt('SUBINVENTORY_ID',int.parse(responseData[0]["SUBINVENTORY_ID"]));
                      return Navigator.pop(context, "success");
                    }
                    if(responseCode == 400){
                      print(responseMsg);
                      return Navigator.pop(context, "failed");
                    }
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

class Organizations extends StatelessWidget {
  const Organizations({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OrganizationsPage(),
    );
  }
}