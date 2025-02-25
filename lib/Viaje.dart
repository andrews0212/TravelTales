class Viaje {
  String destino;
  DateTime fecha_inicio;
  DateTime fecha_fin;
  String ubicacion;
  int calificacionViaje;

  Viaje({
    required this.destino,
    required this.fecha_inicio,
    required this.fecha_fin,
    required this.ubicacion,
    required this.calificacionViaje,
  });

  // Método para convertir un objeto 'Viaje' a un mapa para insertarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'destino': destino,
      'fecha_inicio': fecha_inicio.toIso8601String(),  // Convierte DateTime a String
      'fecha_fin': fecha_fin.toIso8601String(),        // Convierte DateTime a String
      'ubicacion': ubicacion,
      'calificacionViaje': calificacionViaje,
    };
  }

  // Método para convertir un mapa de la base de datos a un objeto 'Viaje'
  static Viaje fromMap(Map<String, dynamic> map) {
    return Viaje(
      destino: map['destino'],
      fecha_inicio: DateTime.parse(map['fecha_inicio']), // Convierte el String de vuelta a DateTime
      fecha_fin: DateTime.parse(map['fecha_fin']),       // Convierte el String de vuelta a DateTime
      ubicacion: map['ubicacion'],
      calificacionViaje: map['calificacionViaje'],
    );
  }
}
