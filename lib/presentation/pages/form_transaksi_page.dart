import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaksi_model.dart';
import '../utils/notification_utils.dart';
import 'transaksi_provider.dart';

class FormTransaksiPage extends StatefulWidget {
  final TransaksiModel? transaksi;
  final String? entityId;

  const FormTransaksiPage({super.key, this.transaksi, this.entityId});

  @override
  State<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksiPage> {
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _catatanController = TextEditingController();
  final _tanggalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  String? _fotoPath;
  String _tipe = 'pengeluaran';
  bool _isSaving = false;
  bool get _isEdit => widget.transaksi != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _judulController.text = widget.transaksi!.judul;
      _jumlahController.text = widget.transaksi!.jumlah.toString();
      _kategoriController.text = widget.transaksi!.kategori;
      _catatanController.text = widget.transaksi!.catatan;
      _tipe = widget.transaksi!.tipe;
      _fotoPath = widget.transaksi!.fotoUrl;
      _selectedDate = _parseTanggal(widget.transaksi!.tanggal);
    }
    _tanggalController.text = _formatTanggal(_selectedDate);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _jumlahController.dispose();
    _kategoriController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime date) {
    return DateFormat('d/M/yyyy').format(date);
  }

  DateTime _parseTanggal(String tanggal) {
    try {
      return DateFormat('d/M/yyyy').parseLoose(tanggal);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _pickTanggal() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _tanggalController.text = _formatTanggal(pickedDate);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _fotoPath = pickedFile.path;
      });
    }
  }

  Future<void> _simpan() async {
    if (_judulController.text.isEmpty || _jumlahController.text.isEmpty) {
      NotificationUtils.showError(context, 'Judul dan jumlah wajib diisi!');
      return;
    }

    final jumlahValue = double.tryParse(
      _jumlahController.text.replaceAll(',', '.'),
    );
    if (jumlahValue == null) {
      NotificationUtils.showError(context, 'Masukkan jumlah yang valid.');
      return;
    }

    final provider = Provider.of<TransaksiProvider>(context, listen: false);
    final transaksi = TransaksiModel(
      id: _isEdit ? widget.transaksi!.id : '',
      judul: _judulController.text,
      jumlah: jumlahValue,
      tipe: _tipe,
      tanggal: _formatTanggal(_selectedDate),
      catatan: _catatanController.text,
      kategori: _kategoriController.text,
      entityId: widget.entityId ?? widget.transaksi?.entityId,
      fotoUrl: _fotoPath,
    );

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await provider.editTransaksi(transaksi);
      } else {
        if (transaksi.entityId == null || transaksi.entityId!.isEmpty) {
          throw Exception('Entity belum dipilih.');
        }
        await provider.tambahTransaksi(transaksi);
      }

      if (provider.errorMessage.isNotEmpty) {
        throw Exception(provider.errorMessage);
      }

      if (mounted) {
        NotificationUtils.showSuccess(
          context,
          _isEdit ? 'Transaksi berhasil diperbarui.' : 'Transaksi berhasil disimpan.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        NotificationUtils.showError(
          context,
          'Gagal menyimpan transaksi: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipe Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _tipe = 'pemasukan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _tipe == 'pemasukan'
                                  ? Colors.green
                                  : Colors.grey.shade200,
                              foregroundColor: _tipe == 'pemasukan'
                                  ? Colors.white
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: _tipe == 'pemasukan' ? 2 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _tipe == 'pemasukan'
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                const Text('Pemasukan'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _tipe = 'pengeluaran'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _tipe == 'pengeluaran'
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              foregroundColor: _tipe == 'pengeluaran'
                                  ? Colors.white
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: _tipe == 'pengeluaran' ? 2 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: _tipe == 'pengeluaran'
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                const Text('Pengeluaran'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Judul',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _judulController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Makan siang, Transport...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Jumlah (Rp)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50000',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Kategori (Opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _kategoriController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Makan, Transport, Cicilan',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: _pickTanggal,
                      decoration: InputDecoration(
                        hintText: 'Pilih tanggal transaksi',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.date_range),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Catatan (opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Foto Struk (opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Kamera'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.image),
                            label: const Text('Galeri'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_fotoPath != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: kIsWeb
                                ? Image.network(
                                    _fotoPath!,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_fotoPath!),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _fotoPath = null;
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Hapus foto struk',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Text(
                                _isEdit
                                    ? 'Update Transaksi'
                                    : 'Simpan Transaksi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSaving)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
