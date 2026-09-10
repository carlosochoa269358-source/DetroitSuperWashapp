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
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

/// Cuerpo de la pestaña "Caja". No trae su propio Scaffold/AppBar — lo provee
/// DashboardPage.
class CajaTab extends ConsumerWidget {
  const CajaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerAsync = ref.watch(openCashRegisterTodayProvider);

    return registerAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (register) {
        if (register == null) {
          return const Center(child: Text('No hay un turno abierto.'));
        }
        return Padding(
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
