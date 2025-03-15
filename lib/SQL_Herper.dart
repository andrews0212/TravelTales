import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Viaje.dart';

class SQL_Helper {
  Database? _database;
  final String CREATE_TABLE = "CREATE TABLE viajes(id INTEGER PRIMARY KEY AUTOINCREMENT,destino TEXT,fecha_inicio TEXT,fecha_fin TEXT,ubicacion TEXT,calificacionViaje TEXT,viajes TEXT,favorito BOOLEAN)";
 Future<Database> getConnection() async {
  if (_database != null) return _database!;

  // Obtener el directorio de la base de datos
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'travel_tales.db');

  // Abrir la base de datos con migración
  _database = await openDatabase(
    path,
    version: 5, // 🚨 Aumenta la versión
    onCreate: (Database db, int version) async {
      await db.execute(CREATE_TABLE);
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 5) {
        await db.execute("DROP TABLE IF EXISTS viajes");
        await db.execute(CREATE_TABLE);
      }
    },
  );
  return _database!;
}
Future<List<Viaje>> getFavoritos() async {
  final Database db = await getConnection();
  final List<Map<String, dynamic>> maps = await db.query(
    'viajes',
    where: 'favorito = ?',
    whereArgs: [1],  // 1 representa true en SQLite
  );

  return List.generate(maps.length, (i) {
    List<String> viajesList = maps[i]['viajes'] != null ? maps[i]['viajes'].split(',') : [];
    return Viaje.fromMap({...maps[i], 'viajes': viajesList});
  });
}

Future<List<Viaje>> viajes() async {
  final Database db = await getConnection();
  final List<Map<String, dynamic>> maps = await db.query('viajes');
  
  return List.generate(maps.length, (i) {
    // Convertir la cadena 'viajes' en una lista
    List<String> viajesList = maps[i]['viajes'] != null ? maps[i]['viajes'].split(',') : []; // Si es null, asignar una lista vacía

    // Pasamos la lista 'viajesList' al constructor de Viaje
    return Viaje.fromMap({...maps[i], 'viajes': viajesList, // Aquí asignamos la lista obtenida
    });
  });
}

Future<void> insertViaje(Viaje viaje) async {
  final Database db = await getConnection();
  
  // Inserta el viaje en la base de datos sin el campo 'id'
  int id = await db.insert(
    'viajes',
    {
      'destino': viaje.destino,
      'fecha_inicio': viaje.fecha_inicio.toIso8601String(),
      'fecha_fin': viaje.fecha_fin.toIso8601String(),
      'ubicacion': viaje.ubicacion,
      'calificacionViaje': viaje.calificacionViaje,
      'viajes': viaje.viajes.join(','),  // Convierte la lista en una cadena separada por comas
      'favorito': viaje.favorito ? 1 : 0  // Convertir booleano a entero
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  // Asigna el id generado al objeto viaje
  viaje.id = id;  // Asigna el id generado por SQLite
}
Future<void> updateViaje(Viaje viaje) async {
  final Database db = await getConnection();
  
  await db.update(
    'viajes',
    {
      'destino': viaje.destino,
      'fecha_inicio': viaje.fecha_inicio.toIso8601String(),
      'fecha_fin': viaje.fecha_fin.toIso8601String(),
      'ubicacion': viaje.ubicacion,
      'calificacionViaje': viaje.calificacionViaje,
      'viajes': viaje.viajes.join(','),  // Convierte la lista en una cadena separada por comas
      'favorito': viaje.favorito ? 1 : 0  // Convertir booleano a entero
    },
    where: 'id = ?',
    whereArgs: [viaje.id],  // Usar el id del viaje
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


Future<void> deleteViaje(Viaje viaje) async {
  final Database db = await getConnection();
  
  // Usar el id del objeto 'viaje' para eliminar el registro correspondiente
  await db.delete(
    'viajes',
    where: 'id = ?',
    whereArgs: [viaje.id],  // Usar el id del viaje
  );
}

  Future<void> deleteAll() async {
    final db = await getConnection();
    await db.delete('viajes');
    }


}