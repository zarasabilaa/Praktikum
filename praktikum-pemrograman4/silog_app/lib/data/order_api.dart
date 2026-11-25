
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../model/order.dart';

/// Exception khusus untuk kegagalan layanan API.
class GagalApi implements Exception {
  final String pesan;
  final int? kode;

  GagalApi(this.pesan, {this.kode});

  @override
  String toString() {
    if (kode != null) {
      return '$pesan (HTTP $kode)';
    }

    return pesan;
  }
}

class OrderApi {
  // Alamat API JSONPlaceholder
  static const String _basis =
      'https://jsonplaceholder.typicode.com';

  // HTTP Client
  final http.Client _client = http.Client();

  // Cache lokal Sembast
  final _OrderLocalCache _cache = _OrderLocalCache();

  // Pesan ketika data diambil dari cache
  String? _pesanPeringatan;

  String? get pesanPeringatan => _pesanPeringatan;

  // =========================
  // GET: MENGAMBIL DAFTAR ORDER
  // =========================
  Future<List<Order>> ambilDaftar() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_basis/posts?_limit=10'),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw GagalApi(
          'Gagal mengambil daftar order',
          kode: response.statusCode,
        );
      }

      final List<dynamic> jsonData =
          jsonDecode(response.body) as List<dynamic>;

      final daftarOrder = jsonData.map((item) {
        return Order.fromJson(
          item as Map<String, dynamic>,
        );
      }).toList();

      // Simpan data API ke cache lokal
      await _cache.simpanSemua(daftarOrder);

      _pesanPeringatan = null;

      return daftarOrder;
    } catch (e) {
      // Jika API gagal, gunakan cache lokal
      final dataCache = await _cache.ambilSemua();

      if (dataCache.isNotEmpty) {
        _pesanPeringatan =
            'Koneksi API gagal. Data ditampilkan dari cache lokal.';

        return dataCache;
      }

      if (e is GagalApi) {
        rethrow;
      }

      throw GagalApi(
        'Tidak dapat mengambil data order: $e',
      );
    }
  }

  // =========================
  // GET: MENGAMBIL DATA DENGAN CADANGAN
  // =========================
  Future<List<Order>> ambilDenganCadangan() async {
    return ambilDaftar();
  }

  // =========================
  // SEARCH: MENCARI ORDER
  // =========================
  List<Order> cariOrder(
    List<Order> daftarOrder,
    String kataKunci,
  ) {
    final keyword = kataKunci.trim().toLowerCase();

    if (keyword.isEmpty) {
      return daftarOrder;
    }

    return daftarOrder.where((order) {
      return order.judul
          .toLowerCase()
          .contains(keyword);
    }).toList();
  }

  // =========================
  // POST: MENGIRIM ORDER
  // =========================
  Future<Order> kirimOrder(Order order) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_basis/posts'),
            headers: {
              'Content-Type':
                  'application/json; charset=UTF-8',
            },
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 201) {
        return Order.fromJson(
          jsonDecode(response.body)
              as Map<String, dynamic>,
        );
      }

      throw GagalApi(
        'Gagal mengirim order',
        kode: response.statusCode,
      );
    } catch (e) {
      if (e is GagalApi) {
        rethrow;
      }

      throw GagalApi(
        'Terjadi kesalahan saat mengirim order: $e',
      );
    }
  }

  // =========================
  // PUT: MEMPERBARUI ORDER
  // =========================
  Future<Order> perbaruiOrder(Order order) async {
    if (order.id == null) {
      throw GagalApi('ID order tidak boleh kosong');
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$_basis/posts/${order.id}'),
            headers: {
              'Content-Type':
                  'application/json; charset=UTF-8',
            },
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return Order.fromJson(
          jsonDecode(response.body)
              as Map<String, dynamic>,
        );
      }

      throw GagalApi(
        'Gagal memperbarui order',
        kode: response.statusCode,
      );
    } catch (e) {
      if (e is GagalApi) {
        rethrow;
      }

      throw GagalApi(
        'Terjadi kesalahan saat memperbarui order: $e',
      );
    }
  }

  // =========================
  // DELETE: MENGHAPUS ORDER
  // =========================
  Future<void> hapusOrder(int id) async {
    if (id <= 0) {
      throw GagalApi('ID order tidak valid');
    }

    try {
      final response = await _client
          .delete(
            Uri.parse('$_basis/posts/$id'),
            headers: {
              'Content-Type':
                  'application/json; charset=UTF-8',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return;
      }

      throw GagalApi(
        'Gagal menghapus order',
        kode: response.statusCode,
      );
    } catch (e) {
      if (e is GagalApi) {
        rethrow;
      }

      throw GagalApi(
        'Terjadi kesalahan saat menghapus order: $e',
      );
    }
  }

  // =========================
  // MENUTUP HTTP CLIENT
  // =========================
  void tutup() {
    _client.close();
  }
}

// ==================================================
// CACHE LOKAL SEMBAST
// ==================================================
class _OrderLocalCache {
  static const String _namaDatabase = 'order_cache.db';

  final StoreRef<int, Map<String, dynamic>> _store =
      StoreRef<int, Map<String, dynamic>>.main();

  Database? _database;

  // Membuka database Sembast
  Future<Database> _bukaDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final directory =
        await getApplicationDocumentsDirectory();

    final path =
        '${directory.path}/$_namaDatabase';

    _database = await databaseFactoryIo.openDatabase(
      path,
    );

    return _database!;
  }

  // Menyimpan seluruh daftar order
  Future<void> simpanSemua(
    List<Order> daftarOrder,
  ) async {
    try {
      final db = await _bukaDatabase();

      await db.transaction((transaction) async {
        await _store.delete(transaction);

        for (final order in daftarOrder) {
          await _store.add(
            transaction,
            order.toJson(),
          );
        }
      });
    } catch (e) {
      debugPrint('Gagal menyimpan cache order: $e');
    }
  }

  // Mengambil daftar order dari cache
  Future<List<Order>> ambilSemua() async {
    try {
      final db = await _bukaDatabase();

      final records = await _store.find(db);

      return records.map((record) {
        return Order.fromJson(record.value);
      }).toList();
    } catch (e) {
      debugPrint('Gagal membaca cache order: $e');
      return [];
    }
  }
}
