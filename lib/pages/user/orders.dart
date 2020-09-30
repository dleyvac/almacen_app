import 'package:almacen/pages/user/receptions.dart';
import 'package:almacen/pages/user/sendws.dart';
import 'package:almacen/utils/api.dart';
import 'package:almacen/utils/colors.dart';
import 'package:almacen/utils/header.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Orders extends StatefulWidget {
  Orders({Key key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {

bool _isLoading = false;
List registers;
List registersCopy;
List proveedor = [];
List proveedores = [];
List subinventory;
int _isSelected = 1;
DateTime dateStartSelected;
DateTime dateEndSelected = DateTime.now();
var _controller = TextEditingController();


Future<DateTime> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
    );
    return picked;
}

Future<DateTime> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
    );
    return picked;
}

Future<String> getData() async {
  try{
  if (this.mounted) { 
  this.setState(() {
    _isLoading = false;
  });
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print("ORGANIZATION_ID");
  print(preferences.get('ORGANIZATION_ID'));
  var orgID = preferences.get('ORGANIZATION_ID');
  
  final response = await http.get("${APIKey.apiURL}/orders/$orgID", 
      headers: Header.headers
    );

  var datauser = json.decode(response.body);
  var responseCode = datauser['code'];
  var responseMessage = datauser['message'];
  var responseData = datauser['data'];

  if(responseCode == 200){
    final responseSub = await http.get("${APIKey.apiURL}/subinventory/$orgID", 
        headers: Header.headers
      );

      var datasub = json.decode(responseSub.body);
      var responseDataSub = datasub['data'];
      var responseCodeSub = datasub['code'];

      if(responseCodeSub == 200){
        if (this.mounted) { 
        this.setState(() {
          subinventory = responseDataSub;
          registers = responseData;
          registersCopy = responseData;
          // print(registers);
        });
        }
        print(responseMessage);
        
        await buildLines(registers);
        // print(proveedor);
        if (this.mounted) { 
        this.setState(() {
          _isLoading = true;
        });
        }
      }
      if(responseCodeSub == 400){
        if (this.mounted) { 
        this.setState(() {
          subinventory = responseDataSub;
          registers = responseData;
          registersCopy = responseData;
          // print(registers);
        });
        }
        print(responseMessage);
        
        // await buildLines(registers);
        // print(proveedor);
        this.setState(() {
          _isLoading = true;
        });
      }
  }

  if(responseCode == 400){
    if (this.mounted) { 
    this.setState(() {
      _isLoading = true;
      registers = [];
    });
    }
  }
  return "Success!";
  }catch(e){
    print(e);
  }
  return "Success!";
}

Future<bool> buildLines(registersBuild) async{
  if (this.mounted) { 
  this.setState(() {
    _isLoading = false;
  });
  }
  for(var index = 0; index < registersBuild.length; index ++){
      var headerID = registersBuild[index]['HEADER_ID'];
      final responseOrder = await http.get("${APIKey.apiURL}/lines/$headerID", 
      headers: Header.headers
      );
      var dataLines = json.decode(responseOrder.body);
      // print(dataLines);
      if(dataLines["code"] == 200){
        String provider = dataLines["data"][0]["PROVEEDOR"];
        if(proveedores.isEmpty){
          if (this.mounted) { 
          this.setState(() {
            var prov = {
              "PROVEEDOR": provider,
              "VALUE": true
            };
            proveedores.add(provider);
            proveedor.add(prov);
          });
          }
        }else{
          if(proveedores.contains(provider)){
          }else{
            if (this.mounted) { 
            this.setState(() {
              var prov = {
              "PROVEEDOR": provider,
              "VALUE": true
            };
            proveedores.add(provider);
            proveedor.add(prov);
            });
            }
          }
        }
        registersBuild[index]["LINE"] = dataLines["data"];
      }
    }
    if (this.mounted) { 
    this.setState(() {
      registers = registersBuild;
      _isLoading = true;
    });
    }
    return true;
}

Future<List<dynamic>> buildProveedor() async {
List<dynamic> provs = [];
for(var index = 0; index < registers.length; index ++){
  var proveedorName = registers[index]["PROVEEDOR"];
  provs.add(proveedorName);
}
return(provs);
}

void getProveedor(provs) async{
  if (this.mounted) { 
  this.setState(() {
    registers = registersCopy;
  });
  }
  List provs = [];
  for(var index = 0; index < proveedor.length; index ++){
    if(proveedor[index]["VALUE"] == true){
      var prov = proveedor[index]["PROVEEDOR"];
      for(var i = 0; i < registers.length; i ++){
        if(registers[i]["PROVEEDOR"] == prov){
          provs.add(registers[i]);
        }
      }
    }
  }
  if(dateStartSelected != null){
    getDate(provs);
  }else{
    if (this.mounted) { 
    this.setState(() {
      registers = provs;
    });
    }
  }
}

void getDate(provs) async {
  List timeProvs = [];
  if (this.mounted) { 
  this.setState(() {
      registers = provs;
  });
  }
  for(var index = 0; index < registers.length; index ++){
    var date = DateTime.parse(registers[index]["FECHA_OC"]);
    if(date.isAfter(dateStartSelected) && date.isBefore(dateEndSelected)){
      timeProvs.add(registers[index]);
    }else{
      print("No hay datos");
    }
  }
  if (this.mounted) { 
  this.setState(() {
      registers = timeProvs;
  });
  }
}

Future<bool> searchByNum(searched) async {
  List orders = [];
  for(var index = 0; index < registers.length; index ++){
    List lines = [];
    orders.add(registers[index]);
    for(var i = 0; i < registers[index]["LINE"].length; i ++){
      if(registers[index]["LINE"][i]["LINE_LOCATION_ID"].toString().contains(searched) ||
        registers[index]["LINE"][i]["NUM_OC"].toString().contains(searched)){
        lines.add(registers[index]["LINE"][i]);  
        // print(registers[index]["LINE"][i]);
      }
    }
    orders[index]["LINE"] = lines;
  }
  if (this.mounted) { 
  this.setState(() {
    registers = orders;
  });
  }
  return true;
  // print(orders);
}

Future<bool> clearController()async{
  _controller.clear();
  await buildLines(registers);
  return true;
}

Future<bool> createTemp(cantidad, numOC, lineID) async {
  for(var index = 0; index < cantidad; index ++){

    var tempID = "$lineID$index";
    var jsonObject = {
      "TEMP_ID": tempID,
      "NUM_OC": numOC,
      "LINE_LOCATION_ID": lineID,
      "SERIE": "",
      "STATUS": "INCOMPLETE",
    };

    await http.post("${APIKey.apiURL}/temp", 
      headers: Header.headers,
      body: jsonEncode(jsonObject)
    );
  }

  return true;
}

  Future<Map>setSubinventory(var lineID) async {
  // await getOrganizations();  
  // var flag = false;
  var getResponse = {
    "code": 100,
    "message": "",
  };

  print(getResponse["code"]);
  await showDialog(
    context: this.context,
    builder: (context){
      return StatefulBuilder( // StatefulBuilder
      builder: (context, setState) {

        return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child:
        AlertDialog(
        title: new Text("Selecciona subinventario"),
        content:
        _isLoading?
        new Scrollbar(
          child: 
              new ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: subinventory == null ? 0 : subinventory.length,
                itemBuilder: (BuildContext context, int index) {
                  return new RadioListTile(
                    activeColor: ColorsStyle.continoSecondary,
                    value: int.parse(subinventory[index]["SUBINVENTORY_ID"]),
                    groupValue: _isSelected,
                    title: Text(subinventory[index]["NAME"]),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        this._isSelected = value;
                      });
                    }
                  );
                },
              ),
        ):Text("No hay datos"),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Aceptar'),
            onPressed: () async {
              var jsonObject = {
                "LINE_LOCATION_ID": lineID,
                "SUBINVENTARIO_ID": _isSelected,
              };
              print(jsonObject);

              final responseSub = await http.put("${APIKey.apiURL}/test", 
                headers: Header.headers,
                body: jsonEncode(jsonObject)
              );

              var res = json.decode(responseSub.body);

              getResponse["code"] = (res["code"]);
              getResponse["message"] = (res["message"]);
              Navigator.pop(context,true);
              return true;
            }
          ),
        ],
        ),
      );
      }
      );
    }
  );
  return getResponse;
}


// @override
//   void dispose() {
//    super.dispose();
//   }

@override
  void initState() {
    super.initState();
    this.getData();
    // this.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
      _isLoading ?
      registers.isNotEmpty ? 
      Container(width:250, child: Drawer(
        child: 
        ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: [
                ExpansionTile(
                  title: Text("Proveedor"),
                  subtitle: Text("Seleccione proveedores"),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: proveedor == null ? 0 : proveedor.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title: Text(proveedor[index]["PROVEEDOR"]), 
                          value: proveedor[index]["VALUE"], 
                          onChanged: (value){
                            this.setState(() {
                              proveedor[index]["VALUE"] = value;
                            });
                          },
                        );
                      }
                    ),
                  ]
                ),
                ListTile(
                    title: Text("Seleccionar Fecha Inicial"),
                    subtitle: 
                    dateStartSelected == null ? 
                    Text("Seleccionar rango o fecha")
                    :Text("${dateStartSelected.year.toString()}-${dateStartSelected.month.toString()}-${dateStartSelected.day.toString()}"),
                    onTap: ()async{
                      var date = await _selectStartDate(context);
                      this.setState(() {
                        dateStartSelected = date;
                      });
                    },
                ),
                ListTile(
                    title: Text("Seleccionar Fecha Final"),
                    subtitle: 
                    dateEndSelected == null? 
                    Text("Seleccionar rango o fecha")
                    :Text("${dateEndSelected.year.toString()}-${dateEndSelected.month.toString()}-${dateEndSelected.day.toString()}"),
                    onTap: ()async{
                      var date = await _selectEndDate(context);
                      this.setState(() {
                        dateEndSelected = date;
                      });
                    },
                ),
                Divider()
            ],),
                SizedBox(
                width: double.infinity,
                child:
                RaisedButton(
                  color: ColorsStyle.continoSecondary,
                  child: Text("Buscar", style: TextStyle(color: Colors.white),),
                  onPressed: () async{
                    await clearController();
                    getProveedor(await buildProveedor());
                    // print(proveedor);
                  },
                )
                ),
          ],
        ), 
      ),
    ): null:null,
      appBar: AppBar(
        title: new Text("Órdenes de Compra", style: TextStyle(color: Colors.white),),
        backgroundColor: ColorsStyle.continoPrimary
        ),
      body:
      _isLoading? 
      registers.isNotEmpty?
      Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              cursorColor: Colors.orange,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Colors.orange,
                focusColor: Colors.orange,
                hoverColor: Colors.orange,
                contentPadding: EdgeInsets.all(20.0),
                hintText: "Buscar número de orden o linea",
                suffixIcon: IconButton(
                  color: Colors.orangeAccent,
                  icon: Icon(Icons.cancel),
                  onPressed: () async {
                    await clearController();
                  }
                ),
              ),
              onChanged: (String value) async {
                await buildLines(registers);
                searchByNum(value);
              }
            ),
            
            Expanded(child:
    Container(
       child:
      
      new RefreshIndicator(
        color: Colors.orange,
        //Cuando se recarga la página se actualizarán los datos en la base de datos local y cargará de nuevo la pantalla
        onRefresh: () async {
          await getData();
        },
        child:
      new ListView.builder(
        shrinkWrap: true,
         physics: BouncingScrollPhysics(),
        itemCount: registers == null ? 0 : registers.length,
        itemBuilder: (BuildContext context, int index) {
        return ExpansionTile(
          initiallyExpanded: true,
          title: Text(registers[index]["NUM_OC"]),
          subtitle: Text(registers[index]["PROVEEDOR"]),
          children: [
            new ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: registers[index]["LINE"] == null ? 0 : registers[index]["LINE"].length,
              itemBuilder: (BuildContext context, int i) {
              String desc = registers[index]["LINE"][i]["DESCRIPCION"];
              String cantS = registers[index]["LINE"][i]["CANT_SOLICITADA"];
              String cantR = registers[index]["LINE"][i]["CANT_RECIBIDA"];
              return 
              registers[index]["LINE"][i]["CONTROL_SERIE"] == "Y" && registers[index]["LINE"][i]["STATUS"] != "COMPLETE"?
              registers[index]["LINE"][i]["CANT_RECIBIDA"] != registers[index]["LINE"][i]["CANT_SOLICITADA"] ?
              ListTile(
                title: Text(registers[index]["LINE"][i]["LINE_LOCATION_ID"]),
                subtitle: Text("$desc\nCantidad Solicitada: $cantS\nCantidad Recibida: $cantR"),
                onTap: () async{
                  String status = registers[index]["LINE"][i]["STATUS"];
                  this.setState(() {
                    registers[index]["LINE"][i]["STATUS"] = "LOADING";
                  });
                  var lineID = registers[index]["LINE"][i]["LINE_LOCATION_ID"];
                  var ordenID = registers[index]["LINE"][i]["NUM_OC"];
                  var cantidadS = int.parse(registers[index]["LINE"][i]["CANT_SOLICITADA"]);
                  var cantidadR = int.parse(registers[index]["LINE"][i]["CANT_RECIBIDA"]);
                  int cantidad = cantidadS - cantidadR;
                  await createTemp(cantidad, ordenID, lineID);
                  this.setState(() {
                    registers[index]["LINE"][i]["STATUS"] = status;
                  });
                  if(cantidadR == 0){
                    await setSubinventory(registers[index]["LINE"][i]["LINE_LOCATION_ID"]).then((value){
                        this.setState(() {
                          registers[index]["LINE"][i]["STATUS"] = status;
                        });
                        Navigator.push( 
                          context, new MaterialPageRoute(
                            builder: (context) => new Receptions(
                              lineID: lineID, 
                              orderID: ordenID
                            )
                          ),
                        )
                        .then((value) async {
                          if(value){
                            if(this.mounted){
                              await getData();
                            }
                          }
                          if(value == null){
                            print("Se cerró");
                          }
                        });
                    });
                  }
                  if(cantidadR != 0){
                    Navigator.push( 
                      context, new MaterialPageRoute(
                        builder: (context) => new Receptions(
                          lineID: lineID, 
                          orderID: ordenID
                        )
                      ),
                    )
                    .then((value) async {
                      if(value){
                        if(this.mounted){
                          await getData();
                        }
                      }
                      if(value == null){
                        print("Se cerró");
                      }
                    });
                  }
                },
                leading:
                  registers[index]["LINE"][i]["STATUS"] == "LOADING"? 
                  CircularProgressIndicator():
                  Icon(Icons.warning, color: Colors.red,)
              ):
              ListTile(
                title: Text(registers[index]["LINE"][i]["LINE_LOCATION_ID"]),
                subtitle: Text("$desc\nCantidad Solicitada: $cantS\nCantidad Recibida: $cantR"),
                onTap: () async{
                },
                leading:
                  registers[index]["LINE"][i]["STATUS"] == "LOADING"? 
                  CircularProgressIndicator():
                  Icon(Icons.done_all, color: Colors.green,)
              ):
              registers[index]["LINE"][i]["CONTROL_SERIE"] == "N"  && registers[index]["LINE"][i]["STATUS"] != "COMPLETE"?
              ListTile(
                title: Text(registers[index]["LINE"][i]["LINE_LOCATION_ID"]),
                subtitle: Text(registers[index]["LINE"][i]["DESCRIPCION"]),
                onTap: () async{
                  var cantidadR = int.parse(registers[index]["LINE"][i]["CANT_RECIBIDA"]);
                  var lineID = registers[index]["LINE"][i]["LINE_LOCATION_ID"];
                  String status = registers[index]["LINE"][i]["STATUS"];
                  await setSubinventory(registers[index]["LINE"][i]["LINE_LOCATION_ID"]).then((value){
                    print(value);
                      Fluttertoast.showToast(
                        msg: value["message"],
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 13.0
                      );
                      this.setState(() {
                        registers[index]["LINE"][i]["STATUS"] = status;
                      });
                  });
                  Navigator.push( 
                      context, new MaterialPageRoute(
                        builder: (context) => new SendWs(
                          lineID: lineID,
                          cantidad: cantidadR 
                        )
                      ),
                    )
                    .then((value) async {
                      if(value){
                        if(this.mounted){
                          await getData();
                        }
                      }
                      if(value == null){
                        print("Se cerró");
                      }
                    });
                },
                leading: Icon(Icons.info, color: Colors.grey,)
              ):
              registers[index]["LINE"][i]["STATUS"] == "COMPLETE" ?
              ListTile(
                title: Text(registers[index]["LINE"][i]["LINE_LOCATION_ID"]),
                subtitle: Text(registers[index]["LINE"][i]["DESCRIPCION"]),
                leading: Icon(Icons.done_all, color: Colors.green,)
              ):
              null;
            },
            )
          ],
        );
       },
      ),
      )
    ),
    )]
    ): Center(child: Text("No hay registros"),):
      Center(child: CircularProgressIndicator(),),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Orders(),
    );
  }
}