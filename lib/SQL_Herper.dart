import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Viaje.dart';

class SQL_Helper {
  Database? _database;

  Future<Database> getConnection() async {
    if (_database != null) return _database!;

    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'travel_tales.db');

    // Open the database
    _database = await openDatabase(
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
    if (db != null) {
      await db.delete('viajes');
    }
  }
}