import 'package:almacen/pages/user/logout.dart';
import 'package:almacen/pages/user/orders.dart';
import 'package:almacen/utils/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.selected}) : super(key: key);
  final int selected;


  @override
  _HomePage createState() => _HomePage(selected);
}

class _HomePage extends State<HomePage> {
  List data;
  
  int selected;

  _HomePage(int selected){
    this.selected = selected;
  }
int _selectedIndex;
//Se llama cuando se invoca la pantalla de Home que recibe el módulo que se requiere y toma el valor para mostrar el módulo cada que se llame Home
/*
0 = Equipos
1 = Selector de Equipos
2 = Drive
3 = Pantalla de Cerrar Sesión 
*/
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
  OrdersPage(),
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
      backgroundColor: ColorsStyle.continoPrimary ,
      unselectedItemColor: Color.fromRGBO(120, 120, 120, 1),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text('Órdenes'),
          backgroundColor: ColorsStyle.continoPrimary
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.list),
        //   title: Text('Equipos2'),
        //   backgroundColor: ColorsStyle.continoPrimary
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          title: Text('Perfil'),
          backgroundColor: ColorsStyle.continoPrimary
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      onTap: _onItemTapped,
    ),
  );
}
}
