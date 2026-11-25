class Order {
  final int? id;
  final int idPelanggan;
  final String judul;
  final String keterangan;

  Order({
    this.id,
    required this.idPelanggan,
    required this.judul,
    required this.keterangan,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int?,
        idPelanggan: json['userId'] as int? ?? 0,
        judul: (json['title'] as String?) ?? '(tanpa judul)',
        keterangan: (json['body'] as String?) ?? '',
      );

  get title => null;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': idPelanggan,
        'title': judul,
        'body': keterangan,
      };

  @override
  String toString() => 'Order#$id $judul';
}