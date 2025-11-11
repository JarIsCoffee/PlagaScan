import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileEditScreen({super.key, required this.userData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _selectedImage;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.userData['nombre']);
    _apellidoController = TextEditingController(text: widget.userData['apellido']);
    print(widget.userData);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String fotoBase64 = widget.userData['fotoPerfil'] ?? '';
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        fotoBase64 = base64Encode(bytes);
        print('📸 Base64 length: ${fotoBase64.length}');
      }

      final success = await _authService.updateProfile(
        userId: widget.userData['idUsuario'],
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        fotoPerfil: fotoBase64,
      );

      if (success) {
        // Mostrar ventana de confirmación
        await showDialog(
          context: context,
          barrierDismissible: false, // evita cerrar tocando afuera
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Perfil actualizado'),
            content: const Text(
              'Los datos de tu perfil se han actualizado correctamente.',
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // cierra el diálogo
                  Navigator.pop(context, {
                    'nombre': _nombreController.text.trim(),
                    'apellido': _apellidoController.text.trim(),
                    'fotoPerfil': fotoBase64,
                  });
                },
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al actualizar el perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Ocurrió un error: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (() {
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
                          })() as ImageProvider<Object>,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.person_outline, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['email'] ?? 'Correo no disponible',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const Divider(height: 40),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Guardar cambios',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
