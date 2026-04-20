import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class _Producto {
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final int total;
  final String imagen;

  const _Producto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.total,
    required this.imagen,
  });
}

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

  // Lista centralizada de productos
  static const List<_Producto> _productos = [
    _Producto(
      nombre: "Memoria RAM Kingston Fury 16GB",
      descripcion: "Alto rendimiento para gaming",
      precio: 1250,
      stock: 11,
      total: 26,
      imagen: "assets/img-1.png",
    ),
    _Producto(
      nombre: "Procesador AMD Ryzen 5 5600G",
      descripcion: "6 núcleos | 12 hilos | Gráficos integrados",
      precio: 3200,
      stock: 8,
      total: 15,
      imagen: "assets/img-2.png",
    ),
    _Producto(
      nombre: "NVIDIA GeForce RTX 3060 12GB",
      descripcion: "Alto rendimiento para gaming y diseño",
      precio: 7800,
      stock: 3,
      total: 10,
      imagen: "assets/img-3.png",
    ),
    _Producto(
      nombre: "Corsair Vengeance 16GB DDR4 3200MHz",
      descripcion: "Optimizada para alto rendimiento",
      precio: 1350,
      stock: 11,
      total: 20,
      imagen: "assets/img-4.jpg",
    ),
    _Producto(
      nombre: "Fuente Corsair 650W 80+ Bronze",
      descripcion: "Energía estable y eficiente",
      precio: 1200,
      stock: 6,
      total: 12,
      imagen: "assets/img-5.png",
    ),
  ];

  void _irADetalle(BuildContext context, _Producto p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          nombre: p.nombre,
          descripcion: p.descripcion,
          precio: p.precio,
          stock: p.stock,
          total: p.total,
          imagen: p.imagen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildFiltros(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text("Filtros", style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero image
            SizedBox(
              height: 500,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset("assets/fondo_productos.jpg", fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.4)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Explora Nuestro Catálogo",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Componentes y equipos con calidad y el mejor precio.",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grid de productos
            Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                childAspectRatio: 0.62,
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _productos.map((p) => ProductCard(
                  nombre: p.nombre,
                  descripcion: p.descripcion,
                  precio: p.precio,
                  stock: p.stock,
                  total: p.total,
                  imagen: p.imagen,
                  onTap: () => _irADetalle(context, p),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("Ordenar por:",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: ordenarPor,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: ["Precio menor a mayor", "Precio mayor a menor"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => ordenarPor = value!),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Categoría:",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
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
              const SizedBox(height: 20),
              const Text("Marca:",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
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
              const SizedBox(height: 20),
              const Text("Precios:",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              ...preciosSeleccionados.keys.map(
                    (key) => CheckboxListTile(
                  value: preciosSeleccionados[key],
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textPrimary,
                  title: Text(key, style: const TextStyle(color: AppColors.textSecondary)),
                  onChanged: (value) => setState(() => preciosSeleccionados[key] = value!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioItem(String title, String? groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      value: title,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(color: AppColors.textSecondary)),
      onChanged: onChanged,
    );
  }
}