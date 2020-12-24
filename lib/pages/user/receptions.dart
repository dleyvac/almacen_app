import 'dart:async';
import 'package:almacen/pages/user/send.dart';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

//Módulo que muestra la información de cada equipo, requiere un id_articulo para llamarlo
class ReceptionsPage extends StatefulWidget {
  ReceptionsPage({Key key, this.lineID, this.orderID,}) : super(key: key, );
  final String lineID;
  final String orderID;

  @override
  _ReceptionsPageState createState() => _ReceptionsPageState(lineID, orderID);
}

class _ReceptionsPageState extends State<ReceptionsPage> {
  String lineID;
  String orderID;
  List dataLine;
  List dataTemp;
  int flagCamera = 0;
  List<dynamic> lines = List<dynamic>();
  bool _isLoading = false;
  bool _isValidate = false;
  //Timer _end;

  _ReceptionsPageState(String lineID, String orderID) {
    this.lineID = lineID;
    this.orderID = orderID;
  }

//Carga los datos requeridos por el id_articulo
Future<bool> getData() async {
  this.setState(() {
    _isLoading = false;
  });
  final responseReception = await http.get("${APIKey.apiURL}/receptions/$lineID", 
  headers: Header.headers
  );
  var dataLines = json.decode(responseReception.body);

  if(dataLines["code"] == 200){
    final responseTemp = await http.get("${APIKey.apiURL}/temp/$lineID", 
    headers: Header.headers
    );
    var dataTemps = json.decode(responseTemp.body);
    if(dataTemps["code"] == 200){
      this.setState(() {
        dataLine = dataLines["data"];
        dataTemp = dataTemps["data"];
        _isLoading = true;
      });
      await getDoppler();
      await getValidation();
    }
  }
  return true;
}

Future<bool>getByScan(index) async {
  ScanResult scan = await BarcodeScanner.scan();
  print(scan.type);
  if(scan.type == ResultType.Barcode){
    if(scan.rawContent == "" || scan.rawContent == null){
      // dataTemp[index]["STATUS"] = "INCOMPLETE";
      return true;
    }else{
      this.setState(() {
        dataTemp[index]["SERIE"] = scan.rawContent;
        dataTemp[index]["STATUS"] = "COMPLETE";
      });
      return true; 
    }
  }
  if(scan.type == ResultType.Cancelled){
    return false;
  }
  return true;
}

Future<bool>getByText(int index) async {
  var _serie = TextEditingController(text: dataTemp[index]["SERIE"].toString());
  showDialog(
    context: context,
    builder: (BuildContext context){
      return new AlertDialog(
        title: new Text("Ingresar serial"),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: _serie,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Número de serie', hintText: "Ingrese número de serie"),
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
              dataTemp[index]["SERIE"] = _serie.value.text;
              if(_serie.value.text.trim() == "" ){
                this.setState((){
                  dataTemp[index]["STATUS"] = "INCOMPLETE";
                }); 
              }else{
                this.setState((){
                  dataTemp[index]["STATUS"] = "COMPLETE";
                });
              }
              await getDoppler();
              await getValidation();
              await saveTemp(index); await getData();
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

Future<bool>getEmpty() async {
  for(var index = 0; index < dataTemp.length; index++){
    if(dataTemp[index]["STATUS"] != "NA"){
      if(dataTemp[index]["STATUS"] != "SENT"){
      if(dataTemp[index]["SERIE"].trim() != ""){
        this.setState(() {
          dataTemp[index]["STATUS"] = "COMPLETE";
        });
      }
      if(dataTemp[index]["SERIE"].trim() == ""){
        this.setState(() {
          dataTemp[index]["STATUS"] = "INCOMPLETE";
        });
      }
    }
    }
  }
  return true;
}

Future<bool>getValidation() async {
  this.setState(() {
      _isValidate = false;
    });
  var counter = 0;
  for(var index = 0; index < dataTemp.length; index++){
    if(
      dataTemp[index]["STATUS"] == "DUPLICATE"){
      counter++;
    }
  }
  if(counter == 0){
    this.setState(() {
      _isValidate = true;
    });
  }
  return true;
}

Future<bool>saveTemp(index) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
    var userID = preferences.get('USER_ID');
    var tempID = dataTemp[index]["TEMP_ID"];
    var serie = dataTemp[index]["SERIE"];
    var status = dataTemp[index]["STATUS"];

    var jsonObject = {
      "TYPE": "SAVE",
      "TEMP_ID": tempID,
      "SERIE": serie,
      "STATUS": status,
      "USER_ID": userID,
    };

    await http.put("${APIKey.apiURL}/temp", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
  return true;
}
Future<bool>saveTempAll() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var userID = preferences.get('USER_ID');
  for(var index = 0; index < dataTemp.length; index++){
    var tempID = dataTemp[index]["TEMP_ID"];
    var serie = dataTemp[index]["SERIE"];
    var status = dataTemp[index]["STATUS"];

     var jsonObject = {
      "TYPE": "SAVE",
      "TEMP_ID": tempID,
      "SERIE": serie,
      "STATUS": status,
      "USER_ID": userID,
    };

    final response = await http.put("${APIKey.apiURL}/temp", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );

     var tempUpdateData = json.decode(response.body);
     print(tempUpdateData);
   }
   return true;
 }

Future<bool>getDoppler() async {
  List dopplers = [];
  for(var index = 0; index < dataTemp.length; index++){
    if(dataTemp[index]["STATUS"] != "INCOMPLETE"){
      if(dataTemp[index]["STATUS"] != "SENT"){
        if(dataTemp[index]["STATUS"] != "NA"){
          for(var i = 0; i < dataTemp.length; i++){
            if(index != i){
              if(dataTemp[index]["SERIE"].trim() == (dataTemp[i]["SERIE"].trim())){
                dopplers.add(index);
              }
            }
          }
        }
      }
    }
  }
  dopplers = dopplers.toSet().toList();
  await getEmpty();
  for(var index = 0; index < dopplers.length; index++){
    var i = dopplers[index];
    this.setState(() {
      dataTemp[i]["STATUS"] = "DUPLICATE";
    });
  }
  return true;
}

Future<bool> scanAtFirst() async {
  if(await getData()){
    for(var index = 0; index < dataTemp.length; index++){
      if(dataTemp[index]["STATUS"] == "INCOMPLETE"){
        if(await getByScan(index)){
          await getDoppler();
          await getValidation();
          await saveTemp(index);
        }else{
          break;
        }
      }
    }
    this.setState(() {
      _isLoading = true;
    });
    await getData();
    return true;
  }else{
    return false;
  }
}

//Cuando se inicie el módulo activa la función geData()
@override
void initState(){
  super.initState();
  // this.scanAtFirst();
  this.getData();
}


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: ColorsStyle.continoPrimary,
        title: new Text("Línea: $lineID"),
        actions: [
          _isValidate?
          IconButton(icon: Icon(
            Icons.assignment_turned_in),
            color: Colors.orange,
            onPressed: ()async{
              if(await saveTempAll()){
              Navigator.push( 
                context, new MaterialPageRoute(
                  builder: (context) => new Send(
                    lineID: lineID, 
                  )
                ),
              )
              .then((value) async {
                print(value);
                if(value){
                  Navigator.pop(context, true);
                }else{
                  Navigator.pop(context, false);
                }
              });
              }
            },
            ):
          IconButton(icon: Icon(Icons.assignment_turned_in),color: Colors.grey,onPressed: null,)
        ],
        // automaticallyImplyLeading: false,
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
        child:ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(dataLine[0]["LINE_LOCATION_ID"]),
              subtitle: Text(dataLine[0]["DESCRIPCION"]),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: dataTemp == null ? 0 : dataTemp.length,
                  itemBuilder: (BuildContext context, int index) {
                  String serie = dataTemp[index]["SERIE"].trim();
                  String username = dataTemp[index]["USER_NAME"];
                  return ListTile(
                    title:
                      dataTemp[index]["STATUS"] == "COMPLETE" ? Text("$index.- Serie Completa"):
                      dataTemp[index]["STATUS"] == "INCOMPLETE" ? Text("$index.- Serie Incompleta"):
                      dataTemp[index]["STATUS"] == "DUPLICATE" ? Text("$index.- Serie Pendiente"):
                      dataTemp[index]["STATUS"] == "SENT" ? Text("$index.- Serie Enviada"):
                      dataTemp[index]["STATUS"] == "NA" ? Text("$index.- Serie No Disponible"):
                      Text("Serie"),
                    subtitle: 
                      dataTemp[index]["SERIE"].trim() == "" ? Text("Inserta Serie"):
                      dataTemp[index]["SERIE"].trim() != "" ? Text("$serie\nUsuario: $username"):
                      dataTemp[index]["STATUS"] == "NA" ? Text("Serie No Disponible\nUsuario: $username"):
                      Text(""),
                    leading: 
                      dataTemp[index]["STATUS"] == "COMPLETE" ? Icon(Icons.check, color: Colors.blue):
                      dataTemp[index]["STATUS"] == "INCOMPLETE" ? Icon(Icons.warning, color: Colors.red):
                      dataTemp[index]["STATUS"] == "DUPLICATE" ? Icon(Icons.priority_high, color: Colors.orange):
                      dataTemp[index]["STATUS"] == "SENT" ? Icon(Icons.done_all, color: Colors.black):
                      dataTemp[index]["STATUS"] == "NA" ? Icon(Icons.watch_later, color: Colors.grey):
                      null,
                    trailing: 
                    dataTemp[index]["STATUS"] != "SENT"?
                    Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: () async {
                                if(await getByScan(index)){
                                  await getDoppler();
                                  await getValidation();
                                  await saveTemp(index); await getData();
                                }
                              }
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await getByText(index);
                              }
                            ),
                            IconButton(
                              icon: Icon(Icons.watch_later),
                              onPressed: () async {
                                this.setState(() {
                                  dataTemp[index]["STATUS"] = "NA";
                                  dataTemp[index]["SERIE"] = "N/D";
                                });
                                await getDoppler();
                                await getValidation();
                                await saveTemp(index); await getData();
                              }
                            )
                          ],
                        ):null,
                  );
                 },
                ),
              ],
            ),
          ],
        )
      ): Center(child:CircularProgressIndicator())
      ),
    );
  }
}

class Receptions extends StatelessWidget {
  Receptions({Key key, this.lineID,this.orderID,}) : super(key: key);
  final String lineID;
  final String orderID;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ReceptionsPage(
        lineID: lineID,
        orderID: orderID
        ),
    );
  }
}

