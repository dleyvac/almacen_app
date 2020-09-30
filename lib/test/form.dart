import 'package:almacen/utils/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:dialisis/utils/providers/db_provider.dart';
import 'package:almacen/utils/firebase_auth.dart';
import 'package:almacen/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';



class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> with SingleTickerProviderStateMixin {
  String message = "";
  bool erroResponse = true;

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
      color: Colors.blueAccent
    );
    TextStyle button = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white
    );
    TextStyle forget = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue
    );

  @override
  void initState() {
    super.initState();
  }

  Future _register() async {
    var jsonObject = {
      "NAME": nameRegister.text,
      "EMAIL": mailRegister.text
    };

    

    final response = await http.post("${APIKey.apiURL}/users", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );

    var datauser = json.decode(response.body);
    var responseCode = datauser['code'];
    var responseMessage = datauser['message'];

    // bool res = await AuthProvider().signInWithEmail(mailLogin.text, pwdLogin.text);
    // if(res){
    // // await DBProvider.db.initDB();
    // print("Entró");
    // }

    if(responseCode == 400){
      this.setState(() {
        message = responseMessage;
      });
      print("No hay datos");
    }

    if(responseCode == 200){
      this.setState(() {
        message = responseMessage;
      });
      // bool res = await AuthProvider.createUser(mailRegister.text);
      await AuthProvider.createUser(mailRegister.text);
      // if(res){
      // print("Entró");
      // }
    }
    return "sucess";
  }

  @override
  Widget build(BuildContext context) {

    return  new DefaultTabController(
      length: 1,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            new TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              tabs: [
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
              padding: EdgeInsets.all(50),
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
                  Text("Registrate", style: title,),
                  Text("llena tus datos", style: subtitle,),
                  SizedBox(height: 20),
                  TextField(controller: nameRegister ,decoration: InputDecoration(hintText: "Nombre Completo", prefixIcon: Icon(Icons.person)),),
                  SizedBox(height: 10),
                  TextField(controller: mailRegister ,decoration: InputDecoration(hintText: "Correo electrónico", prefixIcon: Icon(Icons.email)),),
                  SizedBox(height: 10),
                  RaisedButton(
                    color: Colors.blue[400],
                    child: Text("Registrarse", style: button,),
                    onPressed: ()async{
                      _register();
                    },
                  ),
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    child: Text("FAQ", style: forget,),
                    onPressed: ()async{
                    },
                  )
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
  
  Future<bool> validateAll() async{
    if(await validateEmpty()){
      return true;
    }else{
      return false;
    }
  }


  Future<bool> validateEmpty() async{
    String nameText = nameRegister.text.toString().trim();
    String mailText = mailRegister.text.toString().trim();

    if(
      nameText.isNotEmpty &&
      mailText.isNotEmpty
    ){
      return true;
    }else{
      // Fluttertoast.showToast(
      //   msg: "Faltan datos por llenar",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      // );
      return false;
    }
  }

}

class Forma extends StatelessWidget {
  const Forma({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FormPage(),
    );
  }
}