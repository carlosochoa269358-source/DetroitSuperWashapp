import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_model.dart';

class EmployeeDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<EmployeeModel>> getAll(String companyId) async {
    final data = await _client
        .from('employees')
        .select()
        .eq('company_id', companyId)
        .order('full_name');
    return (data as List).map((e) => EmployeeModel.fromJson(e)).toList();
  }

  Future<EmployeeModel> create({
    required String companyId,
    required String fullName,
    String? phone,
    required double commissionPct,
  }) async {
    final data = await _client
        .from('employees')
        .insert({
          'company_id': companyId,
          'full_name': fullName,
          'phone': phone,
          'commission_pct': commissionPct,
        })
        .select()
        .single();
    return EmployeeModel.fromJson(data);
  }

  Future<EmployeeModel> update({
    required String id,
    required String fullName,
    String? phone,
    required double commissionPct,
  }) async {
    final data = await _client
        .from('employees')
        .update({
          'full_name': fullName,
          'phone': phone,
          'commission_pct': commissionPct,
        })
        .eq('id', id)
        .select()
        .single();
    return EmployeeModel.fromJson(data);
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('employees').update({'is_active': isActive}).eq('id', id);
  }
}
