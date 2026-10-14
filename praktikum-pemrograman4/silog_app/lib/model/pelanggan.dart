class Pelanggan {
  final String kode;
  final String nama;
  final String nomorTelepon;
  final String alamat;

  Pelanggan({
    required this.kode,
    required this.nama,
    required this.nomorTelepon,
    required this.alamat,
  });

  String alamatRingkas() {
    final alamatLengkap = alamat.trim();

    if (alamatLengkap.length <= 40) {
      return alamatLengkap;
    }

    return '${alamatLengkap.substring(0, 37)}...';
  }

  @override
  String toString() {
    return '[$kode] $nama - $nomorTelepon';
  }
}