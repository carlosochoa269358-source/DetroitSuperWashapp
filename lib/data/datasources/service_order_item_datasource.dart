import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_order_item_model.dart';

class ServiceOrderItemDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  static const _selectWithService = '*, services(name)';

  Future<List<ServiceOrderItemModel>> getByOrder(String serviceOrderId) async {
    final data = await _client
        .from('service_order_items')
        .select(_selectWithService)
        .eq('service_order_id', serviceOrderId)
        .order('created_at');
    return (data as List).map((e) => ServiceOrderItemModel.fromJson(e)).toList();
  }

  Future<ServiceOrderItemModel> create({
    required String serviceOrderId,
    required String serviceId,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
  }) async {
    final finalPrice = basePrice - discountAmount;
    final commissionAmount = finalPrice * commissionPct / 100;

    final data = await _client
        .from('service_order_items')
        .insert({
          'service_order_id': serviceOrderId,
          'service_id': serviceId,
          'base_price': basePrice,
          'discount_amount': discountAmount,
          'final_price': finalPrice,
          'commission_pct': commissionPct,
          'commission_amount': commissionAmount,
        })
        .select(_selectWithService)
        .single();
    return ServiceOrderItemModel.fromJson(data);
  }

  Future<void> delete(String itemId) async {
    await _client.from('service_order_items').delete().eq('id', itemId);
  }

  /// Cambia el precio a cobrar de un servicio ya agregado (ej. se negoció
  /// un descuento con el cliente). [basePrice]/[commissionPct] son los del
  /// ítem tal cual están, solo cambia [newFinalPrice].
  Future<ServiceOrderItemModel> updatePrice({
    required String itemId,
    required double basePrice,
    required double commissionPct,
    required double newFinalPrice,
  }) async {
    final discountAmount = basePrice - newFinalPrice;
    final commissionAmount = newFinalPrice * commissionPct / 100;
    final data = await _client
        .from('service_order_items')
        .update({
          'discount_amount': discountAmount,
          'final_price': newFinalPrice,
          'commission_amount': commissionAmount,
        })
        .eq('id', itemId)
        .select(_selectWithService)
        .single();
    return ServiceOrderItemModel.fromJson(data);
  }
}
