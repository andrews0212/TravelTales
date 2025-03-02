import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_tales/InterfazCrearViaje.dart';

import 'SQL_Herper.dart';
import 'Viaje.dart';

void main() {
  sqfliteFfiInit(); // Inicializa sqflite_ffi
  databaseFactory = databaseFactoryFfi; // Establece la fábrica de base de datos
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  final SQL_Helper sql_helper = SQL_Helper();
  List<Viaje> viajes = []; // Lista local en memoria

  @override
  void initState() {
    sql_helper.deleteAll();
    super.initState();
    cargarViajes(); // Cargar viajes al iniciar
  }

  void cargarViajes() async {
    final datos = await sql_helper.viajes();
    print("Viajes cargados: ${datos.length}"); // Ver cuántos viajes se cargan
    setState(() {
      viajes = datos;
    });
  }

  Widget Buscador() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1, // Ajusta el ancho según necesites
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1C5A45)),
          hintText: "Buscar",
          fillColor: Color(0xFF9CEAEF),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xFFC4FFF9),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Color(0xFF1C5A45),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.all_inbox, color: Color(0xFFC4FFF9),),
            icon: Icon(Icons.all_inbox),
            label: 'Todos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite, color: Color(0xFFC4FFF9),),
            icon: Badge(child: Icon(Icons.favorite)),
            label: 'Favoritos',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFC4FFF9),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0), // Grosor de la línea
          child: Container(
            color: Colors.black.withOpacity(0.5), // Color de la línea
            height: 2.0, // Grosor de la línea
          ),
        ),
        actions: <Widget>[Buscador()],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: mostrarListaCard(), // Cambiado para mostrar el GridView
            ),
          ],
        ),
      ),
    );
  }

  Widget mostrarListaCard() {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.1, // Ajusta la proporción según necesites
      ),
      itemCount: viajes.length + 1, // Siempre hay una tarjeta extra para añadir
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // Primera tarjeta: botón para añadir un viaje
          return cartaAddViaje();
        }
        // Tarjetas de viajes
        final viaje = viajes[index - 1]; // Restamos 1 porque el primer índice es la tarjeta de añadir
        return Container(
          decoration: styleViajeCard(viaje),
          child: Card(
            color: Colors.transparent, // Hace que la Card sea transparente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.5), // Fondo negro transparente
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          viaje.destino,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text("Desde: ${viaje.fecha_inicio.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        Text("Hasta: ${viaje.fecha_fin.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        Text("Ubicación: ${viaje.ubicacion}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        Text("Calificación: ${viaje.calificacionViaje}/5", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () async {
                            await sql_helper.deleteViaje(viaje);
                            cargarViajes(); // Recargar los viajes después de la eliminación
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    
  }

  styleViajeCard(Viaje viaje) {
    return BoxDecoration(
      color: Colors.blue.shade100, // Color de fondo
      borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
      image: DecorationImage(
        image: FileImage(File(viaje.viajes[0])), // Asegúrate de que la ruta de la imagen sea válida
        fit: BoxFit.cover, // Ajusta la imagen para que cubra toda la tarjeta
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  Widget cartaAddViaje() {
    return Card(
      color: Color.fromARGB(255, 156, 234, 239),
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            // Al hacer clic en la tarjeta de añadir, se abre la pantalla para crear un viaje
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InterfazCrearViaje(actualizarViajes: cargarViajes),
              ),
            );
            cargarViajes(); // Recargar los viajes al regresar
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.black, size: 50),
              SizedBox(height: 10),
              Text(
                "Añadir Viaje",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
