class AppConstants {
  AppConstants._();
  static const String appName = 'Detroit Súper Wash';
  static const String companyDocument = '1020456810';
  static const String timezone = 'America/Bogota';
  static const int maxPhotosPerOrder = 5;
  static const double defaultCommissionPct = 40.0;
  static const String orderPrefix = 'DSW';
  
  // Payment methods
  static const String pmEfectivo = 'efectivo';
  static const String pmTransferencia = 'transferencia';
  static const String pmNequi = 'nequi';
  static const String pmDaviplata = 'daviplata';
  static const String pmTarjetaDebito = 'tarjeta_debito';
  static const String pmTarjetaCredito = 'tarjeta_credito';
  static const String pmPse = 'pse';
  
  // Order statuses  
  static const String statusNew = 'new';
  static const String statusInProgress = 'in_progress';
  static const String statusFinished = 'finished';
  static const String statusPaid = 'paid';
  static const String statusReceivable = 'receivable';
  static const String statusCancelled = 'cancelled';
  
  // User roles
  static const String roleAdminGeneral = 'admin_general';
  static const String roleAdminPunto = 'admin_punto';
  static const String roleOperador = 'operador';
}
