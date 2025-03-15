import 'dart:io';
import 'package:flutter/material.dart';
import 'Viaje.dart';

class DetalleViaje extends StatefulWidget {
  final Viaje viaje;

  const DetalleViaje({super.key, required this.viaje});

  @override
  _DetalleViajeState createState() => _DetalleViajeState();
}

class _DetalleViajeState extends State<DetalleViaje> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viaje.destino),
        backgroundColor: const Color(0xFF1C5A45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.viaje.destino,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Ubicación: ${widget.viaje.ubicacion}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Fecha de Inicio: ${widget.viaje.fecha_inicio.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Fecha de Fin: ${widget.viaje.fecha_fin.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Calificación: ${widget.viaje.calificacionViaje}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.viaje.viajes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (widget.viaje.viajes[0] != "") {
                        return FittedBox(
                          fit: BoxFit.cover,
                          child: Image.file(File(widget.viaje.viajes[index])),
                        );
                      } else {
                        return const SizedBox.shrink(); // No mostrar nada si no hay imágenes
                      }
                    },
                  ),
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (_currentIndex < widget.viaje.viajes.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}