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
import '../../../domain/entities/expense_category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../../domain/entities/turno_settlement_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/employee_settlement_provider.dart';
import '../../providers/expense_provider.dart';
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
              if ((user?.isAdminGeneral ?? false) || (user?.isAdminPunto ?? false)) ...[
                const SizedBox(height: 16),
                _GastosCard(cashRegisterId: register.id),
              ],
              const SizedBox(height: 16),
              _TotalGeneralCard(cashRegisterId: register.id),
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
    final settledAsync = ref.watch(turnoSettlementsProvider(cashRegisterId));

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
                                  '${CurrencyFormatter.format(employee.pendingSalesTotal)} × ${employee.commissionPct.toStringAsFixed(0)}% '
                                  '= ${CurrencyFormatter.format(employee.pendingTotal)}',
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
          settledAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (settled) {
              if (settled.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider),
                  Text('Liquidado en este turno', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  for (final s in settled) _SettledRow(cashRegisterId: cashRegisterId, settlement: s),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettledRow extends ConsumerWidget {
  final String cashRegisterId;
  final TurnoSettlementEntity settlement;

  const _SettledRow({required this.cashRegisterId, required this.settlement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${settlement.employeeName} (${paymentMethodLabels[settlement.paymentMethod] ?? settlement.paymentMethod})',
              style: AppTextStyles.body2,
            ),
          ),
          Text(
            '-${CurrencyFormatter.format(settlement.commissionPaid)}',
            style: AppTextStyles.body2.copyWith(color: AppColors.error),
          ),
          IconButton(
            icon: const Icon(Icons.undo, color: AppColors.textMuted, size: 18),
            tooltip: 'Reversar liquidación',
            onPressed: () => _showReversarLiquidacionDialog(context, ref, cashRegisterId, settlement),
          ),
        ],
      ),
    );
  }
}

void _showReversarLiquidacionDialog(
  BuildContext context,
  WidgetRef ref,
  String cashRegisterId,
  TurnoSettlementEntity settlement,
) async {
  final reasonController = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Reversar liquidación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esto deja pendiente de nuevo la comisión de ${settlement.employeeName} '
            '(${CurrencyFormatter.format(settlement.commissionPaid)}) para poder liquidarla otra vez.',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: 16),
          DetroitTextField(
            controller: reasonController,
            label: 'Motivo de la reversión',
            validator: Validators.validateRequired,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            if (reasonController.text.trim().isEmpty) return;
            Navigator.pop(context, true);
          },
          child: const Text('REVERSAR', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final user = ref.read(authProvider).value;
  if (user == null) return;

  final result = await ref.read(employeeSettlementRepositoryProvider).reverseSettlement(
        settlementId: settlement.id,
        reversedBy: user.id,
        reason: reasonController.text.trim(),
      );
  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    (_) {
      ref.invalidate(employeePendingSummaryProvider);
      ref.invalidate(turnoSettlementsProvider(cashRegisterId));
      ref.invalidate(paymentMethodTotalsProvider(cashRegisterId));
      ref.invalidate(cashPaymentsTotalProvider(cashRegisterId));
    },
  );
}

/// Gastos activos del turno (insumos, arriendo, reparaciones, etc.), con
/// botón para registrar uno nuevo y anular los que se registren por error.
class _GastosCard extends ConsumerWidget {
  final String cashRegisterId;

  const _GastosCard({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesByRegisterProvider(cashRegisterId));
    final user = ref.watch(authProvider).value;

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gastos del turno', style: AppTextStyles.heading4),
              TextButton.icon(
                onPressed: () => _showAgregarGastoSheet(context, ref, cashRegisterId),
                icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
                label: const Text('Agregar gasto', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          expensesAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (expenses) {
              if (expenses.isEmpty) {
                return Text('No hay gastos registrados en este turno.', style: AppTextStyles.body2);
              }
              double total = 0;
              final rows = <Widget>[];
              for (final expense in expenses) {
                total += expense.amount;
                rows.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.description, style: AppTextStyles.body2),
                            Text(
                              '${expense.categoryName ?? '—'} · ${paymentMethodLabels[expense.paymentMethod] ?? expense.paymentMethod}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(CurrencyFormatter.format(expense.amount), style: AppTextStyles.body2),
                      if (user?.isAdminGeneral ?? false)
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                          tooltip: 'Anular gasto',
                          onPressed: () => _showAnularGastoDialog(context, ref, cashRegisterId, expense),
                        ),
                    ],
                  ),
                ));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rows,
                  const Divider(color: AppColors.divider),
                  _ResumenRow(label: 'Total', value: CurrencyFormatter.format(total), isTotal: true),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showAgregarGastoSheet(BuildContext context, WidgetRef ref, String cashRegisterId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => _AgregarGastoSheet(cashRegisterId: cashRegisterId),
  );
}

class _AgregarGastoSheet extends HookConsumerWidget {
  final String cashRegisterId;

  const _AgregarGastoSheet({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final providerController = useTextEditingController();
    final selectedCategoryId = useState<String?>(null);
    final selectedMethod = useState<String>('efectivo');
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    String categoryLabel(ExpenseCategoryEntity category, List<ExpenseCategoryEntity> all) {
      if (category.parentId == null) return category.name;
      final parent = all.where((c) => c.id == category.parentId);
      return parent.isEmpty ? category.name : '${parent.first.name} > ${category.name}';
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Agregar gasto', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            if (errorMessage.value != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(errorMessage.value!, style: const TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 16),
            ],
            categoriesAsync.when(
              loading: () => const LoadingWidget(),
              error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: selectedCategoryId.value,
                decoration: const InputDecoration(labelText: 'Categoría'),
                dropdownColor: AppColors.surface2,
                items: categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(categoryLabel(c, categories))))
                    .toList(),
                onChanged: (value) => selectedCategoryId.value = value,
              ),
            ),
            const SizedBox(height: 16),
            DetroitTextField(controller: descriptionController, label: 'Descripción'),
            const SizedBox(height: 16),
            DetroitTextField(
              controller: amountController,
              label: 'Monto',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DetroitTextField(controller: providerController, label: 'Proveedor (opcional)'),
            const SizedBox(height: 16),
            Text('Método de pago', style: AppTextStyles.body2),
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
            const SizedBox(height: 24),
            DetroitButton(
              text: 'REGISTRAR GASTO',
              isLoading: isSaving.value,
              onPressed: () async {
                errorMessage.value = null;
                final user = ref.read(authProvider).value;
                if (user == null) return;

                if (selectedCategoryId.value == null) {
                  errorMessage.value = 'Selecciona una categoría.';
                  return;
                }
                if (descriptionController.text.trim().isEmpty) {
                  errorMessage.value = 'Escribe una descripción.';
                  return;
                }
                final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                if (amount <= 0) {
                  errorMessage.value = 'El monto debe ser mayor a cero.';
                  return;
                }

                isSaving.value = true;
                final result = await ref.read(expenseRepositoryProvider).create(
                      companyId: user.companyId,
                      categoryId: selectedCategoryId.value!,
                      cashRegisterId: cashRegisterId,
                      registeredBy: user.id,
                      description: descriptionController.text.trim(),
                      amount: amount,
                      paymentMethod: selectedMethod.value,
                      provider: providerController.text.trim().isEmpty ? null : providerController.text.trim(),
                    );
                isSaving.value = false;
                result.fold(
                  (failure) => errorMessage.value = failure.message,
                  (_) {
                    ref.invalidate(expensesByRegisterProvider(cashRegisterId));
                    ref.invalidate(cashPaymentsTotalProvider(cashRegisterId));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showAnularGastoDialog(BuildContext context, WidgetRef ref, String cashRegisterId, ExpenseEntity expense) async {
  final reasonController = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Anular gasto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esto anula "${expense.description}" (${CurrencyFormatter.format(expense.amount)}). No se borra, queda registrado como anulado.',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: 16),
          DetroitTextField(
            controller: reasonController,
            label: 'Motivo de la anulación',
            validator: Validators.validateRequired,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            if (reasonController.text.trim().isEmpty) return;
            Navigator.pop(context, true);
          },
          child: const Text('ANULAR', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final user = ref.read(authProvider).value;
  if (user == null) return;

  final result = await ref.read(expenseRepositoryProvider).cancel(
        expenseId: expense.id,
        cancelledBy: user.id,
        reason: reasonController.text.trim(),
      );
  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    (_) {
      ref.invalidate(expensesByRegisterProvider(cashRegisterId));
      ref.invalidate(cashPaymentsTotalProvider(cashRegisterId));
    },
  );
}

/// Resumen final del turno: lo bruto por método, lo liquidado a trabajadores
/// (siempre en negativo, sin importar el método), y el neto por método.
class _TotalGeneralCard extends ConsumerWidget {
  final String cashRegisterId;

  const _TotalGeneralCard({required this.cashRegisterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(paymentMethodTotalsProvider(cashRegisterId));
    final settledAsync = ref.watch(turnoSettlementsProvider(cashRegisterId));
    final expensesAsync = ref.watch(expensesByRegisterProvider(cashRegisterId));

    return DetroitCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total general', style: AppTextStyles.heading4),
          const SizedBox(height: 8),
          if (totalsAsync.isLoading || settledAsync.isLoading || expensesAsync.isLoading)
            const LoadingWidget()
          else if (totalsAsync.hasError)
            Text('Error: ${totalsAsync.error}', style: const TextStyle(color: AppColors.error))
          else if (settledAsync.hasError)
            Text('Error: ${settledAsync.error}', style: const TextStyle(color: AppColors.error))
          else if (expensesAsync.hasError)
            Text('Error: ${expensesAsync.error}', style: const TextStyle(color: AppColors.error))
          else
            Builder(builder: (context) {
              final bruto = <String, double>{
                for (final t in totalsAsync.value!) t.method: t.total,
              };
              final liquidado = <String, double>{};
              for (final s in settledAsync.value!) {
                liquidado[s.paymentMethod] = (liquidado[s.paymentMethod] ?? 0) + s.commissionPaid;
              }
              final gastado = <String, double>{};
              for (final e in expensesAsync.value!) {
                gastado[e.paymentMethod] = (gastado[e.paymentMethod] ?? 0) + e.amount;
              }
              final methods = {...bruto.keys, ...liquidado.keys, ...gastado.keys}.toList()
                ..sort((a, b) => paymentMethodLabels.keys.toList().indexOf(a).compareTo(
                      paymentMethodLabels.keys.toList().indexOf(b),
                    ));

              final totalBruto = bruto.values.fold<double>(0, (sum, v) => sum + v);
              final totalTrabajadores = liquidado.values.fold<double>(0, (sum, v) => sum + v);
              final totalGastos = gastado.values.fold<double>(0, (sum, v) => sum + v);
              final totalGeneral = totalBruto - totalTrabajadores - totalGastos;

              if (methods.isEmpty) {
                return Text('Todavía no hay movimientos en este turno.', style: AppTextStyles.body2);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final method in methods)
                    _ResumenRow(
                      label: paymentMethodLabels[method] ?? method,
                      value: CurrencyFormatter.format(bruto[method] ?? 0),
                    ),
                  if (totalTrabajadores > 0)
                    _ResumenRow(
                      label: 'Trabajadores',
                      value: '-${CurrencyFormatter.format(totalTrabajadores)}',
                      isNegative: true,
                    ),
                  if (totalGastos > 0)
                    _ResumenRow(
                      label: 'Gastos',
                      value: '-${CurrencyFormatter.format(totalGastos)}',
                      isNegative: true,
                    ),
                  const Divider(color: AppColors.divider),
                  _ResumenRow(
                    label: 'Total general',
                    value: CurrencyFormatter.format(totalGeneral),
                    isTotal: true,
                    isNegative: totalGeneral < 0,
                  ),
                  const SizedBox(height: 12),
                  for (final method in methods)
                    _ResumenRow(
                      label: 'Total en ${paymentMethodLabels[method] ?? method}',
                      value: CurrencyFormatter.format(
                        (bruto[method] ?? 0) - (liquidado[method] ?? 0) - (gastado[method] ?? 0),
                      ),
                      isNegative: (bruto[method] ?? 0) - (liquidado[method] ?? 0) - (gastado[method] ?? 0) < 0,
                    ),
                ],
              );
            }),
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
            'Esto se descuenta del "Total general" de este turno en "${paymentMethodLabels[selectedMethod.value]}" — puede quedar en negativo si se liquida más de lo que ha entrado en ese método.',
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
                  ref.invalidate(turnoSettlementsProvider(cashRegisterId));
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
