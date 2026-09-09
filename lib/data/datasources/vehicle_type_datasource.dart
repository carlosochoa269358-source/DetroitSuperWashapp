import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_type_model.dart';

class VehicleTypeDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Incluye tipos globales (company_id IS NULL) y específicos de la empresa.
  Future<List<VehicleTypeModel>> getAll(String companyId) async {
    final data = await _client
        .from('vehicle_types')
        .select()
        .or('company_id.is.null,company_id.eq.$companyId')
        .order('sort_order');
    return (data as List).map((e) => VehicleTypeModel.fromJson(e)).toList();
  }

  Future<VehicleTypeModel> create({
    required String companyId,
    required String name,
    String? icon,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('vehicle_types')
        .insert({
          'company_id': companyId,
          'name': name,
          'icon': icon,
          'sort_order': sortOrder,
        })
        .select()
        .single();
    return VehicleTypeModel.fromJson(data);
  }

  Future<VehicleTypeModel> update({
    required String id,
    required String name,
    String? icon,
    required int sortOrder,
  }) async {
    final data = await _client
        .from('vehicle_types')
        .update({'name': name, 'icon': icon, 'sort_order': sortOrder})
        .eq('id', id)
        .select()
        .single();
    return VehicleTypeModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('vehicle_types').update({'is_active': isActive}).eq('id', id);
  }
}
