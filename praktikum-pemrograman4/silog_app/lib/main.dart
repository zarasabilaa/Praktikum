import 'package:flutter/material.dart';

void main() {
  runApp(const SiLogApp());
}

class SiLogApp extends StatelessWidget {
  const SiLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
        useMaterial3: true,
      ),
      home: const BerandaPage(),
    );
  }
}

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SiLog')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 72),

            const SizedBox(height: 20),

            const Text(
              'Zahra Sabila',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text('NIM: 714240017', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 8),

            const Text('Kelas: 3B D4 Teknik Informatika', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 24),

            const Text(
              'Sistem Informasi Logistik',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text('Lingkungan pengembangan siap digunakan'),
          ],
        ),
      ),
    );
  }
}
