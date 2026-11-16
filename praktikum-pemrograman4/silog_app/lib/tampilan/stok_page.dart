
import 'package:flutter/material.dart';

import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../model/stok.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _repo = StokRepository.instance;
  final _pref = Preferensi();

  final TextEditingController _cariController =
      TextEditingController();

  List<Stok> _daftar = [];

  String _gudang = 'GD-BDG';
  String _kataKunci = '';

  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // MEMUAT DATA STOK
  Future<void> _muat() async {
    if (mounted) {
      setState(() {
        _memuat = true;
      });
    }

    try {
      final gudang = await _pref.ambilGudangTerakhir();

      _gudang = gudang;

      final data = await _repo.cariNamaBarang(
        kataKunci: _kataKunci,
        kodeGudang: _gudang,
      );

      if (!mounted) return;

      setState(() {
        _daftar = data;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _memuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data stok: $e'),
        ),
      );
    }
  }

  // PENCARIAN NAMA BARANG
  Future<void> _cariStok(String kataKunci) async {
    setState(() {
      _kataKunci = kataKunci;
      _memuat = true;
    });

    try {
      final hasil = await _repo.cariNamaBarang(
        kataKunci: kataKunci,
        kodeGudang: _gudang,
      );

      if (!mounted) return;

      setState(() {
        _daftar = hasil;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _memuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pencarian gagal: $e'),
        ),
      );
    }
  }

  // TAMBAH STOK
  Future<void> _tambahStok() async {
    final formKey = GlobalKey<FormState>();

    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final jumlahController = TextEditingController();

    try {
      final stokBaru = await showDialog<Stok>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Tambah Data Stok'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: kodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Barang',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization:
                          TextCapitalization.characters,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Kode barang wajib diisi';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nama barang wajib diisi';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Jumlah stok wajib diisi';
                        }

                        final jumlah =
                            int.tryParse(value.trim());

                        if (jumlah == null || jumlah <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final stok = Stok(
                      kodeBarang:
                          kodeController.text.trim(),
                      namaBarang:
                          namaController.text.trim(),
                      kodeGudang: _gudang,
                      jumlah: int.parse(
                        jumlahController.text.trim(),
                      ),
                      diperbaruiPada: DateTime.now(),
                    );

                    Navigator.pop(dialogContext, stok);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );

      if (stokBaru == null) return;

      await _repo.simpan(stokBaru);

      _kataKunci = '';
      _cariController.clear();

      await _muat();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data stok berhasil ditambahkan'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan stok: $e'),
        ),
      );
    } finally {
      kodeController.dispose();
      namaController.dispose();
      jumlahController.dispose();
    }
  }

  // TAMBAH ATAU KURANGI JUMLAH STOK
  Future<void> _ubahJumlah(
    Stok stok,
    int delta,
  ) async {
    final baru = stok.jumlah + delta;

    if (baru < 0) return;

    try {
      await _repo.perbarui(
        stok.salinDengan(jumlah: baru),
      );

      await _cariStok(_kataKunci);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui stok: $e'),
        ),
      );
    }
  }

  // HAPUS DATA STOK
  Future<void> _hapus(Stok stok) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus data stok'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '${stok.namaBarang}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin != true || stok.id == null) return;

    try {
      await _repo.hapus(stok.id!);

      await _cariStok(_kataKunci);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data stok berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus stok: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(
      0,
      (jumlah, stok) => jumlah + stok.jumlah,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Gudang $_gudang'),
      ),

      body: Column(
        children: [
          // KOLOM PENCARIAN
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _cariController,
              onChanged: _cariStok,
              decoration: InputDecoration(
                hintText: 'Cari nama barang...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _cariController.clear();
                          _cariStok('');
                        },
                        icon: const Icon(Icons.clear),
                        tooltip: 'Hapus pencarian',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // TOTAL STOK
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total stok pada hasil pencarian: $total unit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // DAFTAR STOK
          Expanded(
            child: _memuat
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _daftar.isEmpty
                    ? Center(
                        child: Text(
                          _kataKunci.isEmpty
                              ? 'Belum ada data stok'
                              : 'Barang "$_kataKunci" tidak ditemukan',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _daftar.length,
                        itemBuilder: (context, index) {
                          final stok = _daftar[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            child: ListTile(
                              title: Text(stok.namaBarang),
                              subtitle: Text(
                                '${stok.kodeBarang} - '
                                '${stok.jumlah} unit',
                              ),
                              leading: const Icon(
                                Icons.inventory_2_outlined,
                              ),
                              trailing: Wrap(
                                spacing: 0,
                                children: [
                                  IconButton(
                                    onPressed: stok.jumlah > 0
                                        ? () => _ubahJumlah(
                                              stok,
                                              -1,
                                            )
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _ubahJumlah(
                                      stok,
                                      1,
                                    ),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _hapus(stok),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // TOMBOL TAMBAH STOK
      floatingActionButton: FloatingActionButton(
        onPressed: _memuat ? null : _tambahStok,
        tooltip: 'Tambah Data Stok',
        child: const Icon(Icons.add),
      ),
    );
  }
}
