import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

class VehicleDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<VehicleModel>> getByCustomer(String customerId) async {
    final data = await _client
        .from('vehicles')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => VehicleModel.fromJson(e)).toList();
  }

  Future<VehicleModel?> getByPlate({required String companyId, required String plate}) async {
    final cleanPlate = plate.toUpperCase().replaceAll(' ', '');
    final data = await _client
        .from('vehicles')
        .select()
        .eq('company_id', companyId)
        .eq('plate', cleanPlate)
        .maybeSingle();
    if (data == null) return null;
    return VehicleModel.fromJson(data);
  }

  /// Búsqueda parcial: cualquier vehículo cuya placa CONTENGA lo escrito
  /// (no tiene que ser exacta ni empezar por ahí), para "Buscar por placa".
  Future<List<VehicleModel>> searchByPlate({required String companyId, required String query}) async {
    final q = query.toUpperCase().replaceAll(' ', '');
    if (q.isEmpty) return [];
    final data = await _client
        .from('vehicles')
        .select()
        .eq('company_id', companyId)
        .ilike('plate', '%$q%')
        .order('plate')
        .limit(50);
    return (data as List).map((e) => VehicleModel.fromJson(e)).toList();
  }

  /// Todos los vehículos de la empresa (para exportar clientes con sus
  /// placas asociadas).
  Future<List<VehicleModel>> getAllByCompany(String companyId) async {
    final data = await _client.from('vehicles').select().eq('company_id', companyId).order('plate');
    return (data as List).map((e) => VehicleModel.fromJson(e)).toList();
  }

  Future<VehicleModel> create({
    required String companyId,
    required String customerId,
    String? vehicleTypeId,
    required String plate,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? notes,
  }) async {
    final data = await _client
        .from('vehicles')
        .insert({
          'company_id': companyId,
          'customer_id': customerId,
          'vehicle_type_id': vehicleTypeId,
          'plate': plate,
          'brand': brand,
          'model': model,
          'color': color,
          'year': year,
          'notes': notes,
        })
        .select()
        .single();
    return VehicleModel.fromJson(data);
  }

  Future<VehicleModel> update({
    required String id,
    String? vehicleTypeId,
    required String plate,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? notes,
  }) async {
    final data = await _client
        .from('vehicles')
        .update({
          'vehicle_type_id': vehicleTypeId,
          'plate': plate,
          'brand': brand,
          'model': model,
          'color': color,
          'year': year,
          'notes': notes,
        })
        .eq('id', id)
        .select()
        .single();
    return VehicleModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('vehicles').update({'is_active': isActive}).eq('id', id);
  }
}
