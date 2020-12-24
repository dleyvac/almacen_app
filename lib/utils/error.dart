import 'package:almacen/pages/login.dart';
import 'package:almacen/utils/select.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  ErrorPage({Key key, this.error, this.returnAt}) : super(key: key);
  final int error;
  final int returnAt;


  @override
  _ErrorPage createState() => _ErrorPage(error,returnAt);
}

class _ErrorPage extends State<ErrorPage> {
  List data;
  int error;
  int returnAt;
  TextStyle title = new TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );
  TextStyle subtitle = new TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );

  _ErrorPage(int error, returnAt){
    this.error = error;
    this.returnAt = returnAt;
  }

@override
  void initState() {
    super.initState();
  }
//Crea el BottomNavigationBarItem mostrando su título y un ícono por cada elemento 
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: new Container(
              color: Colors.white,
              child: 
              Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child:
              new Column(
                
                //Vista de la información básica del equipo, cada ListTile muestra el contenido de la información
                children: <Widget>[
                  Expanded(
                  child: Align(
                  alignment: Alignment.center,
                  child: 
                  new ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 90.0,
                    child: Image.asset('assets/images/error.png'),
                  ),
                  ),
                  SizedBox(height: 30),
                  Center(child: Text("No tienes acceso a la red", style: title,)),
                  SizedBox(height: 5),
                  Center(child: Text("Comprueba tu acceso a la red", style: subtitle,)),
                  SizedBox(height: 20),
                  RaisedButton(
                    color: Colors.orangeAccent,
                    elevation: 0,
                    child: Text("Intentar de nuevo", style: TextStyle(color: Colors.white),),
                    onPressed: ()async{
                      if(returnAt == 1){
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Selection()))
                        .then((_) => Selection());
                      }
                      if(returnAt == 2){
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()))
                        .then((_) => LoginPage());
                      }
                    },
                  )
                  ]
                  ),
                  ),
                  ),
              
          ]
          ),
        ),
      ),
  );
}
}
