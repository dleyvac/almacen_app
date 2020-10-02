import 'dart:async';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Módulo que muestra la información de cada equipo, requiere un id_articulo para llamarlo
class SendPage extends StatefulWidget {
  SendPage({Key key, this.lineID, this.cantidad,}) : super(key: key, );
  final String lineID;
  final String cantidad;

  @override
  _SendPageState createState() => _SendPageState(lineID, cantidad);
}

class _SendPageState extends State<SendPage> {
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

  _SendPageState(String lineID, String cantidad) {
    this.lineID = lineID;
    this.cantidad = cantidad;
  }

//Carga los datos requeridos por el id_articulo
Future<bool> getData() async {
  final responseReception = await http.get("${APIKey.apiURL}/receptions/$lineID", 
  headers: Header.headers
  );
  var dataLines = json.decode(responseReception.body);
  print(dataLines["code"]);
  if(dataLines["code"] == 200){
    final responseTemp = await http.get("${APIKey.apiURL}/test/$lineID", 
    headers: Header.headers
    );
    var dataTemps = json.decode(responseTemp.body);
    print(dataTemps);
    if(dataTemps["code"] == 200){
      List listTemps = dataTemps["data"];

      this.setState(() {
        _isLoading = true;
        dataLine = dataLines["data"];
        dataTemp = listTemps;
      });
      print(dataTemp);
    }

    if(dataTemps["code"] == 400){
      List listTemps = dataTemps["data"];

      this.setState(() {
        _isLoading = true;
        dataLine = dataLines["data"];
        dataTemp = listTemps;
      });
      print(dataTemp);
    }
  }
  if(dataLines["code"] == 400){
    this.setState(() {
        _isLoading = true;
        dataLine = [];
        dataTemp = [];
      });
  }
  return true;
}

Future<bool> createRecepcion() async{
  var today = DateTime.now();
  String recID = "${today.day}${today.month}${today.year}${today.minute}${today.hour}";
  String folioEntrada = "${today.month}${today.minute}${today.day}${today.year}${today.hour}";
  
  var jsonObject = {
      "RECEPCION_ID": recID,
      "FOLIO_ENTRADA_ALMACEN": folioEntrada,
      "LINE_LOCATION_ID": lineID,
      "FACTURA": folio,
      "CANT_RECIBIDA": dataTemp.length,
      "USER_ID": null
    };

    print(jsonObject);

    final response = await http.post("${APIKey.apiURL}/receptions", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var receptionData = json.decode(response.body);
    if(receptionData["code"]==200){
      await setSeries(recID);
      print("recepcion creada");
      return true;
    }else{
      return false;
    }
}

Future setSeries(String recID)async{
  for(var index = 0; index < dataTemp.length; index++){
    var serie = dataTemp[index]["SERIE"];
    var jsonObject = {
      "RECEPCION_ID": recID,
      "SERIE": serie,
      "USER_ID": dataTemp[index]["USER_ID"]
    };
    print(jsonObject);
    final response = await http.post("${APIKey.apiURL}/series", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var tempUpdateData = json.decode(response.body);
    print(tempUpdateData);

  }
}

Future<bool> setStatusTemp(tempID) async{
  var jsonObject = {
      "TYPE": "SET",
      "TEMP_ID": tempID
    };
    print(jsonObject);
    final response = await http.put("${APIKey.apiURL}/temp", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var tempUpdateData = json.decode(response.body);
    print(tempUpdateData);
  return true;
}

Future<bool> setCantidad() async{
  var jsonObject = {
      "CANTIDAD": dataTemp.length,
      "LINE_LOCATION_ID": lineID
    };
    print(jsonObject);
    final response = await http.put("${APIKey.apiURL}/lines", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
    var tempUpdateData = json.decode(response.body);
    print(tempUpdateData);
  return true;
}

Future<bool> getSub()async{
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
    });
    return true;
  }
  if(subData["code"] == 400){
    this.setState(() {
      subinventory = "Sin subinventario";
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
  if(folio.trim() == null || folio.trim() == ""){
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

//Cuando se inicie el módulo activa la función geData()
@override
void initState(){
  super.initState();
  this.getData();
  this.getSub();
}


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: ColorsStyle.continoPrimary,
        title: new Text("Subir Línea"),
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
          dataTemp != null ?
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
                title: Text("Subinventario"),
                subtitle: Text(subinventory),
              ),
              ExpansionTile(
                title: Text("Serie"),
                subtitle: Text("Series disponibles"),
                children: [
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: dataTemp == null ? 0 : dataTemp.length,
                    itemBuilder: (BuildContext context, int index) {
                    String serie = dataTemp[index]["SERIE"].trim();
                    String user = dataTemp[index]["USER_NAME"];
                    return ListTile(
                      title:
                        Text("Serie"),
                      subtitle: 
                        Text("$serie\nUsuario: $user"),
                    );
                  },
                  ),
                ],
              ),
              _isComplete?
              RaisedButton(
                child: Text("Crear Recepción", style: TextStyle(color: Colors.white),),
                color: ColorsStyle.continoSecondary,
                onPressed: ()async{
                  for(var index = 0; index < dataTemp.length; index++){
                    var tempID = dataTemp[index]["TEMP_ID"];
                    await setStatusTemp(tempID);
                  }
                  await setCantidad();
                  if(await createRecepcion()){
                    Navigator.pop(context, true);
                  }
                },
              ):
              RaisedButton(
                child: Text("Crear Recepción", style: TextStyle(color: Colors.white),),
                color: Colors.grey,
                onPressed: null
              )
            ],
          ): Center(child: Text("No hay series por registrar"),),
        ),
      ): Center(child:CircularProgressIndicator())
      ),
    );
  }
}

class Send extends StatelessWidget {
  Send({Key key, this.lineID,this.cantidad,}) : super(key: key);
  final String lineID;
  final String cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SendPage(
        lineID: lineID,
        cantidad: cantidad
        ),
    );
  }
}

