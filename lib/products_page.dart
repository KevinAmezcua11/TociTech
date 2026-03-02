import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String ordenarPor = "Precio menor a mayor";

  String? categoriaSeleccionada;
  String? marcaSeleccionada;

  Map<String, bool> preciosSeleccionados = {
    "Menos de \$1000": false,
    "\$1,000 - \$5,000": false,
    "Más de \$5,000": false,
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF0F0F14),
      drawer: _buildFiltros(),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F0F14),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Filtros",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/fondo_productos.jpg",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Explora Nuestro Catálogo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Componentes y equipos con calidad y el mejor precio.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Color(0xFF0F0F14),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                childAspectRatio: 0.62,
                padding: const EdgeInsets.all(20),

                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),

                children: [
                  _productCard(
                    nombre: "Memoria RAM Kingston Fury 16GB",
                    descripcion: "Alto rendimiento para gaming",
                    precio: 1250,
                    stock: 11,
                    total: 26,
                    imagen: "assets/img-1.png",
                  ),

                  _productCard(
                    nombre: "Procesador AMD Ryzen 5 5600G",
                    descripcion: "6 núcleos | 12 hilos | Gráficos integrados",
                    precio: 3200,
                    stock: 8,
                    total: 15,
                    imagen: "assets/img-2.png",
                  ),

                  _productCard(
                    nombre: "NVIDIA GeForce RTX 3060 12GB",
                    descripcion: "Alto rendimiento para gaming y diseño",
                    precio: 7800,
                    stock: 3,
                    total: 10,
                    imagen: "assets/img-3.png",
                  ),

                  _productCard(
                    nombre: "Corsair Vengeance 16GB DDR4 3200MHz",
                    descripcion: "Optimizada para alto rendimiento",
                    precio: 1350,
                    stock: 11,
                    total: 20,
                    imagen: "assets/img-4.jpg",
                  ),

                  _productCard(
                    nombre: "Fuente Corsair 650W 80+ Bronze",
                    descripcion: "Energía estable y eficiente",
                    precio: 1200,
                    stock: 6,
                    total: 12,
                    imagen: "assets/img-5.png",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required int total,
    required String imagen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            child: Image.asset(
              imagen,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(nombre,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6),

                  Text(descripcion,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Spacer(),

                  Text("\$${precio.toStringAsFixed(0)} MXN",
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$stock / $total piezas",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text("Disponible",
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Drawer(
      backgroundColor: Color(0xFF0F0F14),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Text("Ordenar por:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: ordenarPor,
                  dropdownColor: Color(0xFF1A1A22),
                  isExpanded: true,
                  underline: SizedBox(),
                  style: TextStyle(color: Colors.white),
                  items: [
                    "Precio menor a mayor",
                    "Precio mayor a menor",
                  ]
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      ordenarPor = value!;
                    });
                  },
                ),
              ),

              SizedBox(height: 20),

              Text("Categoría:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              _radioItem("Procesadores (CPU)", categoriaSeleccionada,
                      (val) => setState(() => categoriaSeleccionada = val)),

              _radioItem("Tarjetas gráficas (GPU)", categoriaSeleccionada,
                      (val) => setState(() => categoriaSeleccionada = val)),

              _radioItem("Memoria RAM", categoriaSeleccionada,
                      (val) => setState(() => categoriaSeleccionada = val)),

              _radioItem("Almacenamiento (SSD / HDD)", categoriaSeleccionada,
                      (val) => setState(() => categoriaSeleccionada = val)),

              _radioItem("Fuentes de poder", categoriaSeleccionada,
                      (val) => setState(() => categoriaSeleccionada = val)),

              SizedBox(height: 20),

              Text("Marca:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              _radioItem("Intel", marcaSeleccionada,
                      (val) => setState(() => marcaSeleccionada = val)),

              _radioItem("AMD", marcaSeleccionada,
                      (val) => setState(() => marcaSeleccionada = val)),

              _radioItem("NVIDIA", marcaSeleccionada,
                      (val) => setState(() => marcaSeleccionada = val)),

              _radioItem("ASUS", marcaSeleccionada,
                      (val) => setState(() => marcaSeleccionada = val)),

              _radioItem("Kingston", marcaSeleccionada,
                      (val) => setState(() => marcaSeleccionada = val)),

              SizedBox(height: 20),

              Text("Precios:",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              ...preciosSeleccionados.keys.map(
                    (key) => CheckboxListTile(
                  value: preciosSeleccionados[key],
                  activeColor: Color(0xFF6C63FF),
                  checkColor: Colors.white,
                  title: Text(key,
                      style: TextStyle(color: Colors.white70)),
                  onChanged: (value) {
                    setState(() {
                      preciosSeleccionados[key] = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioItem(
      String title, String? groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      value: title,
      groupValue: groupValue,
      activeColor: Color(0xFF6C63FF),
      title: Text(title, style: TextStyle(color: Colors.white70)),
      onChanged: onChanged,
    );
  }
}
