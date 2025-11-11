import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plagascan/services/cultivos_service.dart';
import 'package:plagascan/services/plagas_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/io_client.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  File? _image;
  String _result = "Sin análisis aún";
  bool _isAnalyzing = false;
  Interpreter? _interpreter;
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
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      // print("✅ Modelo cargado");
    } catch (e) {
      // print("❌ Error cargando modelo: $e");
    }

    cultivos = await CultivoService.getCultivos(client: client);
    plagasApi = await PlagaService.getPlagas(client: client);

    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Analizando...";
        _isAnalyzing = true;
      });

      await _analyzeImage(_image!);

      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeImage(File image) async {
    if (_interpreter == null || plagasApi.isEmpty || cultivos.isEmpty) {
      setState(() => _result = "Error: modelo o datos no cargados");
      return;
    }

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
          orElse: () => {},
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

      setState(() => _result = resultado);
    } catch (e) {
      setState(() => _result = "Error analizando la imagen");
      // print("Error analizando imagen: $e");
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Analizar Imagen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 120,
                        color: Colors.green,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text(
                "Seleccionar desde galería",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.green,
              ),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _isAnalyzing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text(
                            "Analizando...",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        _result,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
