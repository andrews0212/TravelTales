import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InterfazCrearViaje extends StatefulWidget {
  const InterfazCrearViaje({super.key});

  @override
  State<InterfazCrearViaje> createState() => _InterfazCrearViajeState();

  void cambiarVentana(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const InterfazCrearViaje(),
      ),
    );
  }
}

class _InterfazCrearViajeState extends State<InterfazCrearViaje> {
  final _destinoController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _calificacionController = TextEditingController();
  late List<String> _Photos = [];
  String? _photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Viaje')),
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
                decoration: const InputDecoration(
                  labelText: 'Calificación',
                ),
              ),
              SizedBox(height: 20),
              Text("Añadir fotos:"),
             
              SizedBox(height: 20),
              Column(
                  children: [
                    SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: 
                    Row(
                      children: [
                        for (final photo in _Photos)
                          Column(
                            children: [
                            Image.file(File(photo), width: 200, height: 200),
                            ],
                          )
                          
                      ],
                    ),
                  ),
                  ],
                ),
               IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
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

    void cambiarVentana(BuildContext context) {
      print("Cambiando de ventana...");
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const InterfazCrearViaje(),
        ),
      );
    }
  }


