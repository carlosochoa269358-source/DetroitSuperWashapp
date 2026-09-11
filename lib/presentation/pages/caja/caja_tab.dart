import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/employee_pending_summary_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/employee_settlement_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../operacion/pago_modal.dart' show paymentMethodLabels;

/// Cuerpo de la pestaña "Caja". No trae su propio Scaffold/AppBar — lo provee
/// DashboardPage.
class CajaTab extends ConsumerWidget {
  const CajaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerAsync = ref.watch(openCashRegisterTodayProvider);
    final user = ref.watch(authProvider).value;

    return registerAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (register) {
        if (register == null) {
          return const Center(child: Text('No hay un turno abierto.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetroitCard(
                accentColor: AppColors.success,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turno abierto', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    Text('Abierto: ${DateFormatter.formatDateTime(register.openedAt)}', style: AppTextStyles.body2),
                    Text(
                      'Caja inicial: ${CurrencyFormatter.format(register.openingAmount)}',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _OrdenesResumenCard(),
              const SizedBox(height: 16),
              _ServiciosResumenCard(cashRegisterId: register.id),
              const SizedBox(height: 16),
              _MetodosPagoCard(cashRegisterId: register.id),
              if (user?.isAdminGeneral ?? false) ...[
                const SizedBox(height: 16),
                _LiquidacionCard(cashRegisterId: register.id),
              ],
              const SizedBox(height: 24),
              DetroitButton(
                text: 'CERRAR TURNO',
                type: DetroitButtonType.danger,
                onPressed: () => _showCerrarTurnoSheet(context, ref, register.id, register.openingAmount),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumenRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isNegative;

  const _ResumenRow({required this.label, required this.value, this.isTotal = false, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    final color = isNegative ? AppColors.error : (isTotal ? AppColors.primary : null);
    final style = isTotal
        ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700, color: color)
        : AppTextStyles.body2.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Suma de Nuevas/Finalizadas/Pagadas del turno actual y su gran total.
class _OrdenesResumenCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nuevasAsync = ref.watch(serviceOrdersByStatusProvider('new'));
    final finalizadasAsync = ref.watch(serviceOrdersByStatusProvider('finished'));
    final pagadasAsync = ref.watch(serviceOrdersByStatusProvider('paid'));

    double sumOf(AsyncValue<List<ServiceOrderEntity>> async) {
      final list = async.value;
      if (list == null) return 0;
      return list.fold<double>(0, (sum, order) => sum + order.finalPrice);
    }

    final isLoading = nuevasAsync.isLoading || finalizadasAsync.isLoading || pagadasAsync.isLoading;
    final nuevasTotal = sumOf(nuevasAsync);
    final finalizadasTotal = sumOf(finalizadasAsync);
    final pagadasTotal = sumOf(pagadasAsync);
    final granTotal = nuevasTotal + finalizadasTotal + pagadasTotal;

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Órdenes del turno', style: AppTextStyles.heading4),
          const SizedBox(height: 8),
          if (isLoading)
            const LoadingWidget()
          else ...[
            _ResumenRow(label: 'Nuevas', value: CurrencyFormatter.format(nuevasTotal)),
            _ResumenRow(label: 'Finalizadas', value: CurrencyFormatter.format(finalizadasTotal)),
            _ResumenRow(label: 'Pagadas', value: CurrencyFormatter.format(pagadasTotal)),
            const Divider(color: AppColors.divider),
            _ResumenRow(label: 'Total', value: CurrencyFormatter.format(granTotal), isTotal: true),
          ],
        ],
      ),
    );
  }
}

class _ServiciosResumenCard extends ConsumerWidget {
  final String cashRegisterId;

  const _ServiciosResumenCard({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(servicesSummaryProvider(cashRegisterId));

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Servicios', style: AppTextStyles.heading4),
          const SizedBox(height: 8),
          summaryAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (summary) => _ResumenRow(
              label: '${summary.count} servicio(s)',
              value: CurrencyFormatter.format(summary.total),
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetodosPagoCard extends ConsumerWidget {
  final String cashRegisterId;

  const _MetodosPagoCard({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(paymentMethodTotalsProvider(cashRegisterId));

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Métodos de pago', style: AppTextStyles.heading4),
          const SizedBox(height: 8),
          totalsAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (totals) {
              final byMethod = {for (final t in totals) t.method: t};
              double grandTotal = 0;
              final rows = <Widget>[];
              for (final entry in paymentMethodLabels.entries) {
                final totalForMethod = byMethod[entry.key];
                if (totalForMethod == null) continue;
                grandTotal += totalForMethod.total;
                rows.add(_ResumenRow(
                  label: '${entry.value} (${totalForMethod.count})',
                  value: CurrencyFormatter.format(totalForMethod.total),
                  isNegative: totalForMethod.total < 0,
                ));
              }
              if (rows.isEmpty) {
                return Text('Todavía no se ha cobrado nada en este turno.', style: AppTextStyles.body2);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rows,
                  const Divider(color: AppColors.divider),
                  _ResumenRow(
                    label: 'Total',
                    value: CurrencyFormatter.format(grandTotal),
                    isTotal: true,
                    isNegative: grandTotal < 0,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Comisión pendiente por trabajador (órdenes ya pagadas, sin liquidar) con
/// un botón para liquidar todo de una vez, descontándolo del método de pago
/// elegido en el turno actual.
class _LiquidacionCard extends ConsumerWidget {
  final String cashRegisterId;

  const _LiquidacionCard({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(employeePendingSummaryProvider);

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liquidación de trabajadores', style: AppTextStyles.heading4),
          Text(
            'Incluye comisión de servicios ya cobrados de cualquier turno, no solo el de hoy. Los fiados no cuentan aquí.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 8),
          pendingAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (pending) {
              if (pending.isEmpty) {
                return Text('No hay comisiones pendientes por liquidar.', style: AppTextStyles.body2);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final employee in pending) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(employee.employeeName, style: AppTextStyles.body1),
                                Text(
                                  '${employee.pendingCount} servicio(s) — ${CurrencyFormatter.format(employee.pendingTotal)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showLiquidarSheet(context, ref, cashRegisterId, employee),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                            ),
                            child: const Text('Liquidar'),
                          ),
                        ],
                      ),
                    ),
                    if (employee != pending.last) const Divider(color: AppColors.divider),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showLiquidarSheet(
  BuildContext context,
  WidgetRef ref,
  String cashRegisterId,
  EmployeePendingSummaryEntity employee,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => _LiquidarSheet(cashRegisterId: cashRegisterId, employee: employee),
  );
}

class _LiquidarSheet extends HookConsumerWidget {
  final String cashRegisterId;
  final EmployeePendingSummaryEntity employee;

  const _LiquidarSheet({required this.cashRegisterId, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = useState<String>('efectivo');
    final isSaving = useState(false);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Liquidar a ${employee.employeeName}', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text('${employee.pendingCount} servicio(s) pendientes', style: AppTextStyles.body2),
          const SizedBox(height: 16),
          Text(
            'Total a pagar: ${CurrencyFormatter.format(employee.pendingTotal)}',
            style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('¿En qué método se le está pagando?', style: AppTextStyles.body2),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: paymentMethodLabels.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: selectedMethod.value == entry.key,
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => selectedMethod.value = entry.key,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto se descuenta del total de "${paymentMethodLabels[selectedMethod.value]}" en la caja de este turno — puede quedar en negativo si se liquida más de lo que ha entrado en ese método.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 24),
          DetroitButton(
            text: 'CONFIRMAR LIQUIDACIÓN',
            isLoading: isSaving.value,
            onPressed: () async {
              final user = ref.read(authProvider).value;
              if (user == null) return;

              isSaving.value = true;
              final result = await ref.read(employeeSettlementRepositoryProvider).liquidateAllPending(
                    companyId: user.companyId,
                    employeeId: employee.employeeId,
                    cashRegisterId: cashRegisterId,
                    settledBy: user.id,
                    commissionPct: employee.commissionPct,
                    paymentMethod: selectedMethod.value,
                  );
              isSaving.value = false;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                (_) {
                  ref.invalidate(employeePendingSummaryProvider);
                  ref.invalidate(paymentMethodTotalsProvider(cashRegisterId));
                  ref.invalidate(cashPaymentsTotalProvider(cashRegisterId));
                  if (context.mounted) Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showCerrarTurnoSheet(BuildContext context, WidgetRef ref, String registerId, double openingAmount) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => _CerrarTurnoSheet(registerId: registerId, openingAmount: openingAmount),
  );
}

class _CerrarTurnoSheet extends HookConsumerWidget {
  final String registerId;
  final double openingAmount;

  const _CerrarTurnoSheet({required this.registerId, required this.openingAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashPaymentsAsync = ref.watch(cashPaymentsTotalProvider(registerId));
    final expected = openingAmount + (cashPaymentsAsync.value ?? 0);
    final countedController = useTextEditingController();
    final reasonController = useTextEditingController();
    final showReasonField = useState(false);
    final isSaving = useState(false);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cerrar turno', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          cashPaymentsAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error'),
            data: (_) => Text(
              'Efectivo esperado: ${CurrencyFormatter.format(expected)}',
              style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          DetroitTextField(
            controller: countedController,
            label: 'Efectivo contado',
            keyboardType: TextInputType.number,
          ),
          if (showReasonField.value) ...[
            const SizedBox(height: 16),
            DetroitTextField(
              controller: reasonController,
              label: 'Motivo de la diferencia',
              validator: Validators.validateRequired,
            ),
          ],
          const SizedBox(height: 24),
          DetroitButton(
            text: 'CONFIRMAR CIERRE',
            isLoading: isSaving.value,
            onPressed: () async {
              final user = ref.read(authProvider).value;
              if (user == null) return;
              final counted = double.tryParse(countedController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

              if (counted != expected && reasonController.text.trim().isEmpty) {
                showReasonField.value = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hay una diferencia — indica el motivo para continuar')),
                );
                return;
              }

              isSaving.value = true;
              final result = await ref.read(cashRegisterRepositoryProvider).close(
                    id: registerId,
                    closedBy: user.id,
                    expectedAmount: expected,
                    countedAmount: counted,
                    differenceReason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                  );
              isSaving.value = false;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                (_) {
                  ref.invalidate(anyOpenCashRegisterProvider);
                  ref.invalidate(openCashRegisterTodayProvider);
                  ref.invalidate(closedCashRegistersProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.turno);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
