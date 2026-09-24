
class Kiriman {
  final String resi;
  final double berat;

  Kiriman({
    required this.resi,
    required this.berat,
  });
}

// Fungsi menghitung total berat seluruh kiriman
double hitungTotalBerat(List<Kiriman> kiriman) {
  double total = 0;

  for (final item in kiriman) {
    total += item.berat;
  }

  return total;
}

// Fungsi menghitung rata-rata berat kiriman
double hitungRataRataBerat(List<Kiriman> kiriman) {
  if (kiriman.isEmpty) {
    return 0;
  }

  final total = hitungTotalBerat(kiriman);
  return total / kiriman.length;
}

// Fungsi mencari kiriman terberat
Kiriman cariKirimanTerberat(List<Kiriman> kiriman) {
  if (kiriman.isEmpty) {
    throw ArgumentError('Daftar kiriman tidak boleh kosong.');
  }

  Kiriman terberat = kiriman.first;

  for (final item in kiriman) {
    if (item.berat > terberat.berat) {
      terberat = item;
    }
  }

  return terberat;
}

// Fungsi mencari kiriman teringan
Kiriman cariKirimanTeringan(List<Kiriman> kiriman) {
  if (kiriman.isEmpty) {
    throw ArgumentError('Daftar kiriman tidak boleh kosong.');
  }

  Kiriman teringan = kiriman.first;

  for (final item in kiriman) {
    if (item.berat < teringan.berat) {
      teringan = item;
    }
  }

  return teringan;
}

// Fungsi menentukan kategori berdasarkan berat
String tentukanKategori(double berat) {
  if (berat <= 5) {
    return 'Paket Kecil';
  } else if (berat <= 20) {
    return 'Paket Sedang';
  } else {
    return 'Kargo';
  }
}

// Fungsi menghitung jumlah kiriman pada setiap kategori
Map<String, int> hitungJumlahKategori(List<Kiriman> kiriman) {
  final Map<String, int> jumlahKategori = {
    'Paket Kecil': 0,
    'Paket Sedang': 0,
    'Kargo': 0,
  };

  for (final item in kiriman) {
    final kategori = tentukanKategori(item.berat);
    jumlahKategori[kategori] =
        jumlahKategori[kategori]! + 1;
  }

  return jumlahKategori;
}

// Fungsi menampilkan hasil analisis
void tampilkanHasil(List<Kiriman> kiriman) {
  final totalBerat = hitungTotalBerat(kiriman);
  final rataRata = hitungRataRataBerat(kiriman);
  final terberat = cariKirimanTerberat(kiriman);
  final teringan = cariKirimanTeringan(kiriman);
  final jumlahKategori = hitungJumlahKategori(kiriman);

  print('=== ANALISIS DATA KIRIMAN ===');
  print('Jumlah kiriman : ${kiriman.length}');
  print(
    'Total berat : '
    '${totalBerat.toStringAsFixed(2)} kg',
  );
  print(
    'Rata-rata berat : '
    '${rataRata.toStringAsFixed(2)} kg',
  );

  print('\n--- Kiriman Terberat ---');
  print('Resi : ${terberat.resi}');
  print(
    'Berat : '
    '${terberat.berat.toStringAsFixed(2)} kg',
  );

  print('\n--- Kiriman Teringan ---');
  print('Resi : ${teringan.resi}');
  print(
    'Berat : '
    '${teringan.berat.toStringAsFixed(2)} kg',
  );

  print('\n--- Jumlah Kiriman per Kategori ---');
  print(
    'Paket Kecil : '
    '${jumlahKategori['Paket Kecil']} kiriman',
  );
  print(
    'Paket Sedang : '
    '${jumlahKategori['Paket Sedang']} kiriman',
  );
  print(
    'Kargo : '
    '${jumlahKategori['Kargo']} kiriman',
  );
}

void main() {
  final List<Kiriman> kiriman = [
    Kiriman(resi: 'SLG-001', berat: 2.5),
    Kiriman(resi: 'SLG-002', berat: 5.0),
    Kiriman(resi: 'SLG-003', berat: 7.5),
    Kiriman(resi: 'SLG-004', berat: 12.0),
    Kiriman(resi: 'SLG-005', berat: 18.5),
    Kiriman(resi: 'SLG-006', berat: 25.0),
    Kiriman(resi: 'SLG-007', berat: 3.5),
    Kiriman(resi: 'SLG-008', berat: 30.0),
  ];

  tampilkanHasil(kiriman);
}