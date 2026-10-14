
class DataKiriman {
  final String resi; // Wajib
  final String kotaTujuan; // Wajib
  final String? catatan; // Opsional
  final DateTime? waktuTerima; // Opsional

  DataKiriman({
    required this.resi,
    required this.kotaTujuan,
    this.catatan,
    this.waktuTerima,
  });
}

String ringkasan(DataKiriman k) {
  final catatan = k.catatan ?? '(tanpa catatan)';

  final status = k.waktuTerima == null
      ? 'Dalam perjalanan'
      : 'Diterima pada ${k.waktuTerima!.toIso8601String()}';

  return '${k.resi} | ${k.kotaTujuan} | $status | $catatan';
}

// Exception khusus ketika resi tidak ditemukan
class ResiTidakDitemukan implements Exception {
  final String resi;

  ResiTidakDitemukan(this.resi);

  @override
  String toString() =>
      'Resi $resi tidak ditemukan pada basis data.';
}

// Basis data sederhana untuk pencarian resi
final Map<String, String> basisResi = {
  'SLG-001': 'Bandung',
  'SLG-002': 'Surabaya',
};

// Fungsi untuk mencari kota berdasarkan nomor resi
String cariKota(String resi) {
  final kota = basisResi[resi];

  if (kota == null) {
    throw ResiTidakDitemukan(resi);
  }

  return kota;
}

// Pengujian penanganan exception
void ujiPenanganan() {
  for (final resi in ['SLG-001', 'SLG-999']) {
    try {
      print('$resi -> ${cariKota(resi)}');
    } on ResiTidakDitemukan catch (e) {
      print('Peringatan: $e');
    } catch (e, s) {
      print('Kesalahan tidak terduga: $e');
      print(s);
    } finally {
      print('Pencarian $resi selesai.');
    }
  }
}

void main() {
  // Menampilkan ringkasan data kiriman
  final daftar = <DataKiriman>[
    DataKiriman(
      resi: 'SLG-001',
      kotaTujuan: 'Bandung',
    ),
    DataKiriman(
      resi: 'SLG-002',
      kotaTujuan: 'Surabaya',
      catatan: 'Titipkan ke satpam',
      waktuTerima: DateTime(2026, 9, 12, 10, 30),
    ),
  ];

  print('=== Ringkasan Data Kiriman ===');

  for (final k in daftar) {
    print(ringkasan(k));
  }

  // Menjalankan pengujian exception
  print('\n=== Pengujian Penanganan Exception ===');
  ujiPenanganan();
}
