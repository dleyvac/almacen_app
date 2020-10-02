
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Users extends StatefulWidget {
  Users({Key key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {

bool _isLoading = false;
List registers;

Future<bool> getData() async {
  try{
  this.setState(() {
    _isLoading = false;
  });
  final response = await http.get("${APIKey.apiURL}/users", 
      headers: Header.headers
    );

  var datauser = json.decode(response.body);
  var responseCode = datauser['code'];
  var responseMessage = datauser['message'];
  var responseData = datauser['data'];

  if(responseCode == 200){
    this.setState(() {
      _isLoading = true;
      registers = responseData;
      print(registers);
    });
    print(responseMessage);
  }
  if(responseCode == 400){
    this.setState(() {
      _isLoading = true;
    });
  }
  return true;
  }catch(e){
    print(e);
  }
  return true;
}

@override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new
     RefreshIndicator(
        color: Colors.orange,
        //Cuando se recarga la página se actualizarán los datos en la base de datos local y cargará de nuevo la pantalla
        onRefresh: () async {
          await getData();
        },
        child:
    Scaffold(
      appBar: AppBar(
        title: new Text("Usuarios", style: TextStyle(color: Colors.white),),
        backgroundColor: ColorsStyle.continoPrimary
        ),
      body:
       _isLoading?
        registers != null?
       
          Container(
            child:
            new ListView.builder(
              shrinkWrap: true,
                // physics: BouncingScrollPhysics(),
              itemCount: registers == null ? 0 : registers.length,
              itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(registers[index]["NOMBRE_PERSONA"]),
                subtitle: Text(registers[index]["USER_NAME"]),
                trailing: Icon(Icons.people_outline),
                onTap: () async {
                },
              );
              },
            ),
          ):RefreshIndicator(
        color: Colors.orange,
        //Cuando se recarga la página se actualizarán los datos en la base de datos local y cargará de nuevo la pantalla
        onRefresh: () async {
          await getData();
        },
        child:
          Container(child:
          Center(child:Text("No hay registros"))
          )
          ):Center(child: CircularProgressIndicator(),)
    )
    );
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Users(),
    );
  }
}