import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/expense_category_total_entity.dart';
import '../../domain/entities/payment_method_total_entity.dart';
import '../../domain/entities/profit_report_entity.dart';

class ReportsDataSource {
  final SupabaseClient _client = Supabase.instance.client;
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  /// [fromDate]/[toDate] son fechas calendario en Bogotá, ambas inclusive.
  Future<ProfitReportEntity> getProfitReport({
    required String companyId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // 00:00 Bogotá = 05:00 UTC. El límite superior es exclusivo (inicio del
    // día siguiente a toDate) para incluir el día completo.
    final fromInstant = DateTime.utc(fromDate.year, fromDate.month, fromDate.day, 5);
    final toInstantExclusive = DateTime.utc(toDate.year, toDate.month, toDate.day, 5).add(const Duration(days: 1));
    final fromIso = fromInstant.toIso8601String();
    final toIso = toInstantExclusive.toIso8601String();
    final fromDateStr = _dateFormat.format(fromDate);
    final toDateStr = _dateFormat.format(toDate);

    // Ventas: órdenes cuyo pago se completó dentro del rango (no cuenta lo
    // fiado que sigue sin pagar, sin importar cuándo se hizo el servicio).
    final orders = await _client
        .from('service_orders')
        .select('final_price')
        .eq('company_id', companyId)
        .eq('status', 'paid')
        .gte('paid_at', fromIso)
        .lt('paid_at', toIso);
    double totalSales = 0;
    for (final row in orders as List) {
      totalSales += (row['final_price'] as num).toDouble();
    }

    // Desglose por método de pago: pagos directos + abonos de fiados.
    final directPayments = await _client
        .from('payments')
        .select('payment_method, amount')
        .eq('is_reversed', false)
        .gte('paid_at', fromIso)
        .lt('paid_at', toIso);
    final abonos = await _client
        .from('accounts_receivable_payments')
        .select('payment_method, amount')
        .gte('paid_at', fromIso)
        .lt('paid_at', toIso);
    final salesTotals = <String, double>{};
    final salesCounts = <String, int>{};
    for (final row in [...(directPayments as List), ...(abonos as List)]) {
      final method = row['payment_method'] as String;
      final amount = (row['amount'] as num).toDouble();
      salesTotals[method] = (salesTotals[method] ?? 0) + amount;
      salesCounts[method] = (salesCounts[method] ?? 0) + 1;
    }
    final salesByMethod = salesTotals.entries
        .map((e) => PaymentMethodTotal(method: e.key, count: salesCounts[e.key]!, total: e.value))
        .toList();

    // Comisiones efectivamente pagadas (no reversadas) en el rango.
    final settlements = await _client
        .from('employee_settlements')
        .select('commission_paid')
        .eq('company_id', companyId)
        .eq('is_reversed', false)
        .gte('settled_at', fromIso)
        .lt('settled_at', toIso);
    double totalCommissions = 0;
    for (final row in settlements as List) {
      totalCommissions += (row['commission_paid'] as num).toDouble();
    }

    // Gastos activos del rango, con su categoría.
    final expenses = await _client
        .from('expenses')
        .select('amount, expense_categories(name)')
        .eq('company_id', companyId)
        .eq('status', 'active')
        .gte('expense_date', fromDateStr)
        .lte('expense_date', toDateStr);
    double totalExpenses = 0;
    final expenseTotals = <String, double>{};
    for (final row in expenses as List) {
      final amount = (row['amount'] as num).toDouble();
      totalExpenses += amount;
      final category = row['expense_categories'] as Map<String, dynamic>?;
      final name = category?['name'] as String? ?? 'Sin categoría';
      expenseTotals[name] = (expenseTotals[name] ?? 0) + amount;
    }
    final expensesByCategory = expenseTotals.entries
        .map((e) => ExpenseCategoryTotal(categoryName: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return ProfitReportEntity(
      totalSales: totalSales,
      totalCommissions: totalCommissions,
      totalExpenses: totalExpenses,
      netProfit: totalSales - totalCommissions - totalExpenses,
      salesByMethod: salesByMethod,
      expensesByCategory: expensesByCategory,
    );
  }
}
