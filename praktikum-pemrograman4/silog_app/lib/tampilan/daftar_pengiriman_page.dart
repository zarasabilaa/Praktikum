import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  late List<Pengiriman> _daftar;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();

    // Mengambil data pengiriman awal
    _daftar = List<Pengiriman>.from(dataPengiriman);
  }

  // Menyaring data berdasarkan status pengiriman
  List<Pengiriman> get _hasilSaring {
    return _filterStatus == 'Semua'
        ? _daftar
        : _daftar.where((p) => p.status == _filterStatus).toList();
  }

  // Membuka formulir dan mengirim daftar nomor resi
  Future<void> _bukaFormulir() async {
    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengirimanPage(
          resiTerdaftar: _daftar.map((pengiriman) => pengiriman.resi).toList(),
        ),
      ),
    );

    if (!mounted) return;

    // Menambahkan data pengiriman baru
    if (hasil != null) {
      setState(() {
        _daftar.insert(0, hasil);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengiriman ${hasil.resi} berhasil ditambahkan'),
        ),
      );
    }
  }

  // Membuka halaman detail pengiriman
  Future<void> _bukaDetail(Pengiriman item) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetailPengirimanPage(pengiriman: item)),
    );

    if (!mounted) return;

    // Menghapus data jika pengguna mengonfirmasi
    if (hasil == true) {
      setState(() {
        _daftar.remove(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengiriman ${item.resi} berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const opsi = ['Semua', 'Menunggu Pickup', 'Dalam Perjalanan', 'Diterima'];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengiriman')),

      body: Column(
        children: [
          // Pilihan filter status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: opsi.map((o) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: _filterStatus == o,
                    onSelected: (_) {
                      setState(() {
                        _filterStatus = o;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Informasi jumlah data
          Text(
            'Menampilkan ${_hasilSaring.length} '
            'dari ${_daftar.length} data',
          ),

          // Daftar pengiriman
          Expanded(
            child: _hasilSaring.isEmpty
                ? const Center(child: Text('Tidak ada data pengiriman'))
                : ListView.builder(
                    itemCount: _hasilSaring.length,
                    itemBuilder: (context, i) {
                      final item = _hasilSaring[i];

                      return KartuPengiriman(
                        pengiriman: item,
                        onTap: () {
                          _bukaDetail(item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // Tombol tambah pengiriman
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
    );
  }
}
