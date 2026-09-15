import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class CustomerDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  String _sanitize(String q) => q.replaceAll(RegExp(r'[,()]'), '').trim();

  Future<List<CustomerModel>> search({required String companyId, String? query}) async {
    if (query == null || query.trim().isEmpty) {
      // Sin filtro: se trae TODA la lista (para verla completa y para que
      // el Excel exporte a todos, no solo una muestra).
      final data = await _client.from('customers').select().eq('company_id', companyId).order('full_name');
      return (data as List).map((e) => CustomerModel.fromJson(e)).toList();
    }

    final q = _sanitize(query);
    if (q.isEmpty) return [];

    final results = <String, CustomerModel>{};

    final byNameOrPhone = await _client
        .from('customers')
        .select()
        .eq('company_id', companyId)
        .or('full_name.ilike.%$q%,phone.ilike.%$q%')
        .order('full_name')
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
          .inFilter('id', customerIdsFromPlate.toList());
      for (final row in byPlate as List) {
        final c = CustomerModel.fromJson(row);
        results[c.id] = c;
      }
    }

    return results.values.toList();
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
}
