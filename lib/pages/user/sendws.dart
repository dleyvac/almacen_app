import 'dart:async';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

//Módulo que muestra la información de cada equipo, requiere un id_articulo para llamarlo
class SendWsPage extends StatefulWidget {
  SendWsPage({Key key, this.lineID, this.cantidad,}) : super(key: key, );
  final String lineID;
  final String cantidad;

  @override
  _SendWsPageState createState() => _SendWsPageState(lineID, cantidad);
}

class _SendWsPageState extends State<SendWsPage> {
  String lineID;
  String cantidad;
  List dataLine;
  List dataTemp;
  List dataCheck = [];
  String subinventory = "";
  String folio = "";
  int flagCamera = 0;
  List<dynamic> lines = List<dynamic>();
  bool _isLoading = false;
  bool _isComplete = false;

  TextEditingController cantidadSolicitada = TextEditingController();

  _SendWsPageState(String lineID, String cantidad) {
    this.lineID = lineID;
    this.cantidad = cantidad;
  }


Future<bool> getSub()async{
  print("CANTIDAD SOLICITADA: $cantidad");
  print("CANTIDAD SOLICITADA: $cantidad");
  var jsonObject = {
    "LINE_LOCATION_ID": lineID,
  };

  final response = await http.put("${APIKey.apiURL}/subinventory", 
    headers: Header.headers,
    body: jsonEncode(jsonObject)
  );
  var subData = json.decode(response.body);
  if(subData["code"] == 200){
    this.setState(() {
      subinventory = subData["data"][0]["NAME"];
      _isLoading = true;
    });
    return true;
  }
  if(subData["code"] == 400){
    this.setState(() {
      subinventory = "Sin subinventario";
      _isLoading = true;
    });
    return false;
  }
  return true;
}

Future<bool>getByText(String factura) async {
  var _factura = TextEditingController(text: factura);
  showDialog(
    context: context,
    builder: (BuildContext context){
      return new AlertDialog(
        title: new Text("Ingresar Folio"),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: _factura,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Folio de factura', hintText: "Ingrese folio de la factura"),
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
            child: const Text('Agregar'),
            onPressed: () async {
              this.setState(() {
                folio = _factura.text;
              });
              await checkComplete();
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

Future<bool> checkComplete()async{
  // int cantSol = int.parse(cantidadSolicitada.text);
  if(folio.trim() == null || folio.trim() == "" || 
  cantidadSolicitada.text == null || cantidadSolicitada.text == ""){
    this.setState(() {
      _isComplete = false;
    });
  }else{
    this.setState(() {
      _isComplete = true;
    });
  }
  return true;
}


Future<bool> createID() async{
  var today = DateTime.now();
  String id = "${today.second}${today.month}${today.millisecond}${today.minute}${today.minute}${today.minute}$lineID";
  String entrada = "${today.day}${today.month}${today.year}${today.hour}${today.minute}${today.second}${today.millisecond}";
  print(id);
  print(entrada);
  return true;
}

Future<bool> createRecepcion() async{
  var today = DateTime.now();
  String last = lineID.substring(lineID.length - 5,lineID.length);
  String recID = "${today.month}$last${today.year}${today.second}${today.day}";
  String folioEntrada = "${today.month}${today.millisecond}${today.minute}${today.day}${today.second}${today.year}${today.hour}";
  SharedPreferences preferences = await SharedPreferences.getInstance();
  
  var jsonObject = {
      "RECEPCION_ID": recID,
      "FOLIO_ENTRADA_ALMACEN": folioEntrada,
      "LINE_LOCATION_ID": lineID,
      "FACTURA": folio,
      "CANT_RECIBIDA": int.parse(cantidadSolicitada.text),
      "USER_ID": preferences.get('USER_ID')
    };

    print(jsonObject);

    final response = await http.post("${APIKey.apiURL}/receptions", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var receptionData = json.decode(response.body);
    if(receptionData["code"]==200){
      await finishLine();
      return true;
    }else{
      return false;
    }
}
Future<bool> finishLine() async{
  
  var jsonObject = {
      "LINE_LOCATION_ID": lineID
    };

    final response = await http.put("${APIKey.apiURL}/receptions", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var lineData = json.decode(response.body);
    if(lineData["code"]==200){
      Navigator.pop(context, true);
      return true;
    }else{
      return false;
    }
}

//Cuando se inicie el módulo activa la función geData()
@override
void initState(){
  super.initState();
  this.getSub();
}


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: ColorsStyle.continoPrimary,
        title: new Text("Subir Línea sin Series"),
      ),
      body: 
      WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child:  
      _isLoading?
        Container(
        child:
        Scrollbar(
          child:
          ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              ListTile(
                title: Text("Factura"),
                subtitle: 
                  folio.trim() == null || folio.trim() == "" ?
                  Text("Escribe el folio de la factura"):
                  Text(folio),
                trailing: Icon(Icons.edit),
                onTap: ()async{
                  await getByText(folio);
                },
              ),
              ListTile(
                title: Text("Cantidad Solicitada"),
                subtitle: Text(cantidad.toString()),
              ),
              ListTile(
                title: Text("Cantidad Recibida"),
                subtitle: TextField(
                  onChanged: (value)async{
                    await checkComplete();
                  },
                  controller: cantidadSolicitada,
                  decoration: new InputDecoration(labelText: "Escriba la cantidad recibida"),
                  keyboardType: TextInputType.number, 
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
              ),
              ListTile(
                title: Text("Subinventario"),
                subtitle: Text(subinventory),
              ),
              _isComplete?
              RaisedButton(
                child: Text("Crear Recepción", style: TextStyle(color: Colors.white),),
                color: ColorsStyle.continoSecondary,
                onPressed: ()async{
                  await createID();
                  await createRecepcion();
                },
              ):
              RaisedButton(
                child: Text("Crear Recepción", style: TextStyle(color: Colors.white),),
                color: Colors.grey,
                onPressed: null
              )
            ],
          ),
        ),
      ): Center(child:CircularProgressIndicator())
      ),
    );
  }
}

class SendWs extends StatelessWidget {
  SendWs({Key key, this.lineID, this.cantidad}) : super(key: key);
  final String lineID;
  final String cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SendWsPage(
        lineID: lineID,
        cantidad: cantidad,
        ),
    );
  }
}

