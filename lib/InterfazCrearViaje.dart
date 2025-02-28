import 'package:flutter/material.dart';

void cambiarVentana(BuildContext context) {
  final textController = TextEditingController();

  print("Cambiando de ventana...");
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        print("Construyendo nueva pantalla...");
        return Scaffold(
          appBar: AppBar(title: const Text('Añadir Viaje')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Destino',
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Inicio',
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await selectDate(context);
                      if (selectedDate != null) {
                        textController.text =
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                      }
                    },
                    controller: textController,
                    readOnly: true, // Para evitar que el usuario escriba directamente
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Fin',
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await selectDate(context);
                      if (selectedDate != null) {
                        textController.text =
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                      }
                    },
                    controller: textController,
                    readOnly: true, // Para evitar que el usuario escriba directamente
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<DateTime?> selectDate(BuildContext context) async {
  return await showDatePicker(
    context: context,
    firstDate: DateTime(2020), // Ahora permite fechas anteriores
    lastDate: DateTime(2030),  // Un rango válido
    initialDate: DateTime.now(),
  );
}
