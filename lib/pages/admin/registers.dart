import 'package:almacen/main.dart';
import 'package:almacen/pages/admin/user.dart';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Registers extends StatefulWidget {
  Registers({Key key}) : super(key: key);

  @override
  _RegistersState createState() => _RegistersState();
}

class _RegistersState extends State<Registers> {

bool _isLoading = false;
List registers;

Future<bool> getData() async {
  try{
  this.setState(() {
    _isLoading = false;
  });
  final response = await http.get("${APIKey.apiURL}/registers", 
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
        title: new Text("Registros", style: TextStyle(color: Colors.white),),
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
                title: Text(registers[index]["EMAIL"]),
                subtitle: Text(registers[index]["NOMBRE"]),
                trailing: Icon(Icons.person_add),
                onTap: () async {
                  Navigator.push( 
                          context, new MaterialPageRoute(
                            builder: (context) => new User(
                              registerID: registers[index]["REGISTRO_ID"], 
                            )
                          ),
                        )
                        .then((value) async {
                          if(value == true){
                            // await getData();
                            try{
                            await Firebase.initializeApp().then((value) async => await getData());
                            RestartWidget.restartApp(context);
                            getData();
                            }catch(e){print(e);}
                            
                            // await Firebase.initializeApp();
                          }
                          if(value == null){
                            print("Regreso");
                          }
                        });
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

class RegistersPage extends StatelessWidget {
  const RegistersPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Registers(),
    );
  }
}