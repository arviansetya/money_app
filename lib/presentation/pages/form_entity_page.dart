import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/entity_model.dart';
import '../utils/notification_utils.dart';
import 'entity_provider.dart';

class FormEntityPage extends StatefulWidget {
  final EntityModel? entity;
  const FormEntityPage({super.key, this.entity});

  @override
  State<FormEntityPage> createState() => _FormEntityPageState();
}

class _FormEntityPageState extends State<FormEntityPage> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  bool _isSaving = false;
  bool get _isEdit => widget.entity != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaController.text = widget.entity!.nama;
      _deskripsiController.text = widget.entity!.deskripsi;
      _tanggalMulaiController.text = widget.entity!.tanggalMulai;
      _tanggalSelesaiController.text = widget.entity!.tanggalSelesai;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _simpan() async {
    if (_namaController.text.isEmpty) {
      NotificationUtils.showError(context, 'Nama entity wajib diisi!');
      return;
    }

    final provider = Provider.of<EntityProvider>(context, listen: false);
    final entity = EntityModel(
      id: _isEdit ? widget.entity!.id : '',
      nama: _namaController.text,
      deskripsi: _deskripsiController.text,
      tanggalMulai: _tanggalMulaiController.text,
      tanggalSelesai: _tanggalSelesaiController.text,
    );

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await provider.editEntity(entity);
      } else {
        await provider.tambahEntity(entity);
      }

      if (provider.errorMessage.isNotEmpty) {
        throw Exception(provider.errorMessage);
      }

      if (mounted) {
        NotificationUtils.showSuccess(
          context,
          _isEdit ? 'Entity berhasil diperbarui.' : 'Entity berhasil dibuat.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        NotificationUtils.showError(
          context,
          'Gagal menyimpan entity: ${e.toString()}',
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
        title: Text(_isEdit ? 'Edit Entity' : 'Tambah Entity'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Nama
            const Text('Nama Entity',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Contoh: Tugas Onsite Bali',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.folder),
              ),
            ),

            const SizedBox(height: 16),

            // Deskripsi
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deskripsi singkat...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal Mulai
            const Text('Tanggal Mulai',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tanggalMulaiController,
              readOnly: true,
              onTap: () => _pilihTanggal(_tanggalMulaiController),
              decoration: InputDecoration(
                hintText: 'Pilih tanggal...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal Selesai
            const Text('Tanggal Selesai',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tanggalSelesaiController,
              readOnly: true,
              onTap: () => _pilihTanggal(_tanggalSelesaiController),
              decoration: InputDecoration(
                hintText: 'Pilih tanggal...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                        _isEdit ? 'Update Entity' : 'Simpan Entity',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
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