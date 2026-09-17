import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/accounts_receivable_entity.dart';
import '../../../domain/entities/service_order_entity.dart';
import '../../providers/accounts_receivable_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/employee_settlement_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_text_field.dart';

const paymentMethodLabels = {
  'efectivo': 'Efectivo',
  'transferencia': 'Transferencia',
  'nequi': 'Nequi',
  'daviplata': 'Daviplata',
  'tarjeta_debito': 'Tarjeta débito',
  'tarjeta_credito': 'Tarjeta crédito',
  'pse': 'PSE',
};

void showPagoModal(BuildContext context, WidgetRef ref, ServiceOrderEntity order) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PagoSheet(order: order),
  );
}

class _PagoSheet extends HookConsumerWidget {
  final ServiceOrderEntity order;

  const _PagoSheet({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountController = useTextEditingController(text: order.finalPrice.toStringAsFixed(0));
    final selectedMethod = useState<String>('efectivo');
    final isSaving = useState(false);

    Future<void> settle({required bool isFiar}) async {
      final user = ref.read(authProvider).value;
      final register = ref.read(anyOpenCashRegisterProvider).value;
      if (user == null || register == null) return;

      final amountPaid = isFiar
          ? 0.0
          : double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      isSaving.value = true;
      final result = await ref.read(serviceOrderRepositoryProvider).settlePayment(
            orderId: order.id,
            companyId: user.companyId,
            customerId: order.customerId,
            cashRegisterId: register.id,
            registeredBy: user.id,
            finalPrice: order.finalPrice,
            amountPaid: amountPaid,
            paymentMethod: amountPaid > 0 ? selectedMethod.value : null,
          );
      isSaving.value = false;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          ref.invalidate(serviceOrdersByStatusProvider('finished'));
          ref.invalidate(serviceOrdersByStatusProvider('paid'));
          ref.invalidate(serviceOrdersByStatusProvider('receivable'));
          ref.invalidate(openAccountsReceivableProvider);
          // Sin esto, Caja (Servicios/Métodos de pago/Liquidación) se queda
          // con los números de antes del cobro hasta que algo más la
          // refresque — de ahí que pareciera que "toca cerrar y volver a
          // abrir la app" para que se vea al día.
          ref.invalidate(servicesSummaryProvider(register.id));
          ref.invalidate(paymentMethodTotalsProvider(register.id));
          ref.invalidate(cashPaymentsTotalProvider(register.id));
          ref.invalidate(employeePendingSummaryProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

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
          Text('Cobrar servicio', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text('${order.vehiclePlate ?? ''} · ${order.customerName ?? ''}', style: AppTextStyles.body2),
          const SizedBox(height: 16),
          Text(
            'Total: ${CurrencyFormatter.format(order.finalPrice)}',
            style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          DetroitTextField(
            controller: amountController,
            label: 'Monto recibido',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
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
            text: 'REGISTRAR PAGO',
            isLoading: isSaving.value,
            onPressed: () => settle(isFiar: false),
          ),
          const SizedBox(height: 12),
          DetroitButton(
            text: 'FIAR / PAGAR DESPUÉS',
            type: DetroitButtonType.secondary,
            isLoading: isSaving.value,
            onPressed: () => settle(isFiar: true),
          ),
        ],
      ),
    );
  }
}

void showAbonoModal(BuildContext context, WidgetRef ref, AccountsReceivableEntity receivable) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _AbonoSheet(receivable: receivable),
  );
}

class _AbonoSheet extends HookConsumerWidget {
  final AccountsReceivableEntity receivable;

  const _AbonoSheet({required this.receivable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountController = useTextEditingController(text: receivable.pendingAmount.toStringAsFixed(0));
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
          Text('Registrar abono', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text('${receivable.vehiclePlate ?? ''} · ${receivable.customerName ?? ''}', style: AppTextStyles.body2),
          const SizedBox(height: 16),
          Text(
            'Saldo pendiente: ${CurrencyFormatter.format(receivable.pendingAmount)}',
            style: AppTextStyles.heading4.copyWith(color: AppColors.statusReceivable),
          ),
          const SizedBox(height: 16),
          DetroitTextField(
            controller: amountController,
            label: 'Monto del abono',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
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
            text: 'REGISTRAR ABONO',
            isLoading: isSaving.value,
            onPressed: () async {
              final user = ref.read(authProvider).value;
              final register = ref.read(anyOpenCashRegisterProvider).value;
              if (user == null || register == null) return;
              final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              if (amount <= 0) return;

              isSaving.value = true;
              final result = await ref.read(accountsReceivableRepositoryProvider).registerAbono(
                    accountsReceivableId: receivable.id,
                    cashRegisterId: register.id,
                    registeredBy: user.id,
                    amount: amount,
                    paymentMethod: selectedMethod.value,
                  );
              isSaving.value = false;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                (_) {
                  ref.invalidate(openAccountsReceivableProvider);
                  ref.invalidate(serviceOrdersByStatusProvider('paid'));
                  ref.invalidate(servicesSummaryProvider(register.id));
                  ref.invalidate(paymentMethodTotalsProvider(register.id));
                  ref.invalidate(cashPaymentsTotalProvider(register.id));
                  ref.invalidate(employeePendingSummaryProvider);
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
