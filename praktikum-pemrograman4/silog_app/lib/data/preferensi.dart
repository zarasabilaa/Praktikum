
import 'package:shared_preferences/shared_preferences.dart';

class Preferensi {
  static const _kGudang = 'gudang_terakhir';
  static const _kPetugas = 'nama_petugas';
  static const _kModeGelap = 'mode_gelap';

  // SIMPAN GUDANG TERAKHIR
  Future<void> simpanGudangTerakhir(String kodeGudang) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kGudang, kodeGudang);
  }

  // AMBIL GUDANG TERAKHIR
  Future<String> ambilGudangTerakhir() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kGudang) ?? 'GD-BDG';
  }

  // SIMPAN NAMA PETUGAS
  Future<void> simpanPetugas(String nama) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPetugas, nama);
  }

  // AMBIL NAMA PETUGAS
  Future<String?> ambilPetugas() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPetugas);
  }

  // SIMPAN PREFERENSI MODE GELAP
  Future<void> setModeGelap(bool aktif) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kModeGelap, aktif);
  }

  // AMBIL PREFERENSI MODE GELAP
  Future<bool> modeGelap() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kModeGelap) ?? false;
  }

  // HAPUS SELURUH PREFERENSI
  Future<void> bersihkan() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
