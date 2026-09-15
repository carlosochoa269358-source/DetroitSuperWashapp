import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

class VehicleDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<VehicleModel>> getByCustomer(String customerId) async {
    final data = await _client
        .from('vehicles')
        .select()
        .eq('customer_id', customerId)
        .eq('is_active', true)
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
        .eq('is_active', true)
        .maybeSingle();
    if (data == null) return null;
    return VehicleModel.fromJson(data);
  }

  /// Igual que getByPlate, pero SIN el filtro de is_active — para detectar,
  /// antes de crear una placa nueva, que ya existe (activa o "eliminada")
  /// y evitar el error crudo de restricción única (la placa es única esté
  /// activa o no, así que desactivarla no libera el valor).
  Future<VehicleModel?> getByPlateAny({required String companyId, required String plate}) async {
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
        .eq('is_active', true)
        .ilike('plate', '%$q%')
        .order('plate')
        .limit(50);
    return (data as List).map((e) => VehicleModel.fromJson(e)).toList();
  }

  /// Todos los vehículos activos de la empresa (para exportar clientes con
  /// sus placas asociadas).
  Future<List<VehicleModel>> getAllByCompany(String companyId) async {
    final data = await _client
        .from('vehicles')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('plate');
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

  /// Cambia el dueño de una placa (el carro fue vendido/traspasado). El
  /// historial de servicios sigue intacto porque es la misma fila de
  /// vehículo, solo cambia a quién pertenece.
  Future<void> transferToCustomer({required String vehicleId, required String newCustomerId}) async {
    await _client.from('vehicles').update({'customer_id': newCustomerId}).eq('id', vehicleId);
  }

  /// Borra la placa de verdad (para corregir errores de digitación). Si el
  /// vehículo ya tiene órdenes de servicio asociadas, Postgres rechaza el
  /// borrado (23503, restricción de llave foránea) y el repositorio debe
  /// resolverlo desactivándola en su lugar.
  ///
  /// Se pide `.select()` de vuelta a propósito: si RLS bloquea el borrado
  /// (falta la política, o el usuario no tiene permiso), Postgres NO lanza
  /// error, simplemente borra 0 filas — sin este chequeo la app reportaría
  /// éxito sin haber borrado nada.
  Future<bool> delete(String id) async {
    final data = await _client.from('vehicles').delete().eq('id', id).select();
    return (data as List).isNotEmpty;
  }
}
