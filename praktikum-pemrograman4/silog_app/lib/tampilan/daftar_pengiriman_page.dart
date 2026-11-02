
import 'package:flutter/material.dart';
import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatelessWidget {
  const DaftarPengirimanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Cari resi',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Perjalanan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),

        body: Column(
          children: [
            // Widget ringkasan pengiriman
            _RingkasanPengiriman(
              daftarPengiriman: dataPengiriman,
            ),

            // Daftar berdasarkan tab yang dipilih
            Expanded(
              child: TabBarView(
                children: [
                  _DaftarPengiriman(
                    daftarPengiriman: dataPengiriman,
                  ),
                  _DaftarPengiriman(
                    daftarPengiriman: dataPengiriman
                        .where((item) =>
                            item.status == 'Dalam Perjalanan' ||
                            item.status == 'Tiba di Kota Tujuan')
                        .toList(),
                  ),
                  _DaftarPengiriman(
                    daftarPengiriman: dataPengiriman
                        .where((item) =>
                            item.status == 'Diterima')
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }
}

// Widget ringkasan jumlah dan nilai barang
class _RingkasanPengiriman extends StatelessWidget {
  final List<Pengiriman> daftarPengiriman;

  const _RingkasanPengiriman({
    required this.daftarPengiriman,
  });

  @override
  Widget build(BuildContext context) {
    final jumlahPengiriman = daftarPengiriman.length;

    final totalNilaiBarang = daftarPengiriman.fold<double>(
      0,
      (total, item) => total + item.nilaiBarang,
    );

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Pengiriman',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$jumlahPengiriman',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Nilai Barang',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${totalNilaiBarang.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget daftar pengiriman berdasarkan hasil filter
class _DaftarPengiriman extends StatelessWidget {
  final List<Pengiriman> daftarPengiriman;

  const _DaftarPengiriman({
    required this.daftarPengiriman,
  });

  @override
  Widget build(BuildContext context) {
    if (daftarPengiriman.isEmpty) {
      return const Center(
        child: Text('Tidak ada pengiriman'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: daftarPengiriman.length,
      itemBuilder: (context, index) {
        final item = daftarPengiriman[index];

        return KartuPengiriman(
          pengiriman: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailPengirimanPage(pengiriman: item),
              ),
            );
          },
        );
      },
    );
  }
}
