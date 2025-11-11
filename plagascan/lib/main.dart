import 'package:flutter/material.dart';
import 'package:plagascan/screens/auth/login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plaga Detector',
      theme: ThemeData(primarySwatch: Colors.green),
       debugShowCheckedModeBanner: false, // ← Esto quita la etiqueta DEBUG
      home:  LoginScreen(),
    );
  }
}
