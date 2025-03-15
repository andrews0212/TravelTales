class Validaciones {

static bool InicioFin(DateTime dateTimeInicio, DateTime datetimeFinal){

  return dateTimeInicio.isAfter(datetimeFinal);
}

static bool calificacion(String calificacion){

  var value = int.tryParse(calificacion);
  if (value == null){
    return true;
  }else{
    return false;
  }
}

static bool clificacionRango(String calificacion){
   int value = int.parse(calificacion);
   if (value > 10){
      return true;
   }else{
      return false;
   }
}



}