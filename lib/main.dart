import 'package:almacen/utils/select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:almacen/pages/login.dart';
import 'package:almacen/pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //No muestra el banner de debug
      debugShowCheckedModeBanner: false,
      title: 'App de Ventas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatelessWidget {
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
        if(snapshot.connectionState == ConnectionState.waiting)
          return SplashPage();
        //Si ya cargó la conexión pero no hay datos retornará a la pantalla de Login
        if(!snapshot.hasData || snapshot.data == null)
          return LoginPage();
        //Si ya cargó y si hay datos guardados en la instancia de autenticación, retornará a la página principal
        return Selection();
      },
    );
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}