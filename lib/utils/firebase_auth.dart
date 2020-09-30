import 'dart:convert';

import 'package:almacen/utils/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:dialisis/utils/models/profile_model.dart';
// import 'package:dialisis/utils/providers/db_provider.dart';
import 'package:http/http.dart' as http;

import 'header.dart';
// import 'dart:convert' as JSON;

// Para usar estas funciones se necesitan tener servicios de google activados en plataforma de Firebase
// Crear un proyecto en Firebase para Android o iOS, generar certificados correspondientes, habilitar métodos de autenticación necesarios (Google)
// https://firebase.google.com/?hl=es
class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //Función no utilizada
  Future<bool> signInWithEmail(String email, String password) async{
    try {
      print("Login con correo");
      var result = await _auth.signInWithEmailAndPassword(email: email,password: password);
      var user = result.user;
      print("Usuario: $user");
      if(user != null){
        print("Saliendo de proceso de creación");
      return true;
      }
      else{
      return false;
      }

    } catch (e) {
      return false;
    }
  }

  // static Future<UserCredential> createUser(String email) async {
  static Future<bool> createUser(String email) async {
    if(Firebase.apps.length>1){
      print(Firebase.apps);
      await Firebase.apps.last.delete();
    }else{
    FirebaseApp app = await Firebase.initializeApp(
      name: 'Secondary', options: FirebaseApp.instance.options);
      FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: "temporal");
    }
      return true;
    // await app.delete();
    // print(Firebase.apps);
    // print(Firebase.apps.length);
    // print(Firebase.apps);
    // print(Firebase.apps.length);
    // await Firebase.initializeApp();
    // return true;
}

//   static Future<FirebaseUser> register(String email, String password) async {

//     FirebaseApp app = await FirebaseApp.configure(
//         name: 'Secondary', options: await FirebaseApp.instance.options);
//     return FirebaseAuth.fromApp(app)
//         .createUserWithEmailAndPassword(email: email, password: password);
// }

  Future<bool> createUser2(String email) async {
    try {
      final FirebaseAuth authentication = FirebaseAuth.instance;
      await authentication.createUserWithEmailAndPassword(email: email, password: "temporal");
      await _auth.signOut();
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> forgetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future getUserData(String email, String name) async {

    var jsonObject = {
      "USERNAME": name,
      "EMAIL": email
    };

    

    final response = await http.post("${APIKey.apiURL}/users", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    
    return response;
  }



  //Función no utilizada
  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("error logging out");
    }
  }
}
//Para información más detallada visitar las páginas de las dependencias utilizadas
// https://pub.dev/packages/firebase_auth
// https://pub.dev/packages/google_sign_in