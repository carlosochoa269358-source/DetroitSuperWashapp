import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class CustomerDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  String _sanitize(String q) => q.replaceAll(RegExp(r'[,()]'), '').trim();

  static final RegExp _onlyDigits = RegExp(r'^[0-9]+$');

  /// Alfabético, pero deja al final los clientes cuyo "nombre" en realidad
  /// es un número de celular (quedaron así al migrar de X2 sin nombre).
  List<CustomerModel> _sortNamesFirst(List<CustomerModel> customers) {
    final sorted = [...customers];
    sorted.sort((a, b) {
      final aIsPhone = _onlyDigits.hasMatch(a.fullName.trim());
      final bIsPhone = _onlyDigits.hasMatch(b.fullName.trim());
      if (aIsPhone != bIsPhone) return aIsPhone ? 1 : -1;
      return a.fullName.toUpperCase().compareTo(b.fullName.toUpperCase());
    });
    return sorted;
  }

  Future<List<CustomerModel>> search({required String companyId, String? query}) async {
    if (query == null || query.trim().isEmpty) {
      // Sin filtro: se trae TODA la lista (para verla completa y para que
      // el Excel exporte a todos, no solo una muestra).
      final data = await _client.from('customers').select().eq('company_id', companyId).eq('is_active', true);
      final customers = (data as List).map((e) => CustomerModel.fromJson(e)).toList();
      return _sortNamesFirst(customers);
    }

    final q = _sanitize(query);
    if (q.isEmpty) return [];

    final results = <String, CustomerModel>{};

    final byNameOrPhone = await _client
        .from('customers')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .or('full_name.ilike.%$q%,phone.ilike.%$q%')
        .limit(50);
    for (final row in byNameOrPhone as List) {
      final c = CustomerModel.fromJson(row);
      results[c.id] = c;
    }

    final vehicleMatches = await _client
        .from('vehicles')
        .select('customer_id')
        .eq('company_id', companyId)
        .ilike('plate', '%${q.toUpperCase()}%');
    final customerIdsFromPlate =
        (vehicleMatches as List).map((e) => e['customer_id'] as String).toSet();

    if (customerIdsFromPlate.isNotEmpty) {
      final byPlate = await _client
          .from('customers')
          .select()
          .eq('company_id', companyId)
          .eq('is_active', true)
          .inFilter('id', customerIdsFromPlate.toList());
      for (final row in byPlate as List) {
        final c = CustomerModel.fromJson(row);
        results[c.id] = c;
      }
    }

    return _sortNamesFirst(results.values.toList());
  }

  /// Busca un cliente por celular EXACTO (no parcial) — para detectar, antes
  /// de crear "cliente nuevo", que ese número ya pertenece a alguien y
  /// evitar el error de restricción única + ofrecer usar ese cliente.
  Future<CustomerModel?> getByPhone({required String companyId, required String phone}) async {
    final data = await _client
        .from('customers')
        .select()
        .eq('company_id', companyId)
        .eq('phone', phone)
        .maybeSingle();
    if (data == null) return null;
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> getById(String id) async {
    final data = await _client.from('customers').select().eq('id', id).single();
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> create({
    required String companyId,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  }) async {
    final data = await _client
        .from('customers')
        .insert({
          'company_id': companyId,
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'notes': notes,
        })
        .select()
        .single();
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> update({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  }) async {
    final data = await _client
        .from('customers')
        .update({
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'notes': notes,
        })
        .eq('id', id)
        .select()
        .single();
    return CustomerModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('customers').update({'is_active': isActive}).eq('id', id);
  }

  /// Borra el cliente de verdad. Si ya tiene vehículos asociados, Postgres
  /// rechaza el borrado (23503, restricción de llave foránea) y el
  /// repositorio debe resolverlo desactivándolo en su lugar.
  ///
  /// Se pide `.select()` de vuelta a propósito: si RLS bloquea el borrado,
  /// Postgres NO lanza error, simplemente borra 0 filas.
  Future<bool> delete(String id) async {
    final data = await _client.from('customers').delete().eq('id', id).select();
    return (data as List).isNotEmpty;
  }
}
