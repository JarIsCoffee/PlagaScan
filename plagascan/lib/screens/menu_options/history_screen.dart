import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Más adelante podrías cargar un historial real desde la base de datos
    final List<String> history = [
      'Plaga detectada: Pulgón - 05/10/2025',
      'Plaga detectada: Mosca blanca - 02/10/2025',
      'Sin plaga detectada - 29/09/2025',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Historial de Análisis' ,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: history.isNotEmpty
            ? ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.bug_report, color: Colors.green, size: 32),
                      title: Text(
                        history[index],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  "No hay historial aún.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
