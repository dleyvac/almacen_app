import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(30),
          child:
          new Center(
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
            SizedBox(height: 40),
            Center(child: CircularProgressIndicator(),),
            SizedBox(height: 20),
            Center(child: Text("cargando datos...")),
            ]
          ),
          ),
        ),
      ),
    );
  }
}