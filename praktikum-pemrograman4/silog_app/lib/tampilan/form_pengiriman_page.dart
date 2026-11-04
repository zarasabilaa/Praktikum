import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/data_contoh.dart';
import '../model/barang.dart';
import '../model/pelanggan.dart';
import '../model/pengiriman.dart';

class FormPengirimanPage extends StatefulWidget {
  final List<String> resiTerdaftar;

  const FormPengirimanPage({super.key, this.resiTerdaftar = const []});

  @override
  State<FormPengirimanPage> createState() => _FormPengirimanPageState();
}

class _FormPengirimanPageState extends State<FormPengirimanPage> {
  final _formKey = GlobalKey<FormState>();

  final _resiC = TextEditingController();
  final _namaBarangC = TextEditingController();
  final _hargaC = TextEditingController();
  final _jumlahC = TextEditingController();
  final _beratC = TextEditingController();

  String _kotaTujuan = 'Surabaya';
  DateTime _tanggalKirim = DateTime.now();

  final List<String> _daftarKota = [
    'Surabaya',
    'Jakarta',
    'Bandung',
    'Yogyakarta',
    'Semarang',
    'Malang',
    'Medan',
    'Bali',
  ];

  @override
  void dispose() {
    _resiC.dispose();
    _namaBarangC.dispose();
    _hargaC.dispose();
    _jumlahC.dispose();
    _beratC.dispose();
    super.dispose();
  }

  String? _wajib(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  // Validasi format dan duplikasi nomor resi
  String? _validasiResi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor resi wajib diisi';
    }

    final nomorResi = value.trim().toUpperCase();

    final polaResi = RegExp(r'^SLG-\d{4}-\d{4}$');

    if (!polaResi.hasMatch(nomorResi)) {
      return 'Format resi: SLG-2026-0001';
    }

    final sudahTerdaftar = widget.resiTerdaftar.any(
      (resi) => resi.trim().toUpperCase() == nomorResi,
    );

    if (sudahTerdaftar) {
      return 'Nomor resi sudah terdaftar, gunakan nomor resi lain';
    }

    return null;
  }

  // Validasi angka
  String? _validasiAngka(
    String? value,
    String label, {
    double min = 1,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }

    final angka = double.tryParse(value.trim());

    if (angka == null) {
      return '$label harus berupa angka';
    }

    if (angka < min) {
      return '$label minimal $min';
    }

    if (max != null && angka > max) {
      return '$label maksimal $max';
    }

    return null;
  }

  String? _validasiTanggal() {
    final hariIni = DateUtils.dateOnly(DateTime.now());
    final tanggalDipilih = DateUtils.dateOnly(_tanggalKirim);

    if (tanggalDipilih.isBefore(hariIni)) {
      return 'Tanggal kirim tidak boleh sebelum hari ini';
    }

    return null;
  }

  Future<void> _pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggalKirim,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (tanggal != null && mounted) {
      setState(() {
        _tanggalKirim = tanggal;
      });
    }
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  // Menyimpan data pengiriman
  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final validasiTanggal = _validasiTanggal();

    if (validasiTanggal != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validasiTanggal)));
      return;
    }

    final nomorResi = _resiC.text.trim().toUpperCase();

    // Pemeriksaan ulang sebelum menyimpan
    final sudahTerdaftar = widget.resiTerdaftar.any(
      (resi) => resi.trim().toUpperCase() == nomorResi,
    );

    if (sudahTerdaftar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor resi sudah terdaftar, gunakan nomor resi lain'),
        ),
      );
      return;
    }

    final pengiriman = Pengiriman(
      resi: nomorResi,
      asal: gudangBandung,
      kotaTujuan: _kotaTujuan,
      barang: Barang(
        kode: 'BRG001',
        nama: _namaBarangC.text.trim(),
        hargaSatuan: double.parse(_hargaC.text.trim()),
        beratKg: double.parse(_beratC.text.trim()),
      ),
      jumlah: int.parse(_jumlahC.text.trim()),
      tanggalKirim: _tanggalKirim,
      pelanggan: Pelanggan(
        kode: 'PLG001',
        nama: 'Pelanggan Umum',
        nomorTelepon: '-',
        alamat: '-',
      ),
      status: 'Menunggu Pickup',
    );

    Navigator.pop(context, pengiriman);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengiriman Baru'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nomor Resi
            TextFormField(
              controller: _resiC,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Nomor Resi',
                border: OutlineInputBorder(),
              ),
              validator: _validasiResi,
            ),

            const SizedBox(height: 16),

            // Nama Barang
            TextFormField(
              controller: _namaBarangC,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              validator: _wajib,
            ),

            const SizedBox(height: 16),

            // Harga Satuan
            TextFormField(
              controller: _hargaC,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga Satuan (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validasiAngka(value, 'Harga satuan'),
            ),

            const SizedBox(height: 16),

            // Jumlah
            TextFormField(
              controller: _jumlahC,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validasiAngka(value, 'Jumlah'),
            ),

            const SizedBox(height: 16),

            // Berat Barang
            TextFormField(
              controller: _beratC,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;

                  if (text.isEmpty || RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
                    return newValue;
                  }

                  return oldValue;
                }),
              ],
              decoration: const InputDecoration(
                labelText: 'Berat Barang (kg)',
                hintText: 'Contoh: 2.5',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  _validasiAngka(value, 'Berat barang', min: 0.1, max: 5000),
            ),

            const SizedBox(height: 16),

            // Kota Tujuan
            DropdownButtonFormField<String>(
              value: _kotaTujuan,
              decoration: const InputDecoration(
                labelText: 'Kota Tujuan',
                border: OutlineInputBorder(),
              ),
              items: _daftarKota.map((kota) {
                return DropdownMenuItem<String>(value: kota, child: Text(kota));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _kotaTujuan = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Tanggal Kirim
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_month),
              label: Text('Tanggal Kirim: ${_formatTanggal(_tanggalKirim)}'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _simpan,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Simpan Pengiriman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
