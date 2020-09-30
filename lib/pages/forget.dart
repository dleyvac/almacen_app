import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPage extends StatefulWidget {
  ForgetPage({Key key}) : super(key: key);

  @override
  _ForgetPageState createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {

  TextEditingController mailForget = TextEditingController();
  TextEditingController pwdForget = TextEditingController();

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
    TextStyle button = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white
    );
    TextStyle forget = new TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue
    );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      body:
    Container(
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
          Text("Olvidé", style: title,),
          Text("mi contraseña", style: subtitle,),
          SizedBox(height: 20),
          TextField(controller: mailForget, decoration: InputDecoration(hintText: "Correo electrónico", prefixIcon: Icon(Icons.email)),),
          SizedBox(height: 10),
          RaisedButton(
            color: ColorsStyle.continoPrimary,
            child: Text("Recuperar contraseña", style: button),
            onPressed: ()async{
              await AuthProvider().forgetPassword(mailForget.text.toString());
              Navigator.pop(context);
            }
          )
          ]
        ),
      ),
      ),
    ),
    );
  }
}

class Forget extends StatelessWidget {
  const Forget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ForgetPage(),
    );
  }
}