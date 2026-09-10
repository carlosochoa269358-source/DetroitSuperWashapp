import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class ServiceDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  static const _selectWithPrices = '*, service_prices(vehicle_type_id, price)';

  Future<List<ServiceModel>> getAll(String companyId) async {
    final data = await _client
        .from('services')
        .select(_selectWithPrices)
        .eq('company_id', companyId)
        .order('name');
    return (data as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<void> _replacePrices(String serviceId, Map<String, double> pricesByVehicleType) async {
    await _client.from('service_prices').delete().eq('service_id', serviceId);
    if (pricesByVehicleType.isEmpty) return;
    await _client.from('service_prices').insert([
      for (final entry in pricesByVehicleType.entries)
        {'service_id': serviceId, 'vehicle_type_id': entry.key, 'price': entry.value},
    ]);
  }

  Future<ServiceModel> create({
    required String companyId,
    String? categoryId,
    required String name,
    String? description,
    int? estimatedDurationMin,
    required double commissionPct,
    required Map<String, double> pricesByVehicleType,
  }) async {
    final inserted = await _client
        .from('services')
        .insert({
          'company_id': companyId,
          'category_id': categoryId,
          'name': name,
          'description': description,
          'estimated_duration_min': estimatedDurationMin,
          'commission_pct': commissionPct,
        })
        .select()
        .single();

    final serviceId = inserted['id'] as String;
    await _replacePrices(serviceId, pricesByVehicleType);

    final data = await _client
        .from('services')
        .select(_selectWithPrices)
        .eq('id', serviceId)
        .single();
    return ServiceModel.fromJson(data);
  }

  Future<ServiceModel> update({
    required String id,
    String? categoryId,
    required String name,
    String? description,
    int? estimatedDurationMin,
    required double commissionPct,
    required Map<String, double> pricesByVehicleType,
  }) async {
    await _client
        .from('services')
        .update({
          'category_id': categoryId,
          'name': name,
          'description': description,
          'estimated_duration_min': estimatedDurationMin,
          'commission_pct': commissionPct,
        })
        .eq('id', id);

    await _replacePrices(id, pricesByVehicleType);

    final data = await _client
        .from('services')
        .select(_selectWithPrices)
        .eq('id', id)
        .single();
    return ServiceModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('services').update({'is_active': isActive}).eq('id', id);
  }
}
