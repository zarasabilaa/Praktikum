import 'barang.dart';
import 'gudang.dart';
import 'pelanggan.dart';

class Pengiriman {
  final String resi;
  final Gudang asal;
  final String kotaTujuan;
  final Barang barang;
  final int jumlah;
  final DateTime tanggalKirim;
  final Pelanggan pelanggan;

  String _status;

  static const List<String> _urutanStatus = [
    'Draft',
    'Menunggu Pickup',
    'Dalam Perjalanan',
    'Tiba di Kota Tujuan',
    'Diterima',
  ];

  Pengiriman({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    required this.tanggalKirim,
    required this.pelanggan,
    String status = 'Draft',
  }) : _status = status {
    _validasiJumlah(jumlah);
    _validasiStatus(status);
  }

  Pengiriman.baru({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    required this.pelanggan,
  })  : tanggalKirim = DateTime.now(),
        _status = 'Menunggu Pickup' {
    _validasiJumlah(jumlah);
  }

  static void _validasiJumlah(int jumlah) {
    if (jumlah <= 0) {
      throw ArgumentError(
        'Jumlah pengiriman harus lebih besar dari nol',
      );
    }
  }

  static void _validasiStatus(String status) {
    if (!_urutanStatus.contains(status)) {
      throw ArgumentError('Status $status tidak dikenal');
    }
  }

  String get status => _status;

  double get nilaiBarang => barang.nilaiTotal(jumlah);

  void ubahStatus(String statusBaru) {
    _validasiStatus(statusBaru);

    final indeksLama = _urutanStatus.indexOf(_status);
    final indeksBaru = _urutanStatus.indexOf(statusBaru);

    if (indeksBaru < indeksLama) {
      throw StateError(
        'Status tidak dapat mundur dari $_status ke $statusBaru',
      );
    }

    _status = statusBaru;
  }

  @override
  String toString() {
    return '$resi | ${barang.nama} x$jumlah | '
        '${asal.kota} -> $kotaTujuan | '
        'Pelanggan: ${pelanggan.nama} | $_status';
  }
}