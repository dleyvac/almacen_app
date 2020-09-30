import 'dart:async';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/firebase_auth.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Módulo que muestra la información de cada equipo, requiere un id_articulo para llamarlo
class UserPage extends StatefulWidget {
  UserPage({Key key, this.registerID}) : super(key: key, );
  final String registerID;

  @override
  _UserPageState createState() => _UserPageState(registerID);
}

class _UserPageState extends State<UserPage> {
  String registerID;
  List user;
  List organizations;
  String messageRegister = "";
  String message = "";
  bool _isLoading = false;
  String username = "";
  String messageName = "";
  String messageEmail = "";
  String messageUser = "";
  TextStyle button = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white
    );
  TextStyle alert = new TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: ColorsStyle.continoPrimary
  );

  _UserPageState(String registerID) {
    this.registerID = registerID;
  }

//Carga los datos requeridos por el id_articulo
Future<bool> getData() async {
  final responseUser = await http.get("${APIKey.apiURL}/registers/$registerID", 
  headers: Header.headers
  );
  var dataUser = json.decode(responseUser.body);

  if(dataUser["code"] == 200){
    this.setState(() {
      user = dataUser["data"];
    });
    await getOrganizations(dataUser["data"]);
    await getUser(dataUser["data"]);
  }
  return true;
}

Future<bool>getUser(data)async{
  String usuario = "";
  String name = data[0]["NOMBRE"];
  List getName = name.toString().split(" ");
  print(getName);
  print(getName.length);
    for(var index = 0; index < getName.length; index++){
      if(getName[index].length >= 3){
        String part = (getName[index].toString().replaceAll(new RegExp(r'[^\w\s]+'),'')).toLowerCase();
        usuario = usuario + (part.substring(0,3));
      }
    }
  this.setState(() {
    username = usuario;
  });
  return true;
}

Future<bool>deleteRegister()async{
  var registerID = user[0]["REGISTRO_ID"];
  var response = await http.delete("${APIKey.apiURL}/registers/$registerID", 
    headers: Header.headers,
  );
  var deleted = json.decode(response.body);
  var delCode = deleted["code"];
  if(delCode == 200){
    print("Borrar");
    return true;
  }
  else{
    print("No borrado");
    return false;  
  }
  // return true;
}

Future<bool>getOrganizations(data)async{
  final response = await http.get("${APIKey.apiURL}/organizations", 
      headers: Header.headers
  );
  var datauser = json.decode(response.body);
  var responseCode = datauser['code'];
  var responseData = datauser['data'];

  if(responseCode == 200){
    this.setState((){
        organizations = responseData;
    });

    var orgs = jsonDecode(data[0]["ORGANIZACIONES"]);
    for(var index = 0; index < organizations.length; index ++){
      this.setState(() {
        organizations[index]["VALUE"] = false;
      });
    }
    
    for(var index = 0; index < organizations.length; index ++){
      for(var i = 0; i < orgs.length; i ++){
        if(orgs[i] == organizations[index]["ORGANIZATION_ID"]){
          print(organizations[index]);
          this.setState(() {
            organizations[index]["VALUE"] = true;
          });
        }
      }
    }
    this.setState(() {
      _isLoading = true;
    });
  }
  return true;
}

  Future<bool> emailValidation(String email)async{
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

  Future<bool> nameValidation(String name)async{
    List validName = [];
    print(name);
    List getName = name.toString().split(" ");
    for(var index = 0; index < getName.length; index++){
      validName.add(getName[index]);
    }
    // print(validName);
    if(validName.length>1){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> validateRegister(String mailRegister, String nameRegister)async{
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
      if(nameRegister.toString().isEmpty || mailRegister.toString().isEmpty){
        this.setState(() {
          messageRegister = "Llene todos los datos";
        });
        return false;
      }else{
        if(await emailValidation(mailRegister) == false || await nameValidation(nameRegister) == false){
          if(await emailValidation(mailRegister) == false){
            this.setState(() {
            messageRegister = "Correo no válido";
            });
            return false;
          }
          if(await nameValidation(nameRegister) == false){
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

Future<bool>getNameByText(String dataInput) async {
  var _data = TextEditingController(text: dataInput.toString());
  showDialog(
    context: context,
    builder: (BuildContext context){
      return StatefulBuilder( // StatefulBuilder
      builder: (context, setState) {
      return new AlertDialog(
        title: new Text("Cambiar nombre"),
        content: new ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: _data,
                    // autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Nombre', hintText: "Ingrese nombre completo"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child:
            Center(child: Text(messageName,style: alert,),)
            )
          ],),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Cancelar'),
            onPressed: () {
              setState(() {
                  this.messageName = "";
                });
              Navigator.pop(context);
            }
          ),
          new FlatButton(
            child: const Text('Editar'),
            onPressed: () async {
              if(await nameValidation(_data.text)){
                this.setState(() {
                  user[0]["NOMBRE"] = _data.text;
                });
                setState(() {
                  this.messageName = "";
                });
                await getUser(user);
                Navigator.pop(context);
                return true;
              }else{
                setState(() {
                  this.messageName = "Nombre no válido";
                });
                return false;
              }
            }
          )
        ],
      );
      }
      );
    }
  );
  return true;
}
Future<bool>getEmailByText(String dataInput) async {
  var _data = TextEditingController(text: dataInput.toString());
  showDialog(
    context: context,
    builder: (BuildContext context){
      return StatefulBuilder( // StatefulBuilder
      builder: (context, setState) {
      return new AlertDialog(
        title: new Text("Cambiar Correo"),
        content: new ListView(
          shrinkWrap: true,
          children: [
        Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: _data,
                // autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Correo', hintText: "Ingrese correo"),
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child:
        Center(child: Text(messageEmail,style: alert,),)
        )
        ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Cancelar'),
            onPressed: () {
              setState(() {
                  this.messageEmail = "";
                });
              Navigator.pop(context);
            }
          ),
          new FlatButton(
            child: const Text('Editar'),
            onPressed: () async {
              if(await emailValidation(_data.text)){
                this.setState(() {
                  user[0]["EMAIL"] = _data.text;
                });
                setState(() {
                  this.messageEmail = "";
                });
                Navigator.pop(context);
                return true;
              }else{
                setState(() {
                  this.messageEmail = "Correo no válido";
                });
                return false;
              }
            }
          )
        ],
      );
      }
      );
    }
  );
  return true;
}
Future<bool>getUserByText(String dataInput) async {
  var _data = TextEditingController(text: dataInput.toString());
  showDialog(
    context: context,
    builder: (BuildContext context){
      return new AlertDialog(
        title: new Text("Cambiar nombre de usuario"),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: _data,
                // autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Usuario', hintText: "Ingrese nombre de usuario"),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
          new FlatButton(
            child: const Text('Editar'),
            onPressed: () async {
              this.setState(() {
                username = _data.text;
              });
              Navigator.pop(context);
              return true;
            }
          )
        ],
      );
    }
  );
  return true;
}

//Cuando se inicie el módulo activa la función geData()
@override
void initState(){
  super.initState();
  this.getData();
}


  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: ColorsStyle.continoPrimary,
        title: new Text("Registrar Usuario"),
      ),
      body: 
      _isLoading?
        Container(
        child:
        ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("Nombre de la persona"),
              subtitle: Text(user[0]["NOMBRE"]),
              onTap: () async{
                getNameByText(user[0]["NOMBRE"]);
              },
            ),
            ListTile(
              title: Text("Correo de la persona"),
              subtitle: Text(user[0]["EMAIL"]),
              onTap: () async{
                getEmailByText(user[0]["EMAIL"]);
              },
            ),
            ListTile(
              title: Text("Nombre de usuario"),
              subtitle: Text(username),
              onTap: () async{
                getUserByText(username);
              },
            ),
            ExpansionTile(
              title: Text("Organización"),
              subtitle: Text("Selecciona la organización"),
              children: [
            ListView.builder(
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
            ),
            ]),
            Center(child: Text(message)),
            RaisedButton(
              color: Colors.blue,
              child: Text("Crear usuario",style: button), 
              onPressed: ()async{
                if(await validateRegister(user[0]["EMAIL"], user[0]["NOMBRE"])){
                  var jsonObject = {
                    "NAME": user[0]["NOMBRE"],
                    "USERNAME": username,
                    "EMAIL": user[0]["EMAIL"],
                    "ROL": 1,
                  };
                  print(jsonObject);

                  final response = await http.post("${APIKey.apiURL}/users", 
                    headers: Header.headers,
                    body: jsonEncode(jsonObject)
                  );

                  var datauser = json.decode(response.body);
                  var responseCode = datauser['code'];
                  var responseMsg = datauser['message'];

                  if(responseCode == 200){
                    int flag = 0;
                    var userID = datauser['data'];
                    for(var index = 0; index < organizations.length; index ++){
                      if(organizations[index]["VALUE"] == true){
                        var jsonObject = {
                          "USER_ID": userID[0]["USER_ID"],
                          "ORGANIZATION_ID": organizations[index]["ORGANIZATION_ID"],
                        };

                        print(jsonObject);

                        final response = await http.post("${APIKey.apiURL}/acceso", 
                          headers: Header.headers,
                          body: jsonEncode(jsonObject)
                        );
                        var dataAccess = json.decode(response.body);
                        print(dataAccess);
                        var responseCode = dataAccess['code'];
                        if(responseCode == 200){
                          // flag
                        }
                        if(responseCode == 400){
                          flag++;
                        }
                      }
                    }
                    if(flag == 0){
                      await AuthProvider.createUser(user[0]["EMAIL"]);
                      bool res = await deleteRegister();
                      if(res){
                      Navigator.pop(context, true);
                      }
                    }
                  }
                  if(responseCode == 400){
                    this.setState(() {
                      message = responseMsg;
                    });
                  }
                  
                }else{
                  print(messageRegister);
                }
              }
            ),
            RaisedButton(
              color: Colors.redAccent,
              child: Text("Borrar registro",style: button), 
              onPressed: ()async{
                bool res = await deleteRegister();
                if(res){
                Navigator.pop(context, true);
                }
              }
            ),
          ],
        )
      ): Center(child:CircularProgressIndicator())
    );
  }
}

class User extends StatelessWidget {
  User({Key key, this.registerID}) : super(key: key);
  final String registerID;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: UserPage(
        registerID: registerID,
        ),
    );
  }
}

