// import 'dart:async';
// import 'dart:collection';
// import 'dart:io';
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert' as JSON;
// import 'package:http/http.dart' as http;

// //Módulo que muestra la información de cada equipo, requiere un id_articulo para llamarlo
// class ReceptionsPage extends StatefulWidget {
//   ReceptionsPage({Key key, this.line_location_id, this.orden_compra,}) : super(key: key, );
//   final String line_location_id;
//   final String orden_compra;

//   @override
//   _ReceptionsPageState createState() => _ReceptionsPageState(line_location_id, orden_compra);
// }

// class _ReceptionsPageState extends State<ReceptionsPage> {
//   String line_location_id;
//   String orden_compra;
//   List data;
//   int flagCamera = 0;
//   bool flag = true;
//   List<dynamic> lines = List<dynamic>();
//   List<dynamic> test_lines = List<dynamic>();
//   List<dynamic> flagLine = List<dynamic>();
//   bool _isLoading = false/*, _isInit = true*/;
//   TextStyle title = TextStyle(fontWeight: FontWeight.bold);
//   int dialogFlag = 0;
//   bool flagTime = false;
//   //Timer _end;

//   _ReceptionsPageState(String line_location_id, String orden_compra) {
//     this.line_location_id = line_location_id;
//     this.orden_compra = orden_compra;
//   }

// static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
// //Carga los datos requeridos por el id_articulo
// Future<List> getAllData() async {
//   BarcodeScanner.scan();
//   print("LINE LOCATION: ${line_location_id}");
//   print("ORDEN DE COMPRA: ${orden_compra}");

//     final response = await http.post("http://192.168.0.167/sistemas_contino/portal_lecturas/YA_NO/app_movil_inventario/utils/getLine.php", 
//       body: {
//         "activation": 'confirm',
//         "line_location_id": line_location_id,
//       },
//       headers: {
//         "Accept": "application/json"
//       }
//     );

//     print('body obtener lineas: [${response.body}]');
//     if(response.body.isEmpty) {
//       print ("vacio petición getLine archivo Recepctions");
//     }

//     final getSeries = await http.post("http://192.168.0.167/sistemas_contino/portal_lecturas/YA_NO/app_movil_inventario/utils/seriesGetter.php", 
//       body: {
//         "activation": 'confirm',
//         "line_location_id": line_location_id,
//         "num_oc": orden_compra,
//       },
//       headers: {
//         "Accept": "application/json"
//       }
//     );

//     print('body SeriesGetter: [${getSeries.body}]');

//     //Variable data decodifica el json y almacena su contenido
//     this.setState(() {
//       data = JSON.jsonDecode(response.body);
//     });

//     print ("el json decodificado es $data");

//     flagLine = JSON.jsonDecode(getSeries.body);
//     if(flagLine[0]["status"] == "error"){
//       for(var index = 0; index < int.parse(data[0]["CANT_PENDIENTE"]); index++){

//         var line = {
//           'id': '${line_location_id}${index}',
//           'serie':'',
//           'status':'pending',
//           'line_location_id': line_location_id,
//           'num_oc': orden_compra
//         };
//         this.setState(() {
//           lines.add(line);
//         });
//       }
//     print("HOLA AQUI LINES");
//     print(test_lines);
    
//     for(var i = 0; i < lines.length; i ++){
//       if(flagCamera == 0){
//         print(lines[i]);
//         await barcodeScanning(i);
//         checkDoppler(i);
//         checkSerie(i);
//         checkFlag();
//       }else{
//         break;
//       }
//       // await saveLine();
//     }
//   }else{
//     this.setState(() {
//       lines = JSON.jsonDecode(getSeries.body);
//     });
//     checkFlag();
//   }
  
//   _isLoading = true;
//   print(lines);
//   print (data);
//   return data;
// }

// void setTime() async{
      
//   print("SETTIME DIALOGFLAG ${dialogFlag}");
      
//   const ended = const Duration(minutes:10);
//   new Timer.periodic(ended, (_end){
//     if(flagTime){
//       _end.cancel();
//       setTime();
//     }else{
//       _end.cancel();
//       if(dialogFlag == 0){
//         Navigator.pop(context);
//       }else{
//         for(var i = 0; i < dialogFlag; i ++){
//           print(dialogFlag);
//           Navigator.pop(context);
//         }
//         Navigator.pop(context);
//       }
//     }
//   }); 

//   const message = const Duration(minutes: 9);
//   new Timer(message, (){
//     showAlert("Prueba", Icons.flag);
//   });
// }


// //Cuando se inicie el módulo activa la función geData()
// @override
// void initState(){
//   super.initState();
//   this.getAllData();
//   this.setTime();
// }


// @override
// Widget build(BuildContext context) {
//   return new Scaffold(
//     appBar: new AppBar(
//       backgroundColor: Color.fromRGBO(5, 44, 99, 1),
//       title: new Text("Línea de compra ${line_location_id}"),
//       //  automaticallyImplyLeading: false,
//     ),
//     body: _isLoading ? Column(
//       children:[
//         Expanded( 
//           child: ListView.builder(
//             itemCount: data == null ? 0 : data.length,
//             physics: BouncingScrollPhysics(),
//             shrinkWrap: true,
//             itemBuilder: (BuildContext context, int index) {
//               return new ExpansionTile(
//                 initiallyExpanded: true,
//                 title: Text("Clave de producto ${data[index]["CLAVE"]}", style: TextStyle(fontWeight: FontWeight.bold),),
//                 subtitle: Text("Orden: ${data[index]['NUM_OC']}\nFecha: ${data[index]['FECHA_OC']}\nCantidad recibida: ${data[index]['CANT_PENDIENTE']}\nPrecio: ${data[index]['PRECIO']}"),
//                 children: <Widget>[
//                   ListView.builder(
//                     itemCount: lines.length,
//                     physics: BouncingScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (BuildContext context, int xindex) { 
//                       return new ListTile(
//                         title: Text("Serie"),
//                         subtitle: Text(lines[xindex]["serie"]),
//                         leading: 
//                         lines[xindex]["status"] == "pending" ? Icon(Icons.warning, color: Colors.orange,):
//                         lines[xindex]["status"] == "complete" ? Icon(Icons.check, color: Colors.green,):
//                         lines[xindex]["status"] == "incomplete" ? Icon(Icons.clear, color: Colors.red,): 
//                         Icon(Icons.done_all, color: Colors.green,),
//                         trailing: lines[xindex]["status"] == "sent" ? null: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             IconButton(
//                               icon: Icon(Icons.camera_alt),
//                               onPressed: () async{
//                                 await barcodeScanning(xindex);
//                                 checkDoppler(xindex);
//                                 checkSerie(xindex);
//                                 checkFlag();
//                                 await saveLine();
//                               }
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit),
//                               onPressed: ()async {
//                                 editSerie("Ingrese Texto", xindex);
//                                 checkDoppler(xindex);
//                                 checkSerie(xindex);
//                                 checkFlag();
//                                 await saveLine();
//                               }
//                             )
//                           ],
//                         )
//                       );
//                     },
//                   ),
//                 ],
//               );
//             }
//           )
//         ),
//         flag ? SizedBox(
//           width: double.infinity, // match_parent
//           child: RaisedButton(
//             child: Text("Sube línea de compra"),
//             onPressed: ()async {
//               await saveLine();
//               Navigator.pop(context);
//             }
//           )
//         ):
//         Text("Faltan series por insertar")
//       ]
//     ): Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(
//           valueColor: new AlwaysStoppedAnimation<Color>(
//             Colors.orange
//           )
//         ),
//       )
//     ),
//   );
// }

// Future<String> saveLine() async {
//   print(JSON.jsonEncode(lines));
//   await http.post("http://192.168.0.167/sistemas_contino/portal_lecturas/YA_NO/app_movil_inventario/utils/insertTemp.php", 
//     body: {
//       "activation": 'confirm',
//       "serie": JSON.jsonEncode(lines)
//     },
//     headers: {
//       "Accept": "application/json"
//     }
//   );
          
//   String status = await getLineStatus();
//   print(status);
//   await http.post("http://192.168.0.167/sistemas_contino/portal_lecturas/YA_NO/app_movil_inventario/utils/updateLine.php", 
//     body: {
//       "activation": 'confirm',
//       "line_location_id": line_location_id,
//       "status": status,
//     },
//     headers: {
//       "Accept": "application/json"
//     }
//   );
//   return "SUCCESS";
// }

// Future<String> getLineStatus () async{
//   String status = "";
//   int counter = 0;
//   for(var i = 0; i < lines.length; i++){
//     if(lines[i]["status"] == "pending"){
//       counter++;
//     }
//   }
//   if(counter == 0){
//     status = "complete";
//   }else{
//     status = "pending";
//   }


//   return status;
// }

// Future barcodeScanning(int index) async {
//   try {
//     ScanResult barcode = await BarcodeScanner.scan();
//     setState((){
//       this.lines[index]["serie"] = barcode.rawContent;
//       this.lines[index]["status"] = "complete";
//       checkDoppler(index);
//       checkSerie(index);
//       checkFlag();
//     });
//     this.setState(() {});
//   } on PlatformException catch (e) {
//     if (e.code == BarcodeScanner.cameraAccessDenied) {
//       setState(() {
//         this.lines[index]["serie"] = '';
//         flagCamera ++;
//       });
//     } else {
//       setState((){
//         this.lines[index]["serie"] = 'Error: $e';
//         flagCamera ++;
//       });
//     }
//   } on FormatException {
//     setState((){
//       this.lines[index]["serie"] = '';
//       flagCamera ++;
//     });
//   } catch (e) {
//     setState(() => this.lines[index]["serie"] = 'Error: $e');
//   }
// }
         
// void editSerie(String content, int index){
//   checkDoppler(index);
//   checkSerie(index);
//   checkFlag();
//   var _controller = TextEditingController(text: lines[index]["serie"].toString());

//   showDialog(
//     context: context,
//     builder: (BuildContext context){
//       return new AlertDialog(
//         title: new Text("Ingresar serial"),
//         content: new Row(
//           children: <Widget>[
//             new Expanded(
//               child: new TextField(
//                 controller: _controller,
//                 autofocus: true,
//                 decoration: new InputDecoration(
//                   labelText: 'Número de serie', hintText: "Ingrese número de serie"),
//               ),
//             )
//           ],
//         ),
//         actions: <Widget>[
//           new FlatButton(
//             child: const Text('Cancelar'),
//             onPressed: () {
//               Navigator.pop(context);
//             }
//           ),
//           new FlatButton(
//             child: const Text('Agregar'),
//             onPressed: () {
//               setState((){
//                 this.lines[index]["serie"] = _controller.value.text;
//                 if(_controller.value.text.trim() == "" ){
//                   this.lines[index]["status"] = "pending";
//                 }else{
//                   this.lines[index]["status"] = "complete";
//                 }
//                 checkDoppler(index);
//                 checkSerie(index);
//                 checkFlag();
//               }); 
//               Navigator.pop(context);
//             }
//           )
//         ],
//       );
//     }
//   );
// }
                                                               
// void checkFlag() async {
//   var check = 0;
//   for(var i = 0; i < lines.length; i ++){
//     if(lines[i]["status"] == "incomplete"){
//       check++;
//     }
//   }
//   print(check);
//   if(check == 0){
//     print("Todos validados");
//     setState((){
//       this.flag = true;
//     }); 
//   }else{
//     print("Falta validar");
//     setState((){
//       this.flag = false;
//     }); 
//   }
//   await saveLine();
// }
          
// void checkSerie(int index) {
//   if(lines[index]["serie"].toString().trim()=="" || lines[index]["serie"].toString().trim()== null){
//     setState((){
//       this.lines[index]["status"] = "pending";
//     }); 
//   }else{
//   }
// }
          
// void checkDoppler(int index) {
//   List<dynamic> dopplers = List<dynamic>();
//   List<dynamic> notDopplers = List<dynamic>();
//   for(var i = 0; i < lines.length; i++){
//     for(var xx = 0; xx < lines.length; xx++){
//       if(xx != i){
//         if(lines[i]["serie"] == lines[xx]["serie"] && lines[i]["serie"].trim() != "" && lines[xx]["serie"].trim() != ""){
//           dopplers.add(i);
//           setState((){
//             if (lines[xx]["status"] != "sent"){
//               print ("entra a donde el status es Sent");
//               this.lines[xx]["status"] = "sent";
//               this.lines[i]["status"] = "incomplete";
//             } else {
//               print ("Entra donde el status es diferente de sent");
//               this.lines[xx]["status"] = "incomplete";
//               this.lines[i]["status"] = "incomplete";
//             }
//           }); 
//         }else{
//           notDopplers.add(i);
//         }
//       }
//     }
//   }
      
//   List<int> result = LinkedHashSet<int>.from(dopplers).toList();
//   List<int> result2 = LinkedHashSet<int>.from(notDopplers).toList();
//   arrayDiff(List dopplers, List notDopples){
//     dopplers..retainWhere((i){
//       print("TIENE ${i}");
//       if(!notDopples.contains(i)){
//         print("NO TIENE ${i}");
//         setState((){
//           if(lines[i]["serie"].trim() != "" && lines[i]["status"] != "sent"){
//             this.lines[i]["status"] = "complete";
//           }
//         }); 
//       }
//     }); 
//   } 
//   print(arrayDiff(result2, result));
// }

// void showAlert(String content, IconData icon) async {
//   this.setState((){
//     dialogFlag ++;
//       flagTime = false;
//       print(" DA DE DIALOGFLAG ${dialogFlag}");
//     });

//     showDialog(
//       context: context,
//       builder: (BuildContext context){
//         return new CupertinoAlertDialog(
//           title: new Icon(icon),
//           content: new Container(
//             child: Column(
//               children: <Widget>[
//                 RaisedButton(
//                   child: Text("Continuar"),
//                   onPressed: () async {
//                     await http.post("http://192.168.0.167/sistemas_contino/portal_lecturas/YA_NO/app_movil_inventario/utils/setActivityTime.php", 
//                       body: {
//                         "activation": 'confirm',
//                         "line_location_id": line_location_id,
//                       },
//                       headers: {
//                         "Accept": "application/json"
//                       }
//                     );
//                     this.setState((){
//                       flagTime = true;
//                     });
//                     Navigator.pop(context);
//                   },
//                 )
//               ],
//             )
//           )
//         );
//       }
//     ).then((value) async {
//       dialogFlag--;
//       print("SALIDA DE DIALOGFLAG ${dialogFlag}");
//       this.setState((){
//         flagTime = true;
//       });
//     });
//   }
// }


// class Receptions extends StatelessWidget {
//   Receptions({Key key, this.line_location_id,this.orden_compra,}) : super(key: key);
//   final String line_location_id;
//   final String orden_compra;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: ReceptionsPage(
//         line_location_id: line_location_id,
//         orden_compra: orden_compra
//         ),
//     );
//   }
// }
