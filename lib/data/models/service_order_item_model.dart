import '../../domain/entities/service_order_item_entity.dart';

class ServiceOrderItemModel extends ServiceOrderItemEntity {
  ServiceOrderItemModel({
    required super.id,
    required super.serviceOrderId,
    required super.serviceId,
    required super.basePrice,
    required super.discountAmount,
    required super.finalPrice,
    required super.commissionPct,
    required super.commissionAmount,
    super.serviceName,
  });

  factory ServiceOrderItemModel.fromJson(Map<String, dynamic> json) {
    final service = json['services'] as Map<String, dynamic>?;
    return ServiceOrderItemModel(
      id: json['id'] as String,
      serviceOrderId: json['service_order_id'] as String,
      serviceId: json['service_id'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num).toDouble(),
      commissionPct: (json['commission_pct'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      serviceName: service?['name'] as String?,
    );
  }
}
