import 'expense_category_total_entity.dart';
import 'payment_method_total_entity.dart';

class ProfitReportEntity {
  final double totalSales;
  final double totalCommissions;
  final double totalExpenses;
  final double netProfit;
  final List<PaymentMethodTotal> salesByMethod;
  final List<ExpenseCategoryTotal> expensesByCategory;

  const ProfitReportEntity({
    required this.totalSales,
    required this.totalCommissions,
    required this.totalExpenses,
    required this.netProfit,
    required this.salesByMethod,
    required this.expensesByCategory,
  });
}
