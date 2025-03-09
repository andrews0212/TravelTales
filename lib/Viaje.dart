import 'dart:convert';

class Viaje {
  int? id;
  String destino;
  DateTime fecha_inicio;
  DateTime fecha_fin;
  String ubicacion;
  String calificacionViaje;
  List<String> viajes;
  bool favorito;
  

  Viaje({
    this.id,
    required this.destino,
    required this.fecha_inicio,
    required this.fecha_fin,
    required this.ubicacion,
    required this.calificacionViaje,
    required this.viajes,
      required this.favorito,
    });
  


  // Método para convertir un objeto 'Viaje' a un mapa para insertarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destino': destino,
      'fecha_inicio': fecha_inicio.toIso8601String(),  // Convierte DateTime a String
      'fecha_fin': fecha_fin.toIso8601String(),        // Convierte DateTime a String
      'ubicacion': ubicacion,
      'calificacionViaje': calificacionViaje,
      'favorito': favorito,
    };
  }

  // Método para convertir un mapa de la base de datos a un objeto 'Viaje'
 factory Viaje.fromMap(Map<String, dynamic> map) {
    return Viaje(
      id: map['id'],
      destino: map['destino'] ?? 'Desconocido', // Valor por defecto si es null
      fecha_inicio: map['fecha_inicio'] != null
          ? DateTime.parse(map['fecha_inicio'])
          : DateTime.now(), // Valor por defecto si es null
      fecha_fin: map['fecha_fin'] != null
          ? DateTime.parse(map['fecha_fin'])
          : DateTime.now(), // Valor por defecto si es null
      ubicacion: map['ubicacion'] ?? 'No especificada', // Valor por defecto si es null
      calificacionViaje: map['calificacionViaje'], // Valor por defecto si es null
      viajes: List<String>.from(map['viajes'] ?? []), // Valor por defecto si es null
      favorito: map['favorito'] == 1, // Convierte 0 o 1 a booleano
    );
 }
}