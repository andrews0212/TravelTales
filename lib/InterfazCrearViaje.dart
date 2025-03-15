import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_tales/SQL_Herper.dart';
import 'package:travel_tales/Viaje.dart';

class InterfazCrearViaje extends StatefulWidget {
  final Function actualizarViajes; // Callback que se usará para actualizar la lista en el Main

  const InterfazCrearViaje({super.key, required this.actualizarViajes});
  

  @override
  State<InterfazCrearViaje> createState() => _InterfazCrearViajeState();

}

class _InterfazCrearViajeState extends State<InterfazCrearViaje> {
  final _destinoController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _calificacionController = TextEditingController();

  late final List<String> _Photos = [];
  String? _photoPath;
  final SQL_Helper sql_helper = SQL_Helper();


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Viaje', style: TextStyle(color: Color(0xFF1C5A45))),backgroundColor: Color(0xFF9CEAEF)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _destinoController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Inicio',
                ),
                onTap: () async {
                  DateTime? selectedDate = await _selectDate(context);
                  if (selectedDate != null) {
                    _fechaInicioController.text =
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate
                        .year}";
                  }
                },
                controller: _fechaInicioController,
                readOnly: true, // Para evitar que el usuario escriba directamente
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Fin',
                ),
                onTap: () async {
                  DateTime? selectedDate = await _selectDate(context);
                  if (selectedDate != null) {
                    _fechaFinController.text =
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate
                        .year}";
                  }
                },
                controller: _fechaFinController,
                readOnly: true, // Para evitar que el usuario escriba directamente
              ),
              TextField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                ),
              ),
             TextField(
              controller: _calificacionController, // Ahora tiene un controlador
              decoration: const InputDecoration(
                labelText: 'Calificación',
              ),
              keyboardType: TextInputType.number, // Para restringir la entrada a números
              ),

              SizedBox(height: 20),
              Text("Añadir fotos:"),
              mostrarLista(),
              SizedBox(height: 20),

               TextButton(
                child: Text("Eliminar Todos"),
                onPressed: () {
                  setState(() => _Photos.clear());

                },      
                ),
            
            ],
          ),
        ),
      ),
    
    
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        FloatingActionButton(
        heroTag: 'fabImagen',
        child: const Icon(Icons.image),
        onPressed: () async {
          final path = await CameraGalleryService().selectPhoto();
          if (path == null) return;
          setState(() => _Photos.add(path));
        },
      ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'fabCamara',
            child: const Icon(Icons.camera_alt),
            onPressed: () async {
              final path = await CameraGalleryService().takePhoto();
              if (path == null) return;

              setState(() => _Photos.add(path));
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(child: Icon(Icons.save),onPressed: (){
          List<int> fechaInicio = _fechaInicioController.text.split("/").map((e) => int.parse(e)).toList();
          List<int> fechaFin = _fechaFinController.text.split("/").map((e) => int.parse(e)).toList();

          DateTime inicio = DateTime(fechaInicio[2], fechaInicio[1], fechaInicio[0]);
          DateTime fin = DateTime(fechaFin[2], fechaFin[1], fechaFin[0]);

          print("$inicio   $fin" );

            
              sql_helper.insertViaje(Viaje(
                destino: _destinoController.text,
                fecha_inicio: inicio,
                fecha_fin: fin,
                ubicacion: _ubicacionController.text,
                calificacionViaje: _calificacionController.text,
                viajes: _Photos,
                favorito: false));
                
          })
          
        ],
      ),
          
    );
    
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      firstDate: DateTime(2020), // Ahora permite fechas anteriores
      lastDate: DateTime(2030), // Un rango válido
      initialDate: DateTime.now(),
    );
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      firstDate: DateTime(2020), // Ahora permite fechas anteriores
      lastDate: DateTime(2030), // Un rango válido
      initialDate: DateTime.now(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('_Photos', _Photos));
  }
  
 Widget mostrarLista() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row( // Usamos Row en lugar de ListView.builder
      children: _Photos.map((photoPath) {
        int index = _Photos.indexOf(photoPath); // Obtener el índice de cada foto
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Image.file(File(photoPath), width: 100, height: 100), // Ajusta el tamaño de la imagen si es necesario
              IconButton(
                onPressed: () {
                  setState(() {
                    _Photos.removeAt(index); // Usar removeAt() para eliminar por índice
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}


}


  class CameraGalleryService {

    final ImagePicker _picker = ImagePicker();

    Future<String?> selectPhoto() async {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null) return null;
    
      return photo.path;
    }

    Future<String?> takePhoto() async {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null) return null;

      return photo.path;
    }

  
   
  }