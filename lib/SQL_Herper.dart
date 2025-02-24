import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Viaje.dart';
class SQL_Herper{

  Future<Database> getConetion() async {
    return openDatabase(
        join(await getDatabasesPath(), 'doggie_database.db'),
        onCreate: (db, version) {
          return db.execute(
            '''CREATE TABLE Viaje (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              destino TEXT NOT NULL,
              fecha_inicio TEXT NOT NULL,
              fecha_fin TEXT NOT NULL,
              ubicacion TEXT NOT NULL,
              calificacionViaje INTEGER NOT NULL
          );'''
      );}
    );
  }
  Future<List<Viaje>> viajes() async {
    // Get a reference to the database.
    final db = await getConetion();

    // Query the table for all the dogs.
    final List<Map<String, Object?>> viajeMap = await db.query('Viaje');

    // Convert the list of each dog's fields into a list of `Dog` objects.
    return [for (final {"id": _id as int, "destino": _destino as String,
                        "fecha_inicio": _fecha_inicio as DateTime, "fecha_fin": _fecha_fin as DateTime,
                        "ubicacion": _ubicacion as String, "calificacionViaje": _calificacionViaje as int}
                        in viajeMap)
       Viaje(id: _id, destino: _destino, fecha_inicio: _fecha_inicio, fecha_fin: _fecha_fin, ubicacion: _ubicacion, calificacionViaje: _calificacionViaje)
    ];
  }
  // Define a function that inserts dogs into the database
  Future<void> insertViaje(Viaje viaje) async {

    final db = await getConetion();

    await db.insert(
      'Viaje',
      viaje.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}

