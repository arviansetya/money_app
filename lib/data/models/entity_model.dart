import '../../domain/entities/entity.dart';

class EntityModel extends Entity {
  EntityModel({
    required super.id,
    required super.nama,
    required super.deskripsi,
    required super.tanggalMulai,
    required super.tanggalSelesai,
  });

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
    };
  }
}