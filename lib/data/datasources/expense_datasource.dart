import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/expense_category_entity.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ExpenseCategoryEntity>> getCategories(String companyId) async {
    final data = await _client
        .from('expense_categories')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('sort_order')
        .order('name');
    return (data as List)
        .map((e) => ExpenseCategoryEntity(
              id: e['id'] as String,
              parentId: e['parent_id'] as String?,
              name: e['name'] as String,
              expenseType: e['expense_type'] as String,
              isActive: e['is_active'] as bool,
            ))
        .toList();
  }

  Future<List<ExpenseEntity>> getByRegister(String cashRegisterId) async {
    final data = await _client
        .from('expenses')
        .select('*, expense_categories(name)')
        .eq('cash_register_id', cashRegisterId)
        .eq('status', 'active')
        .order('created_at', ascending: false);
    return (data as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  ExpenseEntity _fromJson(Map<String, dynamic> json) {
    final category = json['expense_categories'] as Map<String, dynamic>?;
    return ExpenseEntity(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      categoryId: json['category_id'] as String,
      cashRegisterId: json['cash_register_id'] as String?,
      registeredBy: json['registered_by'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      provider: json['provider'] as String?,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      categoryName: category?['name'] as String?,
    );
  }

  Future<void> create({
    required String companyId,
    required String categoryId,
    required String cashRegisterId,
    required String registeredBy,
    required String description,
    required double amount,
    required String paymentMethod,
    String? provider,
    String? notes,
  }) async {
    await _client.from('expenses').insert({
      'company_id': companyId,
      'category_id': categoryId,
      'cash_register_id': cashRegisterId,
      'registered_by': registeredBy,
      'description': description,
      'amount': amount,
      'payment_method': paymentMethod,
      'provider': provider,
      'expense_date': DateTime.now().toUtc().toIso8601String().substring(0, 10),
      'notes': notes,
    });
  }

  /// Anula el gasto en vez de borrarlo (nunca se elimina información
  /// financiera, se anula con motivo — sección 20 del documento original).
  Future<void> cancel({
    required String expenseId,
    required String cancelledBy,
    required String reason,
  }) async {
    await _client.from('expenses').update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toUtc().toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancel_reason': reason,
    }).eq('id', expenseId);
  }
}
