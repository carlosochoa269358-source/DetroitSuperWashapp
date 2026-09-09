import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Brand
  static const Color primary = Color(0xFFF5A623);      // Detroit Yellow
  static const Color primaryDark = Color(0xFFD4880A);   // Pressed/hover
  static const Color primaryLight = Color(0xFFF7C05A);  // Light variant
  
  // Background
  static const Color background = Color(0xFF0D0D0D);    // Main background
  static const Color surface = Color(0xFF1A1A1A);       // Cards
  static const Color surface2 = Color(0xFF242424);      // Inputs
  static const Color surface3 = Color(0xFF2E2E2E);      // Dividers area
  
  // Text
  static const Color onBackground = Color(0xFFFFFFFF);  // White text
  static const Color onSurface = Color(0xFFFFFFFF);     // White on cards
  static const Color textMuted = Color(0xFF9E9E9E);     // Secondary text
  static const Color textDisabled = Color(0xFF616161);  // Disabled
  
  // Semantic
  static const Color success = Color(0xFF4CAF50);  // PAGADO
  static const Color warning = Color(0xFFFF9800);  // POR COBRAR
  static const Color error = Color(0xFFF44336);    // CANCELADO/Error
  static const Color info = Color(0xFF2196F3);     // Informativo
  
  // Status colors for service orders
  static const Color statusNew = Color(0xFFF5A623);       // Nuevo - amarillo Detroit
  static const Color statusInProgress = Color(0xFF2196F3); // En progreso - azul
  static const Color statusFinished = Color(0xFF9C27B0);   // Finalizado - morado
  static const Color statusPaid = Color(0xFF4CAF50);       // Pagado - verde
  static const Color statusReceivable = Color(0xFFFF9800); // Por cobrar - naranja
  static const Color statusCancelled = Color(0xFFF44336);  // Cancelado - rojo
  
  // Divider
  static const Color divider = Color(0xFF333333);
  
  // Overlay
  static const Color overlay = Color(0x80000000);
}
