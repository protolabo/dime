import 'package:flutter/material.dart';
import 'client/scan_page_client.dart'; //

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ScanClientPage(), // ✅ Classe non changée
    );
  }
}
