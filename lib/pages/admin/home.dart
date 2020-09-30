import 'package:almacen/pages/admin/registers.dart';
import 'package:almacen/pages/admin/logout.dart';
import 'package:almacen/utils/colors.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key key, this.selected}) : super(key: key);
  final int selected;


  @override
  _AdminHomePage createState() => _AdminHomePage(selected);
}

class _AdminHomePage extends State<AdminHomePage> {
  List data;
  int selected;

  _AdminHomePage(int selected){
    this.selected = selected;
  }
int _selectedIndex;
void getSelected() async {
this.setState(() {
      _selectedIndex = selected;
    });
}

@override
  void initState() {
    super.initState();
    this.getSelected();
  }
//Lista de clases contenidas en el BottomNavigationBarItem
// static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
static const List<Widget> _widgetOptions = <Widget>[
  // Orders(),
  RegistersPage(),
  Logout()
  // OrdersTest(),
  // Logout(),
];
//Cambia de módulo cada que se presiona algún elemento de BottomNavigationBarItem
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
//Crea el BottomNavigationBarItem mostrando su título y un ícono por cada elemento 
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: _widgetOptions.elementAt(_selectedIndex),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: ColorsStyle.continoPrimary,
      unselectedItemColor: Color.fromRGBO(120, 120, 120, 1),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text('Registros'),
          backgroundColor: ColorsStyle.continoPrimary,              
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.exit_to_app),
          title: Text('Perfil'),
          backgroundColor: ColorsStyle.continoPrimary,
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      onTap: _onItemTapped,
    ),
  );
}
}
