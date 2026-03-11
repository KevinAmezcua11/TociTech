import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BusquedaPage extends StatelessWidget {
  const BusquedaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Buscar",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text("¿En qué te podemos ayudar?",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Barra de búsqueda
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 15),
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text("Buscar producto...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            Text("TENDENCIA EN VENTAS",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 20),

            // Productos en tendencia
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _cardProducto(
                    imagen: "assets/asusdual.png",
                    titulo: "Asus DUAL-RTX3050-06G GeForce 6GB GDDR6/PCI-E 4.0/HDMI/DP/Negro",
                  ),
                  SizedBox(width: 20),
                  _cardProducto(
                    imagen: "assets/amdradeon.png",
                    titulo: "AMD RADEON PRO W7900",
                  ),
                  SizedBox(width: 20),
                  _cardProducto(
                    imagen: "assets/mouseacteck.png",
                    titulo: "Mouse Inalambrico Acteck Optimize MI240 / USB / Optico / 1600 DPI",
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Categorías
            Wrap(
              spacing: 15, runSpacing: 15,
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

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _cardProducto({required String imagen, required String titulo}) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Expanded(child: Image.asset(imagen, fit: BoxFit.contain)),
          SizedBox(height: 10),
          Text(
            titulo,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _categoriaButton(String texto) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        texto,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}