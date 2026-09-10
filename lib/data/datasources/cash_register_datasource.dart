import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/date_formatter.dart';
import '../models/cash_register_model.dart';

class CashRegisterDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// El turno abierto más antiguo (si hay varios sin cerrar, se cierra primero el más viejo).
  Future<CashRegisterModel?> getAnyOpen(String companyId) async {
    final data = await _client
        .from('cash_registers')
        .select()
        .eq('company_id', companyId)
        .eq('status', 'open')
        .order('opening_date')
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return CashRegisterModel.fromJson(data);
  }

  Future<double> cashPaymentsTotal(String cashRegisterId) async {
    final payments = await _client
        .from('payments')
        .select('amount')
        .eq('cash_register_id', cashRegisterId)
        .eq('payment_method', 'efectivo')
        .eq('is_reversed', false);
    double total = 0;
    for (final row in payments as List) {
      total += (row['amount'] as num).toDouble();
    }
    return total;
  }

  Future<CashRegisterModel> open({
    required String companyId,
    required String userId,
    required double openingAmount,
    Map<String, dynamic>? denominations,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateFormatter.todayBogota());
    final data = await _client
        .from('cash_registers')
        .insert({
          'company_id': companyId,
          'opened_by': userId,
          'opening_date': today,
          'opening_amount': openingAmount,
          'opening_denominations': denominations,
          'status': 'open',
        })
        .select()
        .single();
    return CashRegisterModel.fromJson(data);
  }

  Future<void> close({
    required String id,
    required String closedBy,
    required double expectedAmount,
    required double countedAmount,
    String? differenceReason,
  }) async {
    await _client
        .from('cash_registers')
        .update({
          'closed_by': closedBy,
          'closing_amount_expected': expectedAmount,
          'closing_amount_counted': countedAmount,
          'closing_difference': countedAmount - expectedAmount,
          'difference_reason': differenceReason,
          'status': 'closed',
          'closed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }
}
