import 'package:flutter/material.dart';

class BusquedaPage extends StatelessWidget {
  const BusquedaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A22),
        elevation: 0,
        title: const Text(
          "Buscar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 30),

            // Título
            const Text(
              "¿En que te podemos ayudar?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 15),
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      "Buscar producto...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TENDENCIA EN VENTAS
            const Text(
              "TENDENCIA EN VENTAS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            // Productos
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [

                  _cardProducto(
                    imagen: "assets/asusdual.png", // <-- PON TU IMAGEN
                    titulo:
                    "Asus DUAL-RTX3050-06G GeForce 6GB GDDR6/PCI-E 4.0/HDMI/DP/Negro",
                  ),

                  const SizedBox(width: 20),

                  _cardProducto(
                    imagen: "assets/amdradeon.png", // <-- PON TU IMAGEN
                    titulo: "AMD RADEON PRO W7900",
                  ),

                  const SizedBox(width: 20),

                  _cardProducto(
                    imagen: "assets/mouseacteck.png", // <-- PON TU IMAGEN
                    titulo:
                    "Mouse Inalambrico Acteck Optimize MI240 / USB / Optico / 1600 DPI",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Categorías
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                _categoriaButton("Teclado"),
                _categoriaButton("Tarjeta Grafica"),
                _categoriaButton("Audifonos"),
                _categoriaButton("Mouse"),
                _categoriaButton("Procesador"),
                _categoriaButton("Soporte"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===========================
  // CARD DE PRODUCTO
  // ===========================

  Widget _cardProducto({
    required String imagen,
    required String titulo,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              imagen,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===========================
  // BOTÓN DE CATEGORÍA
  // ===========================

  Widget _categoriaButton(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}