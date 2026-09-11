class TurnoSettlementEntity {
  final String id;
  final String employeeName;
  final String paymentMethod;
  final double commissionPaid;

  const TurnoSettlementEntity({
    required this.id,
    required this.employeeName,
    required this.paymentMethod,
    required this.commissionPaid,
  });
}
