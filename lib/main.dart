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
    setState(() {
      viajes = datos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              mostrarLista(), // Usamos la lista local en memoria
              TextButton(
                onPressed: () async {
                  await sql_helper.insertViaje(
                    Viaje(
                      id: 0,
                      destino: "Nuevo destino",
                      fecha_inicio: DateTime.now(),
                      fecha_fin: DateTime.now(),
                      ubicacion: "ubicacion",
                      calificacionViaje: 5,
                    ),
                  );
                  cargarViajes(); // Solo actualizamos la lista sin redibujar todo
                },
                child: Text("Añadir"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
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
