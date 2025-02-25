import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Viaje.dart';

class SQL_Helper {
  Database? _database;

  Future<Database> getConnection() async {
    final database = await openDatabase(
      'travel_tales.db',
      version: 2,
      onCreate: (Database db, int version) async {
        // Asegúrate de que la tabla 'viajes' se crea correctamente
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
    return database;
  }

  Future<List<Viaje>> viajes() async {
    final Database db = await getConnection();

    // Realiza la consulta SELECT
    final List<Map<String, dynamic>> maps = await db.query('viajes');

    // Convierte cada mapa en un objeto 'Viaje' y lo devuelve como una lista
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
    if (db != null) {
      await db.delete('viajes');
    }
  }

}