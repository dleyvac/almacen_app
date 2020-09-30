import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:almacen/pages/login.dart';
import 'package:almacen/pages/user/home.dart';
import 'package:almacen/pages/splash.dart';

//Usado para forzar el cierre de sesión 
class LoggingOutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,AsyncSnapshot<User> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting)
          return SplashPage();
        if(!snapshot.hasData || snapshot.data == null)
          return LoginPage();
        return HomePage(selected: 0,);
      },
    );
  }
}