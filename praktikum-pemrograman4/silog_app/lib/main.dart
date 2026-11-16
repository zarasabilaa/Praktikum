
import 'package:flutter/material.dart';

import 'data/preferensi.dart';
import 'tampilan/daftar_pengiriman_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SiLogApp());
}

class SiLogApp extends StatefulWidget {
  const SiLogApp({super.key});

  @override
  State<SiLogApp> createState() => _SiLogAppState();
}

class _SiLogAppState extends State<SiLogApp> {
  final Preferensi _preferensi = Preferensi();

  bool _modeGelap = false;
  bool _memuatPreferensi = true;

  @override
  void initState() {
    super.initState();
    _muatPreferensiTema();
  }

  // MEMUAT PREFERENSI TEMA
  Future<void> _muatPreferensiTema() async {
    final aktif = await _preferensi.modeGelap();

    if (!mounted) return;

    setState(() {
      _modeGelap = aktif;
      _memuatPreferensi = false;
    });
  }

  // MENGUBAH DAN MENYIMPAN MODE TEMA
  Future<void> _ubahModeGelap(bool aktif) async {
    await _preferensi.setModeGelap(aktif);

    if (!mounted) return;

    setState(() {
      _modeGelap = aktif;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLog',
      debugShowCheckedModeBanner: false,

      // TEMA TERANG
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),

      // TEMA GELAP
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),

      // MEMILIH TEMA BERDASARKAN PREFERENSI
      themeMode: _modeGelap
          ? ThemeMode.dark
          : ThemeMode.light,

      home: _memuatPreferensi
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : DaftarPengirimanPage(
              modeGelap: _modeGelap,
              onModeGelapChanged: _ubahModeGelap,
            ),
    );
  }
}
