import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class ServiceDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ServiceModel>> getAll(String companyId) async {
    final data = await _client
        .from('services')
        .select()
        .eq('company_id', companyId)
        .order('name');
    return (data as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> create({
    required String companyId,
    String? categoryId,
    required String name,
    String? description,
    required double basePrice,
    int? estimatedDurationMin,
    required double commissionPct,
    required List<String> applicableVehicleTypeIds,
  }) async {
    final data = await _client
        .from('services')
        .insert({
          'company_id': companyId,
          'category_id': categoryId,
          'name': name,
          'description': description,
          'base_price': basePrice,
          'estimated_duration_min': estimatedDurationMin,
          'commission_pct': commissionPct,
          'applicable_vehicle_types': applicableVehicleTypeIds,
        })
        .select()
        .single();
    return ServiceModel.fromJson(data);
  }

  Future<ServiceModel> update({
    required String id,
    String? categoryId,
    required String name,
    String? description,
    required double basePrice,
    int? estimatedDurationMin,
    required double commissionPct,
    required List<String> applicableVehicleTypeIds,
  }) async {
    final data = await _client
        .from('services')
        .update({
          'category_id': categoryId,
          'name': name,
          'description': description,
          'base_price': basePrice,
          'estimated_duration_min': estimatedDurationMin,
          'commission_pct': commissionPct,
          'applicable_vehicle_types': applicableVehicleTypeIds,
        })
        .eq('id', id)
        .select()
        .single();
    return ServiceModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('services').update({'is_active': isActive}).eq('id', id);
  }
}
