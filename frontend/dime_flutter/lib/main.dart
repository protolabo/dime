import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'view/client/scan_page_client.dart';
import 'view/commercant_account/choose_commerce.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Charge les variables du .env
  await dotenv.load(fileName: '.env');

  // 2️⃣ Récupère les clés
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  // Prends de préférence SUPABASE_ANON_KEY, sinon SUPABASE_SERVICE_KEY
  final supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_SERVICE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception(
        '❌ Impossible de trouver SUPABASE_URL ou la clé dans .env – vérifie ton fichier.');
  }

  // 3️⃣ Initialise Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF1DC),
        primarySwatch: Colors.orange,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dime', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanClientPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "I'm a client",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChooseCommercePage(),
                      ),
                    );
                  },
                  child: const Text(
                    "I'm an employee",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
