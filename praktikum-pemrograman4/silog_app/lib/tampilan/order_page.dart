
import 'package:flutter/material.dart';
import '../data/order_api.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _api = OrderApi();

  // Controller dan kata kunci pencarian
  final TextEditingController _searchController =
      TextEditingController();

  String _kataKunci = '';

  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.ambilDaftar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _api.tutup();
    super.dispose();
  }

  // Memuat ulang daftar order
  Future<void> _muatUlang() async {
    setState(() {
      _future = _api.ambilDaftar();
    });
  }

  // Mengirim contoh order
  Future<void> _kirimContoh() async {
    try {
      final hasil = await _api.kirimOrder(
        Order(
          idPelanggan: 7,
          judul: 'Order pengiriman Bandung - Surabaya',
          keterangan:
              '3 koli, berat total 42 kg, layanan reguler',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order terkirim dengan id ${hasil.id}',
          ),
        ),
      );

      _muatUlang();
    } on GagalApi catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  // Menghapus kata kunci pencarian
  void _hapusPencarian() {
    _searchController.clear();

    setState(() {
      _kataKunci = '';
    });
  }

  // =========================
  // UPDATE ORDER (PUT)
  // =========================
  Future<void> _editOrder(Order order) async {
    final controllerJudul = TextEditingController(
      text: order.judul,
    );

    final controllerKeterangan = TextEditingController(
      text: order.keterangan,
    );

    try {
      final orderBaru = await showDialog<Order>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Order'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controllerJudul,
                    decoration: const InputDecoration(
                      labelText: 'Judul Order',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controllerKeterangan,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  final judul =
                      controllerJudul.text.trim();

                  final keterangan =
                      controllerKeterangan.text.trim();

                  if (judul.isEmpty ||
                      keterangan.isEmpty) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Judul dan keterangan wajib diisi',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    Order(
                      id: order.id,
                      idPelanggan: order.idPelanggan,
                      judul: judul,
                      keterangan: keterangan,
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );

      if (orderBaru == null) return;

      try {
        final hasil = await _api.perbaruiOrder(
          orderBaru,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order ${hasil.id} berhasil diperbarui',
            ),
          ),
        );

        _muatUlang();
      } on GagalApi catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update order: $e'),
          ),
        );
      }
    } finally {
      controllerJudul.dispose();
      controllerKeterangan.dispose();
    }
  }

  // =========================
  // DELETE ORDER
  // =========================
  Future<void> _hapusOrder(Order order) async {
    if (order.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID order tidak ditemukan'),
        ),
      );
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Order'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            'order "${order.judul}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    try {
      await _api.hapusOrder(order.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order ${order.id} berhasil dihapus',
          ),
        ),
      );

      _muatUlang();
    } on GagalApi catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus order: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order dari Layanan Web'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _muatUlang,
          ),
        ],
      ),

      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          // Tampilan loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Tampilan error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 56,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Data order dari API
          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada order yang tercatat',
              ),
            );
          }

          // Filter order berdasarkan judul
          final kataKunci =
              _kataKunci.trim().toLowerCase();

          final orderTampil = data.where((order) {
            return order.judul
                .toLowerCase()
                .contains(kataKunci);
          }).toList();

          return Column(
            children: [
              // Kolom pencarian
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _kataKunci = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Cari order berdasarkan judul...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _kataKunci.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Hapus pencarian',
                            onPressed: _hapusPencarian,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Jumlah hasil pencarian
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ditemukan ${orderTampil.length} order',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Daftar order
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _muatUlang,
                  child: orderTampil.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Order tidak ditemukan',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          itemCount: orderTampil.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final o = orderTampil[i];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${o.id}'),
                              ),
                              title: Text(
                                o.judul,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                o.keterangan,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),

                              // Menu Update dan Delete
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                ),
                                tooltip: 'Aksi order',
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editOrder(o);
                                  } else if (
                                      value == 'hapus') {
                                    _hapusOrder(o);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Edit Order'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'hapus',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Hapus Order'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),

      // Tombol kirim order
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _kirimContoh,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Kirim Order'),
      ),
    );
  }
}
