import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        childAspectRatio: 1 / 1.5, // Ajusta la proporción según necesites
      ),
      itemCount: viajes.length + 1, // Siempre hay una tarjeta extra para añadir
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // Primera tarjeta: botón para añadir un viaje
          return Card(
            color: new Color.fromARGB(194, 0, 0, 0),
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {




                  // await sql_helper.insertViaje(Viaje(
                  //     id: viajes.isEmpty ? 1 : viajes.last.id! + 1, // Asegura un ID único
                  //     destino: "Nuevo Destino",
                  //     fecha_inicio: DateTime.now(),
                  // fecha_fin: DateTime.now().add(Duration(days: 5)),
                  // ubicacion: "Ubicación Ejemplo",
                  // calificacionViaje: 4,
                  // ));
                  // cargarViajes();
                },

                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(Icons.add, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Añadir Viaje",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          );
        }

        // Tarjetas de viajes
        final viaje = viajes[index - 1]; // Restamos 1 porque el primer índice es la tarjeta de añadir
        return Card(
          color: Colors.white,
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
                Text("Desde: ${viaje.fecha_inicio.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center),
                Text("Hasta: ${viaje.fecha_fin.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center),
                Text("Ubicación: ${viaje.ubicacion}", textAlign: TextAlign.center),
                Text("Calificación: ${viaje.calificacionViaje}/5", textAlign: TextAlign.center),
                IconButton(
                  onPressed: () async {
                    await sql_helper.deleteViaje(viaje.id);
                    cargarViajes();
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
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
                cargarViajes();
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