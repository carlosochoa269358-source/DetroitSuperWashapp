import '../../domain/entities/cash_register_entity.dart';

class CashRegisterModel extends CashRegisterEntity {
  CashRegisterModel({
    required super.id,
    required super.companyId,
    required super.openedBy,
    super.closedBy,
    required super.openingDate,
    required super.openingAmount,
    super.closingAmountExpected,
    super.closingAmountCounted,
    super.closingDifference,
    super.differenceReason,
    required super.status,
    required super.openedAt,
    super.closedAt,
    super.openedByName,
    super.closedByName,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) {
    final openedByUser = json['opened_by_user'] as Map<String, dynamic>?;
    final closedByUser = json['closed_by_user'] as Map<String, dynamic>?;
    return CashRegisterModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      openedBy: json['opened_by'] as String,
      closedBy: json['closed_by'] as String?,
      openingDate: DateTime.parse(json['opening_date'] as String),
      openingAmount: (json['opening_amount'] as num).toDouble(),
      closingAmountExpected: (json['closing_amount_expected'] as num?)?.toDouble(),
      closingAmountCounted: (json['closing_amount_counted'] as num?)?.toDouble(),
      closingDifference: (json['closing_difference'] as num?)?.toDouble(),
      differenceReason: json['difference_reason'] as String?,
      status: json['status'] as String,
      openedAt: DateTime.parse(json['opened_at'] as String),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      openedByName: openedByUser?['full_name'] as String?,
      closedByName: closedByUser?['full_name'] as String?,
    );
  }
}
