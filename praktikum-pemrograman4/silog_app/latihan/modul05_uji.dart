
import '../lib/layanan/layanan_pengiriman.dart';
import '../lib/layanan/moda.dart';

void main() {
  final List<LayananPengiriman> daftarLayanan = [
    PengirimanTruk(
      kodeLayanan: 'TRK-REG',
      jarakKm: 780,
      beratKg: 1200,
    ),
    PengirimanTruk(
      kodeLayanan: 'TRK-EXP',
      jarakKm: 780,
      beratKg: 1200,
      ekspres: true,
    ),
    PengirimanKeretaApi(
      kodeLayanan: 'KA-CARGO',
      jarakKm: 780,
      beratKg: 1200,
      stasiunAsal: 'Kiaracondong',
      stasiunTujuan: 'Pasar Turi',
    ),
    PengirimanKapal(
      kodeLayanan: 'KPL-PETI',
      jarakKm: 1450,
      beratKg: 1200,
      volumeM3: 8.5,
    ),
    PengirimanUdara(
      kodeLayanan: 'UDR-CARGO',
      jarakKm: 780,
      beratKg: 15,
      panjangCm: 60,
      lebarCm: 50,
      tinggiCm: 40,
    ),
  ];

  // Menampilkan perbandingan seluruh layanan.
  print('=== Perbandingan Layanan Pengiriman ===');

  for (final layanan in daftarLayanan) {
    print(layanan.ringkasan());
  }

  // Mengurutkan layanan berdasarkan tarif termurah.
  daftarLayanan.sort(
    (a, b) => a.hitungTarif().compareTo(b.hitungTarif()),
  );

  print('\nLayanan termurah: ${daftarLayanan.first.kodeLayanan}');

  // Mencari layanan dengan estimasi waktu tercepat.
  final layananTercepat = daftarLayanan.reduce(
    (a, b) => a.estimasiHari() <= b.estimasiHari() ? a : b,
  );

  print('Layanan tercepat: ${layananTercepat.kodeLayanan}');

  // Menguji mixin Terlacak pada pengiriman truk.
  final truk = daftarLayanan.whereType<PengirimanTruk>().first;

  truk.catatPosisi('Gudang Utama Bandung');
  truk.catatPosisi('Rest Area KM 207');
  truk.catatPosisi('Gudang Transit Semarang');

  print('\nRiwayat posisi ${truk.kodeLayanan}:');

  for (final riwayat in truk.riwayat) {
    print(' $riwayat');
  }

  print('Posisi terakhir: ${truk.posisiTerakhir()}');

  // Menguji mixin Terasuransi.
  print('\n=== Pengujian Mixin Terasuransi ===');

  for (final layanan in daftarLayanan) {
    if (layanan is PengirimanKapal) {
      final premi = layanan.hitungPremi(10000000);

      print(
        '${layanan.kodeLayanan}: '
        'Premi asuransi Rp${premi.toStringAsFixed(0)}',
      );
    } else if (layanan is PengirimanUdara) {
      final premi = layanan.hitungPremi(10000000);

      print(
        '${layanan.kodeLayanan}: '
        'Premi asuransi Rp${premi.toStringAsFixed(0)}',
      );
    } else {
      print(
        '${layanan.kodeLayanan}: '
        'Tidak memiliki fitur asuransi',
      );
    }
  }
}
