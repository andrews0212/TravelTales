
class Viaje {

  int? id;
  String _destino;
  DateTime _fecha_inicio;
  DateTime _fecha_fin;
  String _ubicacion;
  int _calificacionViaje;


  Viaje.withId(this.id, this._destino, this._fecha_inicio, this._fecha_fin,
      this._ubicacion, this._calificacionViaje);

  Viaje({
    this.id,
    required String destino,
    required DateTime fecha_inicio,
    required DateTime fecha_fin,
    required String ubicacion,
    required int calificacionViaje}) :_destino = destino, _fecha_inicio = fecha_inicio, _fecha_fin = fecha_fin, _ubicacion = ubicacion, _calificacionViaje = calificacionViaje;


  int get calificacionViaje => _calificacionViaje;

  set calificacionViaje(int value) {
    _calificacionViaje = value;
  }

  String get ubicacion => _ubicacion;

  set ubicacion(String value) {
    _ubicacion = value;
  }

  DateTime get fecha_fin => _fecha_fin;

  set fecha_fin(DateTime value) {
    _fecha_fin = value;
  }

  DateTime get fecha_inicio => _fecha_inicio;

  set fecha_inicio(DateTime value) {
    _fecha_inicio = value;
  }

  String get destino => _destino;

  set destino(String value) {
    _destino = value;
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "destino": destino,
      "fecha_inicio": fecha_inicio,
      "fecha_fin": fecha_fin
    };
  }

  @override
  String toString() {
    return 'Viaje{id: $id, _destino: $_destino, _fecha_inicio: $_fecha_inicio, _fecha_fin: $_fecha_fin, _ubicacion: $_ubicacion, _calificacionViaje: $_calificacionViaje}';
  }


}
