import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:almacen/utils/firebase_auth.dart';
import 'package:almacen/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:almacen/pages/forget.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  String message = "";
  String messageRegister = "";

  TextEditingController mailLogin = TextEditingController();
  TextEditingController pwdLogin = TextEditingController();

  TextEditingController nameRegister = TextEditingController();
  TextEditingController mailRegister = TextEditingController();

  TextStyle title = new TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.black
    );
    TextStyle subtitle = new TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black
    );
    TextStyle alert = new TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: ColorsStyle.continoPrimary
    );
    TextStyle button = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white
    );
    TextStyle forget = new TextStyle(
      fontWeight: FontWeight.bold,
      color: ColorsStyle.continoPrimary
    );
    bool _isLoading = false;
    List organizations;

  Future _login() async {
    var jsonObject = {
      "USERNAME": mailLogin.text.trim().toLowerCase(),
      "PASSWORD": pwdLogin.text.trim().toLowerCase()
    };
    final response = await http.post("${APIKey.apiURL}/login", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );

    var datauser = json.decode(response.body);
    var responseCode = datauser['code'];
    var responseMessage = datauser['message'];
    var responseData = datauser['data'];


    if(responseCode == 400){
      this.setState(() {
        message = responseMessage;
      });
    }

    if(responseCode == 200){
      this.setState(() {
        message = responseMessage;
      });
      var responseEmail = responseData[0]["EMAIL"];
      // print(responseEmail);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setInt('USER_ID', int.parse(responseData[0]["USER_ID"]));
      preferences.setInt('ORGANIZATION_ID', int.parse(responseData[0]["ORGANIZATION_ID"]));
      preferences.setInt('SUBINVENTORY_ID', int.parse(responseData[0]["SUBINVENTORY_ID"]));
      bool res = await AuthProvider().signInWithEmail(responseEmail, pwdLogin.text);
      if(res){
      //   print(res);
      // // await DBProvider.db.initDB();
      //   print("Entró");
      }
    }
    return "sucess";
  }

  Future<bool> emailValidation(String email)async{
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }
  Future<bool> nameValidation(String name)async{
    List validName = [];
    List getName = name.split(" ");
    for(var index = 0; index < getName.length; index++){
      validName.add(getName[index]);
    }
    print(validName);
    if(validName.length>1){
    return true;
    }else{
      return false;
    }
  }

  Future<bool> validateRegister()async{
    List orgs = [];
    for(var index = 0; index < organizations.length; index ++){
      if(organizations[index]["VALUE"] == true){
        orgs.add(organizations[index]["ORGANIZATION_CODE"]);
      }
    }
    print(orgs);
    if(orgs.isEmpty){
      this.setState(() {
          messageRegister = "Selecciona organizaciones";
      });
      return false;
    }else{
      if(nameRegister.text.trim().isEmpty || mailRegister.text.trim().isEmpty){
        this.setState(() {
          messageRegister = "Llene todos los datos";
        });
        return false;
      }else{
        if(await emailValidation(mailRegister.text.trim()) == false || await nameValidation(nameRegister.text) == false){
          if(await emailValidation(mailRegister.text.trim()) == false){
            this.setState(() {
            messageRegister = "Correo no válido";
            });
            return false;
          }
          if(await nameValidation(nameRegister.text) == false){
            this.setState(() {
            messageRegister = "Ingrese nombre completo";
            });
            return false;
          }
          return false;
        }else{
          this.setState(() {
            messageRegister = "";
          });
          return true;
        }
      }
    }
  }

  Future<List<dynamic>> getFinalOrg()async{
    List orgs = [];
    for(var index = 0; index < organizations.length; index ++){
      if(organizations[index]["VALUE"] == true){
        orgs.add(organizations[index]["ORGANIZATION_ID"]);
      }
    }
    return orgs;
  }

  Future _register() async {
    if(await validateRegister()){
      List correctOrg = await getFinalOrg();
      var jsonObject = {
        "NAME": nameRegister.text,
        "EMAIL": mailRegister.text.trim().toLowerCase(),
        "ORGANIZATION": correctOrg,
      };
      print(jsonObject);
      print(jsonEncode(jsonObject));

      final response = await http.post("${APIKey.apiURL}/registers", 
        headers: Header.headers,
        body: jsonEncode(jsonObject)
      );

      var datauser = json.decode(response.body);
      var responseCode = datauser['code'];
      var responseMessage = datauser['message'];

      if(responseCode == 400){
        this.setState(() {
          messageRegister = responseMessage;
        });
      }

      if(responseCode == 200){
        this.setState((){
          messageRegister = responseMessage;
          nameRegister.clear();
          mailRegister.clear();
          clearOrganizations();
        });
      }
      return "sucess";
    }else{
      print("Validacion incorrecta");
    }
  }

  void clearOrganizations(){
    for(var index = 0; index < organizations.length; index ++){
      this.setState(() {
      organizations[index]["VALUE"] = false;
      });
    }
  }

  Future<bool>getOrganizations() async{

    final response = await http.get("${APIKey.apiURL}/organizations", 
      headers: Header.headers
    );
    var datauser = json.decode(response.body);
    var responseCode = datauser['code'];
    var responseData = datauser['data'];

    if(responseCode == 200){
      if(this.mounted) { 
        this.setState((){
          organizations = responseData;
        });
        for(var index = 0; index < organizations.length; index ++){
          this.setState(() {
            organizations[index]["VALUE"] = false;
          });
        }
        this.setState(() {
          _isLoading = true;
        });
      }
    }  
      return true;
  }

  Future<bool>setOrganization() async {
  // await getOrganizations();  
  await showDialog(
    context: this.context,
    builder: (context){
      return StatefulBuilder( // StatefulBuilder
      builder: (context, setState) {
        return AlertDialog(
        title: new Text("Selecciona organización"),
        content:
        _isLoading?
        new Scrollbar(
          child: 
          new ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: organizations == null ? 0 : organizations.length,
            itemBuilder: (BuildContext context, int index) {
            return CheckboxListTile(
              title: Text(organizations[index]["ORGANIZATION_NAME"]), 
              subtitle: Text(organizations[index]["ORGANIZATION_CODE"]), 
              value: organizations[index]["VALUE"], 
              onChanged: (value) {
                print(value);
                if(this.mounted){
                  setState((){
                    this.organizations[index]["VALUE"] = value;
                  });
                }
              },
            );
          },
          )
        ):Text("No hay datos"),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
        ],
      );
      }
      );
    }
  );
  return true;
}

  @override
  void initState(){
    super.initState();
    this.getOrganizations();
  }

  @override
  Widget build(BuildContext context) {

    return  new DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            new TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.orange,
              unselectedLabelColor: Colors.grey[400],
              tabs: [
                new Tab( text: "Iniciar Sesión",),
                new Tab(text: "Registrarse"),
              ],
            ),
          ],
        ),
      ),
        backgroundColor: Colors.white,
        body: new TabBarView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            new Container(
              color: Colors.white,
              child: 
              Padding(
              padding: EdgeInsets.all(30),
              child:
              new Center(
                //Vista de la información básica del equipo, cada ListTile muestra el contenido de la información
                child: new ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60.0,
                    child: Image.asset('assets/images/icon.png'),
                  ),
                  ),
                  Center(child: Text("Bienvenido", style: title,)),
                  Center(child: Text("de nuevo", style: subtitle,)),
                  SizedBox(height: 20),
                  Center(child: Text(message, style: alert)),
                  TextField(controller: mailLogin, decoration: InputDecoration(hintText: "Correo electrónico", prefixIcon: Icon(Icons.email)),),
                  SizedBox(height: 10),
                  TextField(obscureText: true, controller: pwdLogin, decoration: InputDecoration(hintText: "Contraseña", prefixIcon: Icon(Icons.lock)),),
                  SizedBox(height: 10),
                  RaisedButton(
                    color: ColorsStyle.continoPrimary,
                    child: Text("Inicia Sesión", style: button),
                    onPressed: ()async{
                      _login();
                    }
                  ),
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    child: Text("Olvidé mi contraseña", style: forget,),
                    onPressed: ()async{
                      Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => Forget()
                     )
                    );
                    },
                  )
                  ]
                ),
              ),
            ),
            ),
            new Container(
              color: Colors.white,
              child: 
              Padding(
              padding: EdgeInsets.all(30),
              child:
              new Center(
                //Vista de la información básica del equipo, cada ListTile muestra el contenido de la información
                child: new ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60.0,
                    child: Image.asset('assets/images/icon.png'),
                  ),
                  ),
                  Center(child: Text("Registrate", style: title,)),
                  Center(child: Text("llena tus datos", style: subtitle,)),
                  SizedBox(height: 20),
                  Center(child: Text(messageRegister, style: alert)),
                  TextField(controller: nameRegister ,decoration: InputDecoration(hintText: "Nombre Completo", prefixIcon: Icon(Icons.person)),),
                  SizedBox(height: 10),
                  TextField(controller: mailRegister ,decoration: InputDecoration(hintText: "Correo electrónico", prefixIcon: Icon(Icons.email)),),
                  SizedBox(height: 10),
                  RaisedButton(
                    color: Colors.orange,
                    child: Text("Selecciona tu organización", style: button,),
                    onPressed: () async{
                      await setOrganization();
                    },
                  ),
                  RaisedButton(
                    color: ColorsStyle.continoPrimary,
                    child: Text("Registrarse", style: button,),
                    onPressed: ()async{
                      _register();
                    },
                  ),
                  ]
                ),
              ),
            ),
            ),
          ]
        ),
      ),
    );
  }

}
