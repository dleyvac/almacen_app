
import 'package:almacen/main.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/firebase_auth.dart';
import 'package:almacen/utils/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almacen/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


class LogoutPage extends StatefulWidget {
  @override
  _LogoutPageState createState() {
    return new _LogoutPageState();
  }
}

class _LogoutPageState extends State<LogoutPage> {
  bool _isLoading = false;
  String email = "";
  String name = "";
  String organization = "";
  String sub = "";
  TextStyle contentStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black54
  );
  TextStyle titletStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.black54
  );

  //Obtiene datos del perfil (nombre, correo y foto)
  Future<String> getData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    // var user = await _auth.currentUser();
    var user = _auth.currentUser;


    this.setState(() {
      _isLoading = false;
      this.email = user.email;
      // this._isLoading = true;
    });
    print("USER_ID");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var userID = preferences.get('USER_ID');
    var orgID = preferences.get('ORGANIZATION_ID');
    var subID = preferences.get('SUBINVENTORY_ID');

    var jsonObject = {
      "USER_ID": userID,
      "ORGANIZATION_ID": orgID,
      "SUBINVENTORY_ID": subID
    };
    // print(jsonObject);

    final response = await http.put("${APIKey.apiURL}/profile", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );

    var datauser = json.decode(response.body);
    var responseData = datauser['data'];

    // print(responseData);
    this.setState(() {
      email = responseData[0]["EMAIL"];
      name = responseData[0]["NOMBRE_PERSONA"];
      organization = responseData[0]["ORGANIZATION_NAME"];
      sub = responseData[0]["DESCRIPTION"];
      _isLoading = true;
    });

    
    return "Success!";
  }

  Future<String> getOrgData() async {
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
    // this.getOrgData();
    //this.getOrgSub();

  }

  @override
  Widget build(BuildContext context) {
    return  _isLoading ? new Scaffold(
      endDrawer: Container(width:250, child: Drawer(
        child: 
        Column(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: Text("Configuración"),
                  subtitle: Text("Configuración"),
                  trailing: Icon(Icons.settings),
                ),
                
              ],),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                ListTile(
                  title: Text("Cerrar Sesión"),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () async {
                    await AuthProvider().logOut();
                    try{
                      AuthProvider().logOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MyApp()))
                        .then((_) => MyApp());
                    }catch(Error){
                      print(Error);
                    }
                  },
                ),
              ),
            ),
          ],), 
      ),
    ),
      appBar: new AppBar(
        title: new Text("Perfil Administrador", style: TextStyle(color: Colors.white),),
        backgroundColor: ColorsStyle.continoPrimary,
      ),
      
      body: new Center(child: 
        ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Center(
              //Muestran los datos solicitados en pantalla
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60.0,
                    child: Image.asset('assets/images/admin.png'),
                  ),
                  ),
                  Text("Nombre", style: titletStyle,),
                  Text(name, style: contentStyle),
                  SizedBox(height: 10),
                  Text(email, style: titletStyle,),
                  Text(email, style: contentStyle),
                  SizedBox(height: 20),
                  Text('Sucursal', style: titletStyle,),
                  Text(organization, style: contentStyle,),
                  SizedBox(height: 10),
                  Text('Subinventario', style: titletStyle,),
                  Text(sub, style: contentStyle,),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    ): Scaffold(body: Center(child: CircularProgressIndicator(),),);
  }
}

class Logout extends StatelessWidget {
  const Logout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LogoutPage(),
    );
  }
}