import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'service_picker_field.dart';

class SeleccionarServicioPage extends HookConsumerWidget {
  final String customerId;
  final String vehicleId;
  final String? vehicleTypeId;

  const SeleccionarServicioPage({
    super.key,
    required this.customerId,
    required this.vehicleId,
    required this.vehicleTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = useState<ServiceSelection?>(null);
    final selectedEmployeeId = useState<String?>(null);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    final employeesAsync = ref.watch(employeesProvider);

    Future<void> registrar() async {
      errorMessage.value = null;
      final user = ref.read(authProvider).value;
      final register = ref.read(openCashRegisterTodayProvider).value;

      if (selection.value == null) {
        errorMessage.value = 'Selecciona un servicio y un precio válido.';
        return;
      }
      if (selectedEmployeeId.value == null) {
        errorMessage.value = 'Selecciona el trabajador asignado.';
        return;
      }
      if (user == null || register == null) {
        errorMessage.value = 'No hay un turno abierto.';
        return;
      }

      isSaving.value = true;
      try {
        final result = await ref.read(serviceOrderRepositoryProvider).createOrderWithFirstService(
              companyId: user.companyId,
              cashRegisterId: register.id,
              customerId: customerId,
              vehicleId: vehicleId,
              createdBy: user.id,
              employeeId: selectedEmployeeId.value!,
              serviceId: selection.value!.service.id,
              basePrice: selection.value!.basePrice,
              discountAmount: selection.value!.discountAmount,
              commissionPct: selection.value!.service.commissionPct,
            );
        isSaving.value = false;
        result.fold(
          (failure) => errorMessage.value = failure.message,
          (_) {
            ref.invalidate(serviceOrdersByStatusProvider('new'));
            if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } catch (e) {
        isSaving.value = false;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    }

    return Scaffold(
      appBar: const DetroitAppBar(title: 'Seleccionar servicio'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ServicePickerField(
              vehicleTypeId: vehicleTypeId,
              onChanged: (value) => selection.value = value,
            ),
            if (selection.value != null) ...[
              const SizedBox(height: 16),
              employeesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error'),
                data: (employees) => DropdownButtonFormField<String>(
                  initialValue: selectedEmployeeId.value,
                  decoration: const InputDecoration(labelText: 'Trabajador asignado'),
                  dropdownColor: AppColors.surface2,
                  items: employees
                      .where((e) => e.isActive)
                      .map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName)))
                      .toList(),
                  onChanged: (value) => selectedEmployeeId.value = value,
                ),
              ),
              const SizedBox(height: 24),
              DetroitCard(
                accentColor: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total a pagar', style: AppTextStyles.heading4),
                    Text(
                      CurrencyFormatter.format(selection.value!.finalPrice),
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              DetroitButton(
                text: 'REGISTRAR SERVICIO',
                isLoading: isSaving.value,
                onPressed: registrar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
