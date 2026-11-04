import 'package:flutter/material.dart';

import '../model/pengiriman.dart';

class DetailPengirimanPage extends StatelessWidget {
  final Pengiriman pengiriman;

  const DetailPengirimanPage({super.key, required this.pengiriman});

  // Widget untuk menampilkan baris informasi
  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const Text(': '),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }

  // Menampilkan dialog konfirmasi hapus
  Future<void> _konfirmasiHapus(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Pengiriman?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            'pengiriman dengan nomor resi ${pengiriman.resi}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true && context.mounted) {
      // Mengirim hasil penghapusan ke halaman daftar
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tgl = pengiriman.tanggalKirim;

    return Scaffold(
      appBar: AppBar(title: Text(pengiriman.resi)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Pengiriman
            Text(
              'Informasi Pengiriman',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(height: 24),

            _baris('Nomor Resi', pengiriman.resi),
            _baris('Status', pengiriman.status),
            _baris('Gudang Asal', pengiriman.asal.nama),
            _baris('Kota Tujuan', pengiriman.kotaTujuan),
            _baris('Tanggal Kirim', '${tgl.day}/${tgl.month}/${tgl.year}'),

            const SizedBox(height: 16),

            // Rincian Barang
            Text(
              'Rincian Barang',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(height: 24),

            _baris('Kode Barang', pengiriman.barang.kode),
            _baris('Nama Barang', pengiriman.barang.nama),
            _baris(
              'Jumlah',
              '${pengiriman.jumlah} ${pengiriman.barang.satuan}',
            ),
            _baris('Berat Barang', '${pengiriman.barang.beratKg} kg'),
            _baris(
              'Nilai Barang',
              'Rp${pengiriman.nilaiBarang.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 24),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),

            const SizedBox(height: 12),

            // Tombol Hapus
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _konfirmasiHapus(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus Pengiriman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
