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
              FutureBuilder(
                future: sql_helper.getConnection(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return mostrarLista(context);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  sql_helper.insertViaje(new Viaje(
                    destino: "destino",
                    fecha_inicio: DateTime.now(),
                    fecha_fin: DateTime.now(),
                    ubicacion: "ubicacion",
                    calificacionViaje: 5,
                  ));
                  setState(() {});
                },

                child: Text("añadir"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  mostrarLista(BuildContext context) {
    return FutureBuilder(
      future: sql_helper.viajes(),
      builder: (BuildContext context, AsyncSnapshot<List<Viaje>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Container(
              height: 300, // Establece un tamaño fijo para el ListView
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data![index].destino),
                    subtitle: Text(snapshot.data![index].fecha_inicio.toString()),
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
