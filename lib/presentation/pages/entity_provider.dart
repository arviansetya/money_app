import 'package:flutter/material.dart';
import '../../data/models/entity_model.dart';
import '../../data/repositories/entity_repository.dart';

class EntityProvider extends ChangeNotifier {
  final EntityRepository _repository = EntityRepository();

  List<EntityModel> _entities = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<EntityModel> get entities => _entities;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // GET semua entity
  Future<void> getEntity() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _entities = await _repository.getEntity();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // POST tambah entity
  Future<void> tambahEntity(EntityModel entity) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final baru = await _repository.tambahEntity(entity);
      _entities.insert(0, baru);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // PUT edit entity
  Future<void> editEntity(EntityModel entity) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updated = await _repository.editEntity(entity);
      final index = _entities.indexWhere((e) => e.id == entity.id);
      if (index != -1) _entities[index] = updated;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // DELETE hapus entity
  Future<void> hapusEntity(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.hapusEntity(id);
      _entities.removeWhere((e) => e.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}