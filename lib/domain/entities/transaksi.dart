class Transaksi {
  final String id;
  final String judul;
  final double jumlah;
  final String tipe;
  final String tanggal;
  final String catatan;
  final String kategori;
  final String? entityId;
  final String? fotoUrl;

  Transaksi({
    required this.id,
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
    required this.catatan,
    this.kategori = '',
    this.entityId,
    this.fotoUrl,
  });
}