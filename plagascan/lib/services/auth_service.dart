import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

class AuthService {
  static const String baseUrl = "https://10.73.105.88:7021/api/Auth";
  // static const String baseUrl = "https://10.0.2.2:7021/api/Auth";
  Future<bool> register(
      String nombre,
      String apellido,
      String email,
      String password,
      File? fotoPerfil,
      ) async {
    try {
      var client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true; // Permite HTTPS local

      final url = "$baseUrl/register";
      // print("➡️ Enviando POST a: $url");

      var request = await client.postUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");

      // Preparamos body
      Map<String, dynamic> body = {
        "nombre": nombre,
        "apellido": apellido,
        "email": email,
        "password": password,
      };

      // Adjuntar imagen si existe
      if (fotoPerfil != null) {
        List<int> bytes = await fotoPerfil.readAsBytes();
        body["fotoPerfil"] = base64Encode(bytes);
      }

      // Enviar body
      request.add(utf8.encode(jsonEncode(body)));

      var response = await request.close();
      await response.transform(utf8.decoder).join();

      // print("⬅️ Status code: ${response.statusCode}");
      // print("📦 Response body: $responseBody");

      return response.statusCode == 200;
    } catch (e) {
      // print("❌ Error en register: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      var client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final url = "$baseUrl/login";
      // print("➡️ Enviando POST a: $url");

      var request = await client.postUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      request.add(utf8.encode(jsonEncode({
        "email": email,
        "password": password
      })));

      var response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // print("⬅️ Status code: ${response.statusCode}");
      // print("📦 Response body: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data;
      } else {
        // print("❌ Login fallido: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("❌ Error en login: $e");
      return null;
    }
  }

 Future<bool> updateProfile({
    required int userId,
    required String nombre,
    required String apellido,
    required String fotoPerfil,
  }) async {
    // Crear cliente que ignore certificados (solo para desarrollo)
    final ioc = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(ioc);

    final url = Uri.parse('$baseUrl/updateProfile/$userId');
    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
       body: jsonEncode({
        'id':userId,
        'nombre': nombre,
        'apellido': apellido,
        'fotoPerfil': fotoPerfil,
      }),
    );

    return response.statusCode == 200;
  }
  
}
