
class ResiTidakDitemukan implements Exception {
  final String resi;

  ResiTidakDitemukan(this.resi);

  @override
  String toString() =>
      'Resi $resi tidak ditemukan pada basis data.';
}

// Basis data status kiriman
final Map<String, String> basisStatusKiriman = {
  'SLG-001': 'Dalam perjalanan menuju Bandung',
  'SLG-002': 'Tiba di gudang transit Surabaya',
  'SLG-003': 'Sedang diantar kurir ke penerima',
  'SLG-004': 'Menunggu proses sortir di Jakarta',
  'SLG-005': 'Paket telah diterima oleh penerima',
};

// Mengambil status kiriman berdasarkan nomor resi
Future<String> ambilStatusKiriman(String resi) async {
  await Future.delayed(const Duration(seconds: 1));

  final status = basisStatusKiriman[resi];

  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }

  return status;
}

// Memantau beberapa resi secara bersamaan
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  print('Memantau ${daftarResi.length} resi secara bersamaan...');

  // Setiap resi menangani error secara mandiri
  final hasil = await Future.wait(
    daftarResi.map((resi) async {
      try {
        final status = await ambilStatusKiriman(resi);
        return 'BERHASIL|$resi|$status';
      } on ResiTidakDitemukan catch (e) {
        return 'GAGAL|$resi|$e';
      } catch (e) {
        return 'ERROR|$resi|$e';
      }
    }),
  );

  final berhasil = <String>[];
  final gagal = <String>[];

  for (final item in hasil) {
    final bagian = item.split('|');

    if (bagian[0] == 'BERHASIL') {
      berhasil.add('${bagian[1]} -> ${bagian[2]}');
    } else {
      gagal.add(
        '${bagian[1]} -> ${bagian.sublist(2).join('|')}',
      );
    }
  }

  print('\n=== HASIL BERHASIL (${berhasil.length}) ===');

  if (berhasil.isEmpty) {
    print('Tidak ada resi yang berhasil.');
  } else {
    for (final item in berhasil) {
      print(item);
    }
  }

  print('\n=== RESI GAGAL (${gagal.length}) ===');

  if (gagal.isEmpty) {
    print('Tidak ada resi gagal.');
  } else {
    for (final item in gagal) {
      print(item);
    }
  }

  print('\nPemantauan selesai.');
}

Future<void> main() async {
  // Pilih 'sah' atau 'campuran'
  const skenario = 'sah';

  final daftarResi = skenario == 'sah'
      ? [
          'SLG-001',
          'SLG-002',
          'SLG-003',
          'SLG-004',
          'SLG-005',
        ]
      : [
          'SLG-001',
          'XYZ-002',
          'SLG-003',
          'SLG-999',
          'SLG-005',
        ];

  print('=== Skenario: $skenario ===');

  await pantauBanyakResi(daftarResi);
}
