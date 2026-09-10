class CashRegisterEntity {
  final String id;
  final String companyId;
  final String openedBy;
  final String? closedBy;
  final DateTime openingDate;
  final double openingAmount;
  final double? closingAmountExpected;
  final double? closingAmountCounted;
  final double? closingDifference;
  final String? differenceReason;
  final String status;
  final DateTime openedAt;
  final DateTime? closedAt;

  CashRegisterEntity({
    required this.id,
    required this.companyId,
    required this.openedBy,
    this.closedBy,
    required this.openingDate,
    required this.openingAmount,
    this.closingAmountExpected,
    this.closingAmountCounted,
    this.closingDifference,
    this.differenceReason,
    required this.status,
    required this.openedAt,
    this.closedAt,
  });

  bool get isOpen => status == 'open';
}
