import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../models/entity_model.dart';

class EntityRepository {
  final _supabase = Supabase.instance.client;

  // GET semua entity
  Future<List<EntityModel>> getEntity() async {
    try {
      final response = await _supabase
          .from(ApiConstants.entityTable)
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));
      return (response as List)
          .map((json) => EntityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // POST tambah entity
  Future<EntityModel> tambahEntity(EntityModel entity) async {
    try {
      final response = await _supabase
          .from(ApiConstants.entityTable)
          .insert(entity.toJson())
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      return EntityModel.fromJson(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // PUT edit entity
  Future<EntityModel> editEntity(EntityModel entity) async {
    try {
      final response = await _supabase
          .from(ApiConstants.entityTable)
          .update(entity.toJson())
          .eq('id', entity.id)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      return EntityModel.fromJson(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // DELETE hapus entity
  Future<void> hapusEntity(String id) async {
    try {
      await _supabase
          .from(ApiConstants.entityTable)
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}