import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/service_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

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
    final selectedServiceId = useState<String?>(null);
    final priceController = useTextEditingController();
    final selectedEmployeeId = useState<String?>(null);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    final servicesAsync = ref.watch(servicesProvider);
    final employeesAsync = ref.watch(employeesProvider);

    final vehicleTypeId = this.vehicleTypeId;
    final availableServices = (servicesAsync.value ?? [])
        .where((s) => s.isActive && vehicleTypeId != null && s.pricesByVehicleType.containsKey(vehicleTypeId))
        .toList();

    final serviceMatches = availableServices.where((s) => s.id == selectedServiceId.value);
    final ServiceEntity? selectedService = serviceMatches.isEmpty ? null : serviceMatches.first;
    final suggestedPrice =
        selectedService != null && vehicleTypeId != null ? selectedService.priceFor(vehicleTypeId) ?? 0.0 : 0.0;

    Future<void> registrar() async {
      errorMessage.value = null;
      final user = ref.read(authProvider).value;
      final register = ref.read(openCashRegisterTodayProvider).value;

      if (selectedService == null) {
        errorMessage.value = 'Selecciona un servicio.';
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

      final finalPrice = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (finalPrice == null || finalPrice <= 0) {
        errorMessage.value = 'Ingresa un precio válido.';
        return;
      }
      final discount = suggestedPrice - finalPrice;

      isSaving.value = true;
      try {
        final result = await ref.read(serviceOrderRepositoryProvider).create(
              companyId: user.companyId,
              cashRegisterId: register.id,
              customerId: customerId,
              vehicleId: vehicleId,
              serviceId: selectedService.id,
              createdBy: user.id,
              basePrice: suggestedPrice,
              discountAmount: discount,
              commissionPct: selectedService.commissionPct,
              employeeId: selectedEmployeeId.value!,
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
            if (vehicleTypeId == null)
              Text(
                'Este vehículo no tiene un tipo asignado, así que no se pueden sugerir servicios.',
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
              )
            else
              servicesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error'),
                data: (_) => availableServices.isEmpty
                    ? Text(
                        'No hay servicios con precio configurado para este tipo de vehículo. Ve a Configuración → Servicios.',
                        style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: selectedServiceId.value,
                        decoration: const InputDecoration(labelText: 'Servicio'),
                        dropdownColor: AppColors.surface2,
                        items: availableServices
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text('${s.name} — ${CurrencyFormatter.format(s.priceFor(vehicleTypeId) ?? 0)}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          selectedServiceId.value = value;
                          final match = availableServices.where((s) => s.id == value);
                          if (match.isNotEmpty) {
                            priceController.text = (match.first.priceFor(vehicleTypeId) ?? 0).toStringAsFixed(0);
                          }
                        },
                      ),
              ),
            if (selectedService != null) ...[
              const SizedBox(height: 16),
              DetroitTextField(
                controller: priceController,
                label: 'Precio a cobrar (editable)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Text(
                'Precio sugerido: ${CurrencyFormatter.format(suggestedPrice)}',
                style: AppTextStyles.caption,
              ),
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
                      priceController.text.isEmpty
                          ? CurrencyFormatter.format(suggestedPrice)
                          : CurrencyFormatter.format(
                              double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
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
