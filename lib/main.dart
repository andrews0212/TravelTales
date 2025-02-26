import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_tales/Viaje.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'SQL_Herper.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final SQL_Helper sql_helper = SQL_Helper();
  List<Viaje> viajes = []; // Lista local en memoria

  @override
  void initState() {
    super.initState();
    cargarViajes(); // Cargar viajes al iniciar
  }

  void cargarViajes() async {
    final datos = await sql_helper.viajes();
    print("Viajes cargados: ${datos.length}"); // Debug
    setState(() {
      viajes = datos;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black,
              height: 2.0,
            )),
        leading: IconButton(
          icon: Icon(Icons.home, size: 35),
          padding: EdgeInsets.only(left: 10.0),
          onPressed: () {

          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, size: 35),
            padding: EdgeInsets.only(right: 10.0),
            onPressed: () {
              cargarViajes(); // Recargar viajes
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: mostrarListaCard(), // Cambiado para mostrar el GridView
            ),
            ElevatedButton(
              onPressed: () async {
                await sql_helper.insertViaje(Viaje(
                  id: viajes.isEmpty ? 1 : viajes.last.id! + 1, // Asegura un ID único
                  destino: "Nuevo Destino",
                  fecha_inicio: DateTime.now(),
                  fecha_fin: DateTime.now().add(Duration(days: 5)),
                  ubicacion: "Ubicación Ejemplo",
                  calificacionViaje: 4,
                ));
                 cargarViajes();
                // Espera la recarga de datos
              },
              child: Text('Añadir Viaje'),
            ),
          ],
        ),
      ),

    );
  }Widget mostrarListaCard() {
    if (viajes.isEmpty) {
      return Center(child: Text('No hay viajes disponibles'));
    }
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2, // Ajusta la proporción según necesites
      ),
      itemCount: viajes.length,
      itemBuilder: (BuildContext context, int index) {
        final viaje = viajes[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viaje.destino,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text("Desde: ${viaje.fecha_inicio.toLocal()}".split(' ')[0]),
                Text("Hasta: ${viaje.fecha_fin.toLocal()}".split(' ')[0]),
                Text("Ubicación: ${viaje.ubicacion}"),
                Text("Calificación: ${viaje.calificacionViaje}/5"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget mostrarLista() {

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.3,
      child: ListView.builder(
        itemCount: viajes.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(viajes[index].destino, textAlign: TextAlign.center),
            subtitle: Text(viajes[index].fecha_inicio.toString(), textAlign: TextAlign.center),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await sql_helper.deleteViaje(viajes[index].id);
                cargarViajes(); // Eliminamos sin reconstruir todo
              },
            ),
          );
        },
      ),
    );
  }
}

class PageAddViaje extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Viaje'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondo.jpg"),
            fit: BoxFit.cover, // Ajusta la imagen al tamaño de la pantalla
          ),
        ),
        child: Center(
          child: Text("Hola, Flutter!", style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
      ),
    );
  }
}