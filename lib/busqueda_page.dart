import 'package:flutter/material.dart';

class BusquedaPage extends StatefulWidget {
  const BusquedaPage({super.key});

  @override
  State<BusquedaPage> createState() => _BusquedaPageState();
}

class _BusquedaPageState extends State<BusquedaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Búsqueda"),
      ),
      body: Center(child: Text("Busqueda")),
    );
  }
}
