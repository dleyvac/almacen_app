import 'dart:convert';
import 'package:almacen/pages/splash.dart';
import 'package:almacen/pages/user/home.dart';
import 'package:almacen/pages/admin/home.dart';
import 'package:almacen/utils/header.dart';
import 'package:http/http.dart' as http;
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Selection extends StatefulWidget {
  Selection({Key key}) : super(key: key);
  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {

  int roleID = 0;
  int errorHandler = 0;
  
  Future<String> getData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;
    print(user.email);
    print("INICIO");
    var jsonObject = {
      "EMAIL": user.email
    };

    
    try{
      final response = await http.put("${APIKey.apiURL}/login", 
        headers: Header.headers,
        body: jsonEncode(jsonObject)
      );

      var datauser = json.decode(response.body);
      var responseCode = datauser['code'];
      var responseData = datauser['data'];
      print(responseCode);
      if(responseCode == 200){
        this.setState(() {
        roleID = int.parse(responseData[0]["ROL"]);
        print("ROL DEL USUARIO $roleID");
        });
      }
    }on Exception catch (exception) {
      if(exception.runtimeType.toString() == "SocketException"){
        this.setState(() {
          errorHandler = 400;
        });
        print("error de conexión");
      }else{
        print("otro error");
      }
    }
    return "Success!";
    }

  //   @override
  // void dispose() {
  //  super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    //Crea widget cuando se lanza un evento
    return StreamBuilder(
      //Evento en la instancia de autenticación
      stream: FirebaseAuth.instance.authStateChanges(),
      //Toma la información guardada en el snapshot de instancia de Firebase
      // builder: (context,AsyncSnapshot<FirebaseUser> snapshot) {
         builder: (context,AsyncSnapshot<User> snapshot) {
        //Si la conexión todavía no está cargado totalmente se mandará a una pantalla de Splash
        if(roleID == 1){
          return HomePage(selected: 0,);
        }
        //Si ya cargó la conexión pero no hay datos retornará a la pantalla de Login
        if(roleID == 2){
          return AdminHomePage(selected: 0,);
        }

        if(errorHandler == 400){
          //returnAt [1 = Select, 2 = Login]
          return ErrorPage(error: 400, returnAt: 1);
        }
        //Si ya cargó y si hay datos guardados en la instancia de autenticación, retornará a la página principal
        return SplashPage();
      },
    );
  }
}