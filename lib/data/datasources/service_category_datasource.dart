import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_category_model.dart';

class ServiceCategoryDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ServiceCategoryModel>> getAll(String companyId) async {
    final data = await _client
        .from('service_categories')
        .select()
        .eq('company_id', companyId)
        .order('sort_order');
    return (data as List).map((e) => ServiceCategoryModel.fromJson(e)).toList();
  }

  Future<ServiceCategoryModel> create({
    required String companyId,
    required String name,
    String? description,
    String? colorHex,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('service_categories')
        .insert({
          'company_id': companyId,
          'name': name,
          'description': description,
          'color_hex': colorHex,
          'sort_order': sortOrder,
        })
        .select()
        .single();
    return ServiceCategoryModel.fromJson(data);
  }

  Future<ServiceCategoryModel> update({
    required String id,
    required String name,
    String? description,
    String? colorHex,
    required int sortOrder,
  }) async {
    final data = await _client
        .from('service_categories')
        .update({
          'name': name,
          'description': description,
          'color_hex': colorHex,
          'sort_order': sortOrder,
        })
        .eq('id', id)
        .select()
        .single();
    return ServiceCategoryModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('service_categories').update({'is_active': isActive}).eq('id', id);
  }
}
