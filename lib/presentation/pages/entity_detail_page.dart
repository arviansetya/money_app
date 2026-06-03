import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/entity_model.dart';
import '../../data/models/transaksi_model.dart';
import '../utils/format_utils.dart';
import '../utils/notification_utils.dart';
import '../utils/pdf_generator.dart';
import '../widgets/transaksi_card.dart';
import 'transaksi_provider.dart';
import 'form_transaksi_page.dart';

class EntityDetailPage extends StatefulWidget {
  final EntityModel entity;
  const EntityDetailPage({super.key, required this.entity});

  @override
  State<EntityDetailPage> createState() => _EntityDetailPageState();
}

class _EntityDetailPageState extends State<EntityDetailPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'Semua';
  final DateFormat _filterDateFormat = DateFormat('d/M/yyyy');

  DateTime _parseTanggal(String tanggal) {
    try {
      return _filterDateFormat.parseLoose(tanggal);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _pickFilterDate(bool isStart) async {
    final initial = isStart
        ? _startDate ?? DateTime.now()
        : _endDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  List<String> _categories(TransaksiProvider provider) {
    final categories = <String>{};
    for (final transaksi in provider.transaksi) {
      if (transaksi.kategori.isNotEmpty) {
        categories.add(transaksi.kategori);
      }
    }
    return ['Semua', ...categories];
  }

  List<TransaksiModel> _filteredTransaksi(TransaksiProvider provider) {
    return provider.transaksi.where((transaksi) {
      if (_selectedCategory != 'Semua' &&
          transaksi.kategori != _selectedCategory) {
        return false;
      }
      final tanggal = _parseTanggal(transaksi.tanggal);
      if (_startDate != null && tanggal.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && tanggal.isAfter(_endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategory = 'Semua';
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).getTransaksiByEntity(int.parse(widget.entity.id));
    });
  }

  Future<void> _generatePdf(
    BuildContext context,
    List<TransaksiModel> transaksi,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await PdfGenerator.generateTransaksiReport(
        transaksi,
        'Rekap ${widget.entity.nama}',
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'rekap_${widget.entity.nama}.pdf',
      );
    } catch (e) {
      debugPrint('Generate PDF error: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membuat PDF.')),
      );
    }
  }

  Future<void> _savePdf(
    BuildContext context,
    List<TransaksiModel> transaksi,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await PdfGenerator.generateTransaksiReport(
        transaksi,
        'Rekap ${widget.entity.nama}',
      );

      Directory? targetDir;

      // 1) Try common public Downloads path on Android devices
      if (Platform.isAndroid) {
        try {
          final androidDownload = Directory('/storage/emulated/0/Download');
          if (await androidDownload.exists()) {
            targetDir = androidDownload;
          }
        } catch (_) {
          // ignore
        }
      }

      // 2) Try external storage Downloads via path_provider
      if (targetDir == null) {
        try {
          final dirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads,
          );
          if (dirs != null && dirs.isNotEmpty) {
            targetDir = dirs.first;
          }
        } catch (_) {
          // ignore
        }
      }

      // 3) Fallback to app documents
      targetDir ??= await getApplicationDocumentsDirectory();

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final filename =
          'rekap_${widget.entity.nama.replaceAll(RegExp(r"[^a-zA-Z0-9_]"), '_')}.pdf';
      final file = File('${targetDir.path}/$filename');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('PDF disimpan: ${file.path}')),
      );
    } catch (e) {
      debugPrint('Save PDF error: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan PDF.')),
      );
    }
  }

  void _showFotoStruk(BuildContext context, String fotoPath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Foto Struk'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: kIsWeb
                ? Image.network(fotoPath, fit: BoxFit.contain)
                : Image.file(File(fotoPath), fit: BoxFit.contain),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, child) {
        final filteredTransaksi = _filteredTransaksi(provider);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.entity.nama),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Bagikan PDF',
                onPressed: filteredTransaksi.isEmpty
                    ? null
                    : () => _generatePdf(context, filteredTransaksi),
                icon: const Icon(Icons.share),
              ),
              IconButton(
                tooltip: 'Unduh PDF',
                onPressed: filteredTransaksi.isEmpty
                    ? null
                    : () => _savePdf(context, filteredTransaksi),
                icon: const Icon(Icons.download),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(provider.errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.getTransaksiByEntity(
                          int.parse(widget.entity.id),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (widget.entity.deskripsi.isNotEmpty)
                            Text(
                              widget.entity.deskripsi,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          if (widget.entity.tanggalMulai.isNotEmpty)
                            Text(
                              '${widget.entity.tanggalMulai} - ${widget.entity.tanggalSelesai.isEmpty ? 'sekarang' : widget.entity.tanggalSelesai}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 12),
                          const Text(
                            'Saldo',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            FormatUtils.formatIdr(provider.saldo),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.greenAccent,
                                        size: 14,
                                      ),
                                      Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    FormatUtils.formatIdr(
                                      provider.totalPemasukan,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white30,
                              ),
                              Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                      Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    FormatUtils.formatIdr(
                                      provider.totalPengeluaran,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Filter Transaksi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _pickFilterDate(true),
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  _startDate == null
                                      ? 'Dari'
                                      : _filterDateFormat.format(_startDate!),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _pickFilterDate(false),
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  _endDate == null
                                      ? 'Sampai'
                                      : _filterDateFormat.format(_endDate!),
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedCategory,
                                items: _categories(provider)
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                              TextButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // List Transaksi
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.getTransaksiByEntity(
                          int.parse(widget.entity.id),
                        ),
                        child: provider.transaksi.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 80),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Belum ada transaksi',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : filteredTransaksi.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 80),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Tidak ada transaksi yang cocok dengan filter',
                                          style: TextStyle(color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: filteredTransaksi.length,
                                itemBuilder: (context, index) {
                                  final item = filteredTransaksi[index];
                                  return TransaksiCard(
                                    transaksi: item,
                                    onViewFoto: item.fotoUrl != null
                                        ? () => _showFotoStruk(
                                            context,
                                            item.fotoUrl!,
                                          )
                                        : null,
                                    onEdit: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormTransaksiPage(
                                            transaksi: item,
                                            entityId: widget.entity.id,
                                          ),
                                        ),
                                      ).then(
                                        (_) => provider.getTransaksiByEntity(
                                          int.parse(widget.entity.id),
                                        ),
                                      );
                                    },
                                    onHapus: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Hapus Transaksi?'),
                                          content: Text(
                                            'Yakin hapus "${item.judul}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(dialogContext);
                                                await provider.hapusTransaksi(item.id);
                                                if (!context.mounted) return;
                                                if (provider.errorMessage.isNotEmpty) {
                                                  NotificationUtils.showError(
                                                    context,
                                                    'Gagal menghapus transaksi: ${provider.errorMessage}',
                                                  );
                                                } else {
                                                  NotificationUtils.showSuccess(
                                                    context,
                                                    'Transaksi "${item.judul}" berhasil dihapus.',
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final transaksiProvider = Provider.of<TransaksiProvider>(
                context,
                listen: false,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormTransaksiPage(entityId: widget.entity.id),
                ),
              ).then(
                (_) => transaksiProvider.getTransaksiByEntity(
                  int.parse(widget.entity.id),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
