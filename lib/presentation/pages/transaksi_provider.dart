import 'package:flutter/material.dart';
import '../../data/models/transaksi_model.dart';
import '../../data/repositories/transaksi_repository.dart';

class TransaksiProvider extends ChangeNotifier {
  final TransaksiRepository _repository = TransaksiRepository();

  List<TransaksiModel> _transaksi = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<TransaksiModel> get transaksi => _transaksi;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  double get totalPemasukan => _transaksi
      .where((t) => t.tipe == 'pemasukan')
      .fold(0, (sum, t) => sum + t.jumlah);

  double get totalPengeluaran => _transaksi
      .where((t) => t.tipe == 'pengeluaran')
      .fold(0, (sum, t) => sum + t.jumlah);

  double get saldo => totalPemasukan - totalPengeluaran;

  // GET transaksi by entity
  Future<void> getTransaksiByEntity(int entityId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _transaksi = await _repository.getTransaksiByEntity(entityId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // GET semua transaksi
  Future<void> getTransaksi() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _transaksi = await _repository.getTransaksi();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // POST tambah transaksi
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final baru = await _repository.tambahTransaksi(transaksi);
      _transaksi.insert(0, baru);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // PUT edit transaksi
  Future<void> editTransaksi(TransaksiModel transaksi) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updated = await _repository.editTransaksi(transaksi);
      final index = _transaksi.indexWhere((t) => t.id == transaksi.id);
      if (index != -1) _transaksi[index] = updated;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // DELETE hapus transaksi
  Future<void> hapusTransaksi(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.hapusTransaksi(id);
      _transaksi.removeWhere((t) => t.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
} 