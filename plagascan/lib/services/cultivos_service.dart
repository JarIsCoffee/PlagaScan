import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

class CultivoService {
  static const String baseUrl = "https://10.73.105.88:7021/api/Cultivos";

  static Future<List<Map<String, dynamic>>> getCultivos({required IOClient client}) async {
    try {
      final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      final client = IOClient(ioc);

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
      } else {
        print("Error en la API de cultivos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching cultivos: $e");
      return [];
    }
  }
}
