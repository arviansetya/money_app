import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/transaksi_model.dart';

class PdfGenerator {
  static Future<Uint8List> generateTransaksiReport(
    List<TransaksiModel> transaksi,
    String title,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalPemasukan = transaksi
        .where((t) => t.tipe == 'pemasukan')
        .fold(0.0, (sum, t) => sum + t.jumlah);
    final totalPengeluaran = transaksi
        .where((t) => t.tipe == 'pengeluaran')
        .fold(0.0, (sum, t) => sum + t.jumlah);

    final imageBytes = <String, Uint8List>{};
    for (final item in transaksi) {
      if (item.fotoUrl != null && item.fotoUrl!.isNotEmpty) {
        try {
          final file = File(item.fotoUrl!);
          if (await file.exists()) {
            imageBytes[item.id] = await file.readAsBytes();
          }
        } catch (_) {
          // Ignore image loading errors.
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 6),
                    pw.Text('Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(now)}',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text('Total: ${currency.format(totalPemasukan - totalPengeluaran)}',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Jumlah Transaksi: ${transaksi.length}',
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text('Pemasukan: ${currency.format(totalPemasukan)}',
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text('Pengeluaran: ${currency.format(totalPengeluaran)}',
                    style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Divider(height: 24, thickness: 1),
            ...transaksi.map((item) => _buildItem(item, imageBytes[item.id], currency)).expand((widget) => widget),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildItem(
    TransaksiModel item,
    Uint8List? fotoBytes,
    NumberFormat currency,
  ) {
    final isPemasukan = item.tipe == 'pemasukan';
    final row = <pw.Widget>[
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.judul,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(item.tanggal, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                if (item.catatan.isNotEmpty)
                  pw.Text(item.catatan, style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${isPemasukan ? '+' : '-'} ${currency.format(item.jumlah)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: isPemasukan ? PdfColors.green800 : PdfColors.red800,
                  ),
                ),
                if (item.fotoUrl != null && item.fotoUrl!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text('Foto struk tersedia', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ),
              ],
            ),
          ),
          if (fotoBytes != null)
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
              child: pw.Image(pw.MemoryImage(fotoBytes), fit: pw.BoxFit.cover),
            ),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 12),
    ];

    return row;
  }
}
