import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_tales/InterfazCrearViaje.dart';
import 'SQL_Herper.dart';
import 'Viaje.dart';

void main() {
  sqfliteFfiInit(); // Inicializa sqflite_ffi
  databaseFactory = databaseFactoryFfi; // Establece la fábrica de base de datos
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  final SQL_Helper sql_helper = SQL_Helper();
  List<Viaje> viajes = []; // Lista local en memoria
  List<Viaje> todosLosViajes = []; // Lista para almacenar todos los viajes

  @override
  void initState() {
    sql_helper.deleteAll();
    super.initState();
    cargarViajes(); // Cargar viajes al iniciar
  }

  void cargarViajes() async {
    final datos = await sql_helper.viajes();
    print("Viajes cargados: ${datos.length}"); // Ver cuántos viajes se cargan
    setState(() {
      viajes = datos;
      todosLosViajes = List.from(datos); // Guardamos una copia de la lista completa
    });
  }

  Widget buscador() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: TextField(
        onChanged: (value) {
          if (value.isEmpty) {
            // Restauramos la lista completa si el campo de búsqueda está vacío
            setState(() {
              viajes = List.from(todosLosViajes);
            });
          } else {
            buscarViajes(value);
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1C5A45)),
          hintText: "Buscar",
          fillColor: const Color(0xFF9CEAEF),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
        ),
      ),
    );
  }

  void buscarViajes(String query) {
    if (query.isEmpty) {
      setState(() {
        viajes = List.from(todosLosViajes); // Restauramos la lista original
      });
      return;
    }

    final input = query.toLowerCase();
    final resultados = todosLosViajes.where((viaje) {
      final destino = viaje.destino.toLowerCase();
      final ubicacion = viaje.ubicacion.toLowerCase();
      final calificacion = viaje.calificacionViaje.toString();
      final fechaInicio = viaje.fecha_inicio.toLocal().toString().split(' ')[0];
      final fechaFin = viaje.fecha_fin.toLocal().toString().split(' ')[0];

      return destino.contains(input) ||
             ubicacion.contains(input) ||
             calificacion.contains(input) ||
             fechaInicio.contains(input) ||
             fechaFin.contains(input);
    }).toList();

    setState(() {
      viajes = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFC4FFF9),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color(0xFF1C5A45),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.all_inbox, color: Color(0xFFC4FFF9)),
            icon: Icon(Icons.all_inbox),
            label: 'Todos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite, color: Color(0xFFC4FFF9)),
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4FFF9),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            height: 2.0,
          ),
        ),
        actions: <Widget>[buscador()],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: mostrarListaCard(), // Muestra el GridView de viajes
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: const Color(0xFFC4FFF9),
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.sort_by_alpha, color: Colors.black),
                      title: const Text('Ordenar por Destino (A-Z)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => a.destino.compareTo(b.destino));
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.sort_by_alpha, color: Colors.black),
                      title: const Text('Ordenar por Destino (Z-A)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => b.destino.compareTo(a.destino));
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range, color: Colors.black),
                      title: const Text('Ordenar por Fecha de Inicio (Asc)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => a.fecha_inicio.compareTo(b.fecha_inicio));
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range, color: Colors.black),
                      title: const Text('Ordenar por Fecha de Inicio (Desc)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => b.fecha_inicio.compareTo(a.fecha_inicio));
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.black),
                      title: const Text('Ordenar por Calificación (Asc)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => a.calificacionViaje.compareTo(b.calificacionViaje));
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.black),
                      title: const Text('Ordenar por Calificación (Desc)', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          viajes.sort((a, b) => b.calificacionViaje.compareTo(a.calificacionViaje));
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xFF1C5A45),
        child: const Icon(Icons.sort, color: Colors.white),
      ),
    );
  }

  Widget mostrarListaCard() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.1, // Ajusta la proporción según necesites
      ),
      itemCount: viajes.length + 1, // Siempre hay una tarjeta extra para añadir
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // Primera tarjeta: botón para añadir un viaje
          return cartaAddViaje();
        }
        // Tarjetas de viajes
        final viaje = viajes[index - 1]; // Restamos 1 porque el primer índice es la tarjeta de añadir
        return Container(
          decoration: styleViajeCard(viaje),
          child: Card(
            color: Colors.transparent, // Hace que la Card sea transparente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.5), // Fondo negro transparente
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          viaje.destino,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text("Desde: ${viaje.fecha_inicio.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        Text("Hasta: ${viaje.fecha_fin.toLocal().toString().split(' ')[0]}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        Text("Ubicación: ${viaje.ubicacion}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        Text("Calificación: ${viaje.calificacionViaje}/5", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () async {
                            await sql_helper.deleteViaje(viaje);
                            cargarViajes(); // Recargar los viajes después de la eliminación
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration styleViajeCard(Viaje viaje) {
    if (viaje.viajes.isNotEmpty) {
      String rutaImagen = viaje.viajes[0];
      File archivoImagen = File(rutaImagen);
      // Verificar si la imagen existe antes de usar FileImage
      if (archivoImagen.existsSync()) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: FileImage(archivoImagen),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        );
      }
    }
    // Si no hay imagen o no existe, usa un color de fondo o imagen por defecto
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      image: const DecorationImage(
        image: AssetImage('assets/images/fondoDefault.png'),
        fit: BoxFit.cover,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget cartaAddViaje() {
    return Card(
      color: const Color.fromARGB(255, 156, 234, 239),
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            // Al hacer clic en la tarjeta de añadir, se abre la pantalla para crear un viaje
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InterfazCrearViaje(actualizarViajes: cargarViajes),
              ),
            );
            cargarViajes(); // Recargar los viajes al regresar
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: Colors.black, size: 50),
              SizedBox(height: 10),
              Text(
                "Añadir Viaje",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
