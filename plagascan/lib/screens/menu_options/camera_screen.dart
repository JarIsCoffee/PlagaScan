import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plagascan/services/cultivos_service.dart';
import 'package:plagascan/services/plagas_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/io_client.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Interpreter? _interpreter;
  File? _image;
  bool _isProcessing = false;
  List<Map<String, dynamic>> cultivos = [];
  List<Map<String, dynamic>> plagasApi = [];
  late IOClient client;

  @override
  void initState() {
    super.initState();
    _setupClient();
    _loadModelAndData();
  }

  void _setupClient() {
    final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    client = IOClient(ioc);
  }

  Future<void> _loadModelAndData() async {
    // Cargar modelo TFLite
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    // print("✅ Modelo cargado");

    // Traer datos de API
    cultivos = await CultivoService.getCultivos(client: client);
    plagasApi = await PlagaService.getPlagas(client: client);

    // if (cultivos.isEmpty) print("⚠ Atención: cultivos está vacío");
    // if (plagasApi.isEmpty) print("⚠ Atención: plagasApi está vacío");

    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });

      await _classifyImage(_image!);

      setState(() => _isProcessing = false);
    }
  }

  Future<void> _classifyImage(File image) async {
    if (_interpreter == null || plagasApi.isEmpty || cultivos.isEmpty) return;

    try {
      final imageBytes = await image.readAsBytes();
      final oriImage = img.decodeImage(imageBytes);
      if (oriImage == null) return;

      final resizedImage = img.copyResize(oriImage, width: 224, height: 224);

      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => [
              img.getRed(resizedImage.getPixel(x, y)) / 255.0,
              img.getGreen(resizedImage.getPixel(x, y)) / 255.0,
              img.getBlue(resizedImage.getPixel(x, y)) / 255.0,
            ],
          ),
        ),
      );

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));
      _interpreter!.run(input, output);

      int predIndex = output[0].indexWhere(
        (v) => v == output[0].reduce((a, b) => a > b ? a : b),
      );

      Map<String, dynamic>? detectedPlaga;
      if (predIndex >= 0 && predIndex < plagasApi.length) {
        detectedPlaga = plagasApi[predIndex];
      }

      String resultado;

      if (detectedPlaga != null && detectedPlaga.isNotEmpty) {
        final cultivo = cultivos.firstWhere(
          (c) => c["id"] == detectedPlaga?["cultivoId"],
        );

        resultado =
            "📌 Plaga: ${detectedPlaga["nombre_comun"] ?? 'Desconocida'}\n"
            "📝 Nombre científico: ${detectedPlaga["nombre_cientifico"] ?? 'No disponible'}\n"
            "🌿 Descripción: ${detectedPlaga["descripcion"] ?? 'No disponible'}\n"
            "🐞 Síntomas: ${detectedPlaga["sintomas"] ?? 'No disponible'}\n\n"
            "🌱 Cultivo afectado: ${cultivo['nombre'] ?? 'Desconocido'}\n"
            "🌾 Variedad: ${cultivo['variedad'] ?? 'Desconocida'}\n"
            "📍 Ubicación: ${cultivo['ubicacion'] ?? 'No disponible'}";
      } else {
        resultado = "No se pudo identificar la plaga.";
      }

      _showResultCard(resultado, image);
    } catch (e) {
      // print("Error clasificando la imagen: $e");
    }
  }

  void _showResultCard(String result, File image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                spreadRadius: 3,
                offset: const Offset(0, -3),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(image, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Resultado del análisis",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Detector de Plagas",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(Icons.camera_alt,
                            color: Colors.grey, size: 90),
                      ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickImage,
                icon: const Icon(Icons.camera, color: Colors.white,),
                label: Text(
                  _isProcessing ? "Analizando..." : "Tomar Foto",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
