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
import '../../../domain/entities/cash_register_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

const _billDenominations = [100000, 50000, 20000, 10000, 5000, 2000];
const _coinDenominations = [1000, 500, 200, 100, 50];

class TurnoPage extends ConsumerWidget {
  const TurnoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anyOpenAsync = ref.watch(anyOpenCashRegisterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: anyOpenAsync.when(
          loading: () => const LoadingWidget(),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
          ),
          data: (register) {
            if (register != null && !isTodayBogota(register.openingDate)) {
              return _CerrarTurnoAnteriorView(register: register);
            }
            return const _AbrirTurnoView();
          },
        ),
      ),
    );
  }
}

class _AbrirTurnoView extends HookConsumerWidget {
  const _AbrirTurnoView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useDenominations = useState(false);
    final amountController = useTextEditingController();
    final billCounts = useState<Map<int, int>>({});
    final coinCounts = useState<Map<int, int>>({});
    final isSaving = useState(false);

    int denominationsTotal() {
      var total = 0;
      billCounts.value.forEach((denom, count) => total += denom * count);
      coinCounts.value.forEach((denom, count) => total += denom * count);
      return total;
    }

    Future<void> abrirTurno() async {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      final amount = useDenominations.value
          ? denominationsTotal().toDouble()
          : double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      isSaving.value = true;
      final repo = ref.read(cashRegisterRepositoryProvider);
      final result = await repo.open(
        companyId: user.companyId,
        userId: user.id,
        openingAmount: amount,
        denominations: useDenominations.value
            ? {
                'bills': billCounts.value.map((k, v) => MapEntry(k.toString(), v)),
                'coins': coinCounts.value.map((k, v) => MapEntry(k.toString(), v)),
              }
            : null,
      );
      isSaving.value = false;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          ref.invalidate(anyOpenCashRegisterProvider);
          ref.invalidate(openCashRegisterTodayProvider);
          if (context.mounted) context.go(AppRoutes.dashboard);
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/images/logo_banner.jpg', width: 160),
          const SizedBox(height: 24),
          Text('Abrir turno', style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            DateFormatter.formatDate(DateFormatter.todayBogota()),
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Monto directo'),
                selected: !useDenominations.value,
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => useDenominations.value = false,
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Contar denominaciones'),
                selected: useDenominations.value,
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => useDenominations.value = true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!useDenominations.value)
            DetroitTextField(
              controller: amountController,
              label: 'Caja inicial',
              hint: '\$ 200.000',
              keyboardType: TextInputType.number,
            )
          else ...[
            Text('Billetes', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            ..._billDenominations.map((denom) => _DenominationRow(
                  label: CurrencyFormatter.format(denom.toDouble()),
                  onChanged: (count) {
                    final updated = Map<int, int>.from(billCounts.value);
                    updated[denom] = count;
                    billCounts.value = updated;
                  },
                )),
            const SizedBox(height: 16),
            Text('Monedas', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            ..._coinDenominations.map((denom) => _DenominationRow(
                  label: CurrencyFormatter.format(denom.toDouble()),
                  onChanged: (count) {
                    final updated = Map<int, int>.from(coinCounts.value);
                    updated[denom] = count;
                    coinCounts.value = updated;
                  },
                )),
            const SizedBox(height: 16),
            DetroitCard(
              accentColor: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.heading4),
                  Text(
                    CurrencyFormatter.format(denominationsTotal().toDouble()),
                    style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          DetroitButton(text: 'ABRIR TURNO', isLoading: isSaving.value, onPressed: abrirTurno),
        ],
      ),
    );
  }
}

class _DenominationRow extends HookWidget {
  final String label;
  final ValueChanged<int> onChanged;

  const _DenominationRow({required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body1)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(isDense: true),
              onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _CerrarTurnoAnteriorView extends HookConsumerWidget {
  final CashRegisterEntity register;

  const _CerrarTurnoAnteriorView({required this.register});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashPaymentsAsync = ref.watch(cashPaymentsTotalProvider(register.id));
    final expectedAsync = cashPaymentsAsync.whenData((cashPayments) => register.openingAmount + cashPayments);
    final countedController = useTextEditingController();
    final reasonController = useTextEditingController();
    final isSaving = useState(false);
    final showReasonField = useState(false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              'El turno anterior quedó abierto. Debes cerrarlo antes de continuar.',
              style: AppTextStyles.body2.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Text('Cerrar turno anterior', style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          expectedAsync.when(
            loading: () => const LoadingWidget(),
            error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
            data: (expected) => DetroitCard(
              accentColor: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Efectivo esperado', style: AppTextStyles.heading4),
                  Text(
                    CurrencyFormatter.format(expected),
                    style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
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
          const SizedBox(height: 32),
          DetroitButton(
            text: 'CERRAR TURNO',
            isLoading: isSaving.value,
            onPressed: () async {
              final user = ref.read(authProvider).value;
              if (user == null) return;
              final expected = expectedAsync.value ?? 0;
              final counted = double.tryParse(countedController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

              if (counted != expected && reasonController.text.trim().isEmpty) {
                showReasonField.value = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hay una diferencia — indica el motivo para continuar')),
                );
                return;
              }

              isSaving.value = true;
              final repo = ref.read(cashRegisterRepositoryProvider);
              final result = await repo.close(
                id: register.id,
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
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
