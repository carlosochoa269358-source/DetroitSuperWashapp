import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/accounts_receivable_model.dart';

class AccountsReceivableDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AccountsReceivableModel>> getOpen(String companyId) async {
    final data = await _client
        .from('accounts_receivable')
        .select('*, customers(full_name, phone), service_orders(order_number, vehicles(plate))')
        .eq('company_id', companyId)
        .inFilter('status', ['open', 'partial'])
        .order('created_at');
    return (data as List).map((e) => AccountsReceivableModel.fromJson(e)).toList();
  }

  Future<void> registerAbono({
    required String accountsReceivableId,
    required String cashRegisterId,
    required String registeredBy,
    required double amount,
    required String paymentMethod,
  }) async {
    await _client.from('accounts_receivable_payments').insert({
      'accounts_receivable_id': accountsReceivableId,
      'cash_register_id': cashRegisterId,
      'registered_by': registeredBy,
      'amount': amount,
      'payment_method': paymentMethod,
    });
  }
}
