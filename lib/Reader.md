# Como Hacer una lista con una BD


```dart

class _MyHomePageState extends State<MyHomePage> {
// Primero lo que hacemos en en nuestro Pagina declarar el SQL_HELPER y La lista estatica
// de Viaje
  final SQL_Helper sql_helper = SQL_Helper();
  List<Viaje> viajes = []; // Lista local en memoria

// Luego sobreescribimos nuestro metodo initState() para poder cargar los viajes cuando
// se inicia

  @override
  void initState() {
    super.initState();
    cargarViajes(); // Cargar viajes al iniciar
  }

// Tenemos este metodo donde cargamos los viajes
// este cuenta con la variable datos que es una lista de todos los viajes
y lo actualizamos con el setState() para actualizar nuestra lista local

  void cargarViajes() async {
    final datos = await sql_helper.viajes();
    print("Viajes cargados: ${datos.length}"); // Debug
    setState(() {
      viajes = datos;
    });
  }

```

Luego en nuestro Body llamamos a este metodo

```dart
body: Center(
        child: Column(
          children: [
            Expanded(
              child: mostrarListaCard(), // Cambiado para mostrar el GridView
            ),
          ],
        ),
      ),
```

Nuestra lista esta conformada de esta forma

```dart



 Widget mostrarListaCard() {

// primero lo que hacemos es retornar nuestro gridView
// es importante colocarlo con el .Builder

    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.1, // Ajusta la proporción según necesites
      ),

      itemCount: viajes.length + 1, // Siempre hay una tarjeta extra para añadir

// aqui en el item builder es importate colocar lo que queremos que se vaya agregando a 
// nuestra lista. En este caso lo que he hecho primero agregar una carta por defecto que
// es la que se va a encargar de añadir los viajes

      itemBuilder: (BuildContext context, int index) {

        if (index == 0) {
          // Primera tarjeta: botón para añadir un viaje
          return Card(
            color: Color.fromARGB(255,156, 234, 239),
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

                        InterfazCrearViaje().cambiarVentana(context);

                  await sql_helper.insertViaje(Viaje(
                      id: viajes.isEmpty ? 1 : viajes.last.id! + 1, // Asegura un ID único
                      destino: "Nuevo Destino",
                      fecha_inicio: DateTime.now(),
                  fecha_fin: DateTime.now().add(Duration(days: 5)),
                  ubicacion: "Ubicación Ejemplo",
                  calificacionViaje: 4,

                  ));

                  cargarViajes();
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

	// aqui lo mismo que el anterior seguimos funcionando con el itemBuilder porque 
	// todo lo de arriba esta funcionando con la condicional de si no hay ninguna

        // Tarjetas de viajes
	// esto es el idex de viaje que lo va a consultar en nuestra lita para ir añadiento
        final viaje = viajes[index - 1]; // Restamos 1 porque el primer índice es la tarjeta de añadir

	// return de lo que vamos a añadir
	// Retornara cada carta por viaje que tengamos
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
```

# SQLITE Con Dart

```dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Viaje.dart';

// Primero creamos una clase SQL_HELPER

class SQL_Helper {

// Esta Tiene como propiedad un Objeto Database que puede ser nulo y es privado 
	Database? _database;

//  Luego tenemos una funtion donde retorna un objeto Future con la DataBase async
//  Los Future Son instancia de la clase Future de dart que representa los resultado de una operacion asincrona que nos devuelve dos estados:
//  completado y no completado, Ejemplo de como funciona: Es como si montaramos un agua a calentar en una tetera, podemos hacer diferentes cosas
//  mietra esta calienta y esta nos avisara cuando este ya caliente el agua.

// Funciona como los Thread en java 

// Se puede utiliza cuando utilizamos datos de servicio de internet y como en este caso como la bd

// En este metodo lo que hacemos es devolver la conexion de la bd
  Future<Database> getConnection() async {
    if (_database != null) return _database!;

    // Aqui pedimos la ruta donde la aplicacion puede guardar  y recuperar archivo
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Aqui obtenemos la ruta uniendo la bd con el documentDirectory
    String path = join(documentsDirectory.path, 'travel_tales.db');

    // Aqui utilizamos el metodo openDatabase para establecer la conexion
    _database = await openDatabase(
   // Le pasariamos la ruta, la vercion y aplicacon el db.execute para crear la tabla
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''CREATE TABLE viajes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            destino TEXT,
            fecha_inicio TEXT,
            fecha_fin TEXT,
            ubicacion TEXT,
            calificacionViaje INTEGER
          )''',
        );
      },
    );
    return _database!;
  }

  Future<List<Viaje>> viajes() async {
    final Database db = await getConnection();
    final List<Map<String, dynamic>> maps = await db.query('viajes');
    return List.generate(maps.length, (i) {
      return Viaje.fromMap(maps[i]);
    });
  }

  Future<void> insertViaje(Viaje viaje) async {
    final Database db = await getConnection();
    await db.insert(
      'viajes',
      viaje.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteViaje(int? id) async {
    final Database db = await getConnection();
    await db.delete(
      'viajes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await getConnection();
    await db.delete('viajes');
    }
}
```
