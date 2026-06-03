import '../../domain/entities/transaksi.dart';

class TransaksiModel extends Transaksi {
  TransaksiModel({
    required super.id,
    required super.judul,
    required super.jumlah,
    required super.tipe,
    required super.tanggal,
    required super.catatan,
    required super.kategori,
    super.entityId,
    super.fotoUrl,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'].toString(),
      judul: json['judul'] ?? '',
      jumlah: double.parse(json['jumlah'].toString()),
      tipe: json['tipe'] ?? 'pengeluaran',
      tanggal: json['tanggal'] ?? '',
      catatan: json['catatan'] ?? '',
      kategori: json['kategori'] ?? '',
      entityId: json['entity_id']?.toString(),
      fotoUrl: json['foto_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'jumlah': jumlah,
      'tipe': tipe,
      'tanggal': tanggal,
      'catatan': catatan,
      if (kategori.isNotEmpty) 'kategori': kategori,
      if (entityId != null) 'entity_id': entityId,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}