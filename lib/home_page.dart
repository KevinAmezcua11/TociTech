import 'package:flutter/material.dart';
import 'ajustes_page.dart';
import 'notificaciones_page.dart';
import 'products_page.dart';
import 'reparaciones_page.dart';
import 'busqueda_page.dart';

class TociTechApp extends StatefulWidget {
  const TociTechApp({super.key});

  @override
  State<TociTechApp> createState() => _TociTechAppState();
}

class _TociTechAppState extends State<TociTechApp> {
  int _index = 0;

  final List _titulosAppBar = [
    "TociTech",
    "Productos",
    "Reparaciones",
    "Ajustes",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A22),
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            _titulosAppBar[_index],
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesPage()),
            ),
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF6C63FF).withOpacity(0.2),
              child: Icon(Icons.person, color: Color(0xFF6C63FF)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificacionesPage()),
              ),
              icon: Icon(Icons.notifications, color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),

      body: _contenido(),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A22),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (x) => setState(() => _index = x),
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Inicio"
              ),

              BottomNavigationBarItem(
                  icon: Icon(Icons.category_sharp),
                  label: "Productos"
              ),

              BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: "Reparaciones"
              ),

              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Ajustes"
              ),
            ],

            iconSize: 26,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,

            showUnselectedLabels: true,

            selectedIconTheme: IconThemeData(color: Color(0xFF6C63FF)),
            unselectedIconTheme: IconThemeData(color: Color(0xFF8A8A93)),

            selectedLabelStyle: TextStyle(fontSize: 14),
            unselectedLabelStyle: TextStyle(fontSize: 14),

            selectedItemColor: Color(0xFF6C63FF),
            unselectedItemColor: Color(0xFFD6D6D6),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF1E88E5),
        child: Icon(
            Icons.smart_toy,
            size: 32,
            color: Colors.white
        ),
      ),
    );
  }

  Widget? _contenido() {
    switch (_index) {
      case 0:  return _buildHome();
      case 1:  return ProductsPage();
      case 2:  return ReparacionesPage();
      case 3:  return AjustesPage();
      default: return Center(child: Text("Página NO existe"));
    }
  }

  Widget _buildHome() {
    return ListView(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFF1A1A22)),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BusquedaPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFFD6D6D7)),
                  SizedBox(width: 8),
                  Text("Buscar", style: TextStyle(color: Color(0xFFD6D6D7))),
                ],
              ),
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.asset("assets/Logo-img.png"),
                    radius: 35,
                    backgroundColor: Color(0xFF6C63FF).withOpacity(0.2),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text("Soluciones tecnológicas para tu equipo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("Venta de hardware, reparación especializada y atención para que tu equipo rinda al máximo.",
                style: TextStyle(
                    color: Colors.white70,
                    height: 1.4
                ),
              ),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cardCaracteristicas(
                      Icons.star_rounded,
                      titulo: "4.9",
                      descripcion: "Calificación"
                  ),

                  cardCaracteristicas(
                      Icons.people_rounded,
                      titulo: "500+",
                      descripcion: "Clientes"
                  ),

                  cardCaracteristicas(
                      Icons.build_circle_rounded,
                      titulo: "1000+",
                      descripcion: "Reparaciones"
                  ),
                ],
              ),

              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (){},
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: Icon(Icons.grid_view_rounded, size: 18),
                      label: Text("Ver productos",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.handyman_rounded, size: 18, color: Colors.black87),
                      label: Text("Explorar servicios",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                          )
                      ),

                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          decoration: BoxDecoration(
            color: Color(0xFF1A1A22),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        SizedBox(height: 20,),

        // Servicios
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Nuestros Servicios",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, fontWeight:
                  FontWeight.bold
                  ),
                  textAlign: TextAlign.center
              ),
              const SizedBox(height: 6),
              Text("Soluciones técnicas con precios claros y accesibles.",
                  style: TextStyle(color: Color(0xFFD6D6D7)),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: 10),
              _cardServicio(
                  titulo: "Diagnóstico técnico especializado",
                  descripcion: "Revisión completa del equipo para detectar fallas de hardware o software.",
                  imagen: "assets/servicio1.png",
                  precio: 150,
                  tiempo: "1-2",
                  textoBoton: "Solicitar Servicio"
              ),
              SizedBox(height: 16),
              _cardServicio(
                  titulo: "Mantenimiento Preventivo",
                  descripcion: "Limpieza y optimización para mejorar el rendimiento y prolongar la vida útil del equipo.",
                  imagen: "assets/servicio2.png",
                  precio: 350,
                  tiempo: "1",
                  textoBoton: "Solicitar Servicio"
              ),
              SizedBox(height: 16),
              _cardServicio(
                  titulo: "Reparación de Hardware",
                  descripcion: "Solución de fallas físicas en laptop o PC.",
                  imagen: "assets/servicio3.png",
                  precio: 400,
                  tiempo: "1-15",
                  textoBoton: "Solicitar Servicio"
              ),
            ],
          ),
        ),

        // Horarios
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Horarios de Atención",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: 6),
              Text("Estamos disponibles para ayudarte en los siguientes horarios.",
                  style: TextStyle(color: Color(0xFFD6D6D7)),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: 10),
              _cardHorario(
                  dias: "Lunes a Viernes",
                  horario: "9:00 AM – 7:00 PM",
                  comentario1: "Atención en persona y en línea",
                  comentario2: "Respuesta rápida en horario laboral"
              ),
              SizedBox(height: 16),
              _cardHorario(
                  dias: "Sábado",
                  horario: "9:00 AM – 2:00 PM",
                  comentario1: "Horario reducido",
                  comentario2: "Citas recomendadas"
              ),
              SizedBox(height: 16),
              _cardHorario(
                  dias: "Domingo",
                  horario: "Cerrado",
                  comentario1: "Puedes dejarnos un mensaje",
                  comentario2: "Te responderemos el lunes"
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardServicio({
    required String titulo,
    required String descripcion,
    required String imagen,
    required int precio,
    required String tiempo,
    required String textoBoton,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF2A2A35)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(titulo,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
              )
          ),
          SizedBox(height: 6),
          Text(descripcion, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
          SizedBox(height: 12),
          Image.asset(imagen, height: 120),
          SizedBox(height: 14),
          Row(children: [
            Icon(Icons.attach_money_rounded, color: Color(0xFF00E676), size: 22),
            SizedBox(width: 6),
            Text("Desde \$$precio MXN",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                )
            ),
          ]),
          SizedBox(height: 8),
          Row(children: [
            Icon(Icons.schedule_rounded, color: Color(0xFF42A5F5), size: 22),
            SizedBox(width: 6),
            Text("$tiempo días hábiles",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14
                )
            ),
          ]),
          SizedBox(height: 16),
          FilledButton.icon(
            onPressed: (){},
            style: FilledButton.styleFrom(backgroundColor: Color(0xFF1E88E5)),
            icon: Icon(Icons.handyman_rounded),
            label: Text(textoBoton,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _cardHorario({
    required String dias,
    required String horario,
    required String comentario1,
    required String comentario2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFF130C1F)
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 5),
            child: Text(dias,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.6
                ),
                textAlign: TextAlign.center
            ),

            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.2),
              border: Border.all(color: Color(0xFF6C63FF)),
              borderRadius: BorderRadius.circular(20)
            ),
          ),
          SizedBox(height: 10),
          Text(horario,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.95)
              ),
              textAlign: TextAlign.center
          ),
          SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          SizedBox(height: 14),
          _horarioRow(
              Icons.check_circle_rounded,
              Color(0xFF00E676),
              comentario1
          ),
          SizedBox(height: 10),
          _horarioRow(
              Icons.info_rounded,
              Colors.blue,
              comentario2
          ),
        ],
      ),
    );
  }

  Widget _horarioRow(IconData icon, Color iconColor, String texto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          child: Icon(icon, color: iconColor, size: 20),
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.2),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(texto,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14
              ),
          ),
        ),
      ],
    );
  }

  cardCaracteristicas(IconData icon, {required String titulo, required String descripcion}) {
    return Container(
      alignment: Alignment.center,
      height: 80,
      width: 110,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFF6C63FF), size: 20),
          Text(titulo,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(descripcion,
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12
              )
          ),
        ],
      ),

      decoration: BoxDecoration(
        color: Color(0xFF26262D),
          border: Border.all(color: Color(0xFF6F6F7A)),
          borderRadius: BorderRadius.circular(12)
      ),
    );
  }
}