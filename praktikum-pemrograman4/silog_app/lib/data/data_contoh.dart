import '../model/barang.dart';
import '../model/gudang.dart';
import '../model/pengiriman.dart';
import '../model/pelanggan.dart';

final gudangBandung = Gudang(
     kode: 'GD-BDG', nama: 'Gudang Utama Bandung', kota: 'Bandung');
final List<Pengiriman> dataPengiriman = [
    Pengiriman(
        pelanggan: Pelanggan(
        kode: 'PLG001',
        nama: 'Buwana',
        nomorTelepon: '081234567890',
        alamat: 'Bandung',),
      resi: 'SLG-2026-0001',
      asal: gudangBandung,
      kotaTujuan: 'Surabaya',
      barang: Barang(kode: 'B-1024', nama: 'Sepatu Lari Pria', hargaSatuan: 450000),
      jumlah: 10,
      tanggalKirim: DateTime(2026, 9, 8),
      status: 'Dalam Perjalanan',
    ),
    Pengiriman(
        pelanggan: Pelanggan(
        kode: 'PLG002',
        nama: 'Andi',
        nomorTelepon: '081234567891',
        alamat: 'Jakarta',
        ),
      resi: 'SLG-2026-0002',
      asal: gudangBandung,
      kotaTujuan: 'Makassar',
      barang: Barang(kode: 'B-2048', nama: 'Kaos Katun', hargaSatuan: 85000),
      jumlah: 120,
      tanggalKirim: DateTime(2026, 9, 9),
      status: 'Menunggu Pickup',
    ),
    Pengiriman(
        pelanggan: Pelanggan(
          kode: 'PLG003',
          nama: 'Salma',
          nomorTelepon: '081234567892',
          alamat: 'Surabaya',
        ),
      resi: 'SLG-2026-0003',
      asal: gudangBandung,
      kotaTujuan: 'Medan',
      barang: Barang(kode: 'B-3072', nama: 'Tas Ransel', hargaSatuan: 275000),
      jumlah: 35,
      tanggalKirim: DateTime(2026, 9, 10),
      status: 'Diterima',
    ),
  ];