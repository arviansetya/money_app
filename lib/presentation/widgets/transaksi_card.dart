import 'package:flutter/material.dart';
import '../../data/models/transaksi_model.dart';
import '../utils/format_utils.dart';

class TransaksiCard extends StatelessWidget {
  final TransaksiModel transaksi;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final VoidCallback? onViewFoto;

  const TransaksiCard({
    super.key,
    required this.transaksi,
    required this.onEdit,
    required this.onHapus,
    this.onViewFoto,
  });

  @override
  Widget build(BuildContext context) {
    final isPemasukan = transaksi.tipe == 'pemasukan';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPemasukan
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isPemasukan ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaksi.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (transaksi.kategori.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                transaksi.kategori,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          Text(
                            transaksi.tanggal,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatIdrSigned(
                    transaksi.jumlah,
                    isPositive: isPemasukan,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isPemasukan ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (transaksi.catatan.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                transaksi.catatan,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onViewFoto != null) ...[
                    IconButton(
                      onPressed: onViewFoto,
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      tooltip: 'Lihat Struk',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onHapus,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    tooltip: 'Hapus',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
