import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/transaksi_model.dart';

class TransaksiRepository {
  final _supabase = Supabase.instance.client;

  Future<List<TransaksiModel>> getTransaksi() async {
    try {
      final response = await _supabase
          .from(ApiConstants.transaksiTable)
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));
      return (response as List)
          .map((json) => TransaksiModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('getTransaksi error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<TransaksiModel>> getTransaksiByEntity(int entityId) async {
    try {
      debugPrint('getTransaksiByEntity: entityId=$entityId');
      final response = await _supabase
          .from(ApiConstants.transaksiTable)
          .select()
          .eq('entity_id', entityId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));
      debugPrint('getTransaksiByEntity response: $response');
      return (response as List)
          .map((json) => TransaksiModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('getTransaksiByEntity error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<TransaksiModel> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      final data = transaksi.toJson();
      debugPrint('tambahTransaksi data: $data');
      final response = await _supabase
          .from(ApiConstants.transaksiTable)
          .insert(data)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      debugPrint('tambahTransaksi response: $response');
      return TransaksiModel.fromJson(response);
    } catch (e) {
      debugPrint('tambahTransaksi error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<TransaksiModel> editTransaksi(TransaksiModel transaksi) async {
    try {
      final response = await _supabase
          .from(ApiConstants.transaksiTable)
          .update(transaksi.toJson())
          .eq('id', transaksi.id)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      return TransaksiModel.fromJson(response);
    } catch (e) {
      debugPrint('editTransaksi error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> hapusTransaksi(String id) async {
    try {
      await _supabase
          .from(ApiConstants.transaksiTable)
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('hapusTransaksi error: $e');
      throw Exception('Error: $e');
    }
  }
} 