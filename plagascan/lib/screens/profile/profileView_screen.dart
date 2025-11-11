import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plagascan/screens/profile/profileEdit_screen.dart';

class ProfileViewScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileViewScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final user = userData;

    ImageProvider<Object> getProfileImage() {
      final foto = user['fotoPerfil'] ?? '';
      if (foto.isEmpty) return const AssetImage('assets/default_profile.png');
      try {
        if (foto.startsWith('/9j') || foto.startsWith('iVBORw0')) {
          return MemoryImage(base64Decode(foto));
        }
        if (foto.startsWith('http')) return NetworkImage(foto);
        return const AssetImage('assets/default_profile.png');
      } catch (_) {
        return const AssetImage('assets/default_profile.png');
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Navegar al modo de edición
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(
                    userData: userData, // aquí se pasan los datos actuales
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: getProfileImage(),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user['nombre'] ?? ''} ${user['apellido'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['email'] ?? 'Correo no disponible',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 1.2),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.badge, 'Nombre', user['nombre'] ?? '—'),
                _buildInfoRow(Icons.people, 'Apellido', user['apellido'] ?? '—'),
                _buildInfoRow(Icons.email, 'Email', user['email'] ?? '—'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
