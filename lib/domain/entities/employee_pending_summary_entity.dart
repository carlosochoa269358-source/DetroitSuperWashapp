class EmployeePendingSummaryEntity {
  final String employeeId;
  final String employeeName;
  final double commissionPct;
  final int pendingCount;
  final double pendingTotal;

  const EmployeePendingSummaryEntity({
    required this.employeeId,
    required this.employeeName,
    required this.commissionPct,
    required this.pendingCount,
    required this.pendingTotal,
  });
}
