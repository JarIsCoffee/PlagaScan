import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plagascan/screens/menu_options/camera_screen.dart';
import 'package:plagascan/screens/profile/profileView_screen.dart';
import 'gallery_screen.dart';
import 'info_screen.dart';
import 'history_screen.dart';

class MenuScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MenuScreen({super.key, required this.userData});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedOption = -1;
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    userData = Map.from(widget.userData);
  }

  late final List<Map<String, dynamic>> options = [
    {
      'icon': Icons.camera_alt,
      'title': 'Abrir Cámara',
      'subtitle': 'Detectar plagas en tiempo real',
      'action': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
      },
    },
    {
      'icon': Icons.image,
      'title': 'Analizar Imagen',
      'subtitle': 'Seleccionar foto desde la galería',
      'action': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GalleryScreen()),
        );
      },
    },
    {
      'icon': Icons.history,
      'title': 'Historial de Análisis',
      'subtitle': 'Ver resultados anteriores',
      'action': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
      },
    },
    {
      'icon': Icons.info_outline,
      'title': 'Información del Modelo',
      'subtitle': 'Detalles sobre la inteligencia artificial',
      'action': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InfoScreen()),
        );
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Bienvenido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🔹 Foto de perfil con actualización
          GestureDetector(
            onTap: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileViewScreen(userData: userData),
                ),
              );

              if (updatedData != null && updatedData is Map<String, dynamic>) {
                setState(() {
                  userData['nombre'] = updatedData['nombre'];
                  userData['apellido'] = updatedData['apellido'];
                  userData['fotoPerfil'] = updatedData['fotoPerfil'];
                });
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: (() {
              print("🧾 Datos recibidos en MenuScreen: $userData");
              final foto = userData['fotoPerfil'] ?? userData['FotoPerfil'];

              print("📸 FotoPerfil recibida en MenuScreen: $foto");

              if (foto == null || (foto is String && foto.isEmpty)) {
                print("⚠️ No hay foto, se usará imagen por defecto");
                return const AssetImage('assets/default_profile.png');
              }

              try {
                // Detectar Base64 (normalmente empieza con /9j o iVBORw)
                if (foto.startsWith('/9j') || foto.startsWith('iVBORw0')) {
                  print("🧠 Detectada imagen Base64");
                  final decoded = base64Decode(foto);
                  return MemoryImage(decoded);
                }

                // Detectar URL
                if (foto.startsWith('http')) {
                  print("🌐 Detectada imagen por URL");
                  return NetworkImage(foto);
                }

                print("⚠️ Foto no reconocida, usando imagen por defecto");
                return const AssetImage('assets/default_profile.png');
              } catch (e, s) {
                print("❌ Error al cargar imagen: $e");
                print("🔍 Stack: $s");
                return const AssetImage('assets/default_profile.png');
              }
              })() as ImageProvider<Object>?,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = _selectedOption == index;

          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border:
                  selected ? Border.all(color: Colors.green, width: 2) : null,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(option['icon'], color: Colors.green),
              title: Text(
                option['title'],
                style: TextStyle(
                  color: selected ? Colors.black : Colors.grey[700],
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                option['subtitle'],
                style: TextStyle(
                  color: selected ? Colors.black : Colors.grey[600],
                ),
              ),
              onTap: () {
                setState(() => _selectedOption = index);
                option['action'](context);
              },
            ),
          );
        },
      ),
    );
  }
}
