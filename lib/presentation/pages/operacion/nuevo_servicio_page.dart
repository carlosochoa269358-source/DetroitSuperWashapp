import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cash_register_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/service_order_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class NuevoServicioPage extends HookConsumerWidget {
  const NuevoServicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateController = useTextEditingController();
    final lookupPlate = useState<String?>(null);

    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final brandController = useTextEditingController();
    final modelController = useTextEditingController();
    final colorController = useTextEditingController();
    final newVehicleTypeId = useState<String?>(null);

    final selectedServiceId = useState<String?>(null);
    final discountController = useTextEditingController(text: '0');
    final selectedEmployeeId = useState<String?>(null);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 350), () {
        final plate = plateController.text.trim().toUpperCase().replaceAll(' ', '');
        lookupPlate.value = plate.length >= 5 ? plate : null;
      });
      return timer.cancel;
    }, [plateController.text]);

    final vehicleAsync = lookupPlate.value == null
        ? const AsyncValue<dynamic>.data(null)
        : ref.watch(vehicleByPlateProvider(lookupPlate.value!));
    final foundVehicle = vehicleAsync.value;

    final customerAsync = foundVehicle != null
        ? ref.watch(customerByIdProvider(foundVehicle.customerId))
        : const AsyncValue<dynamic>.data(null);
    final foundCustomer = customerAsync.value;

    final vehicleTypeId = foundVehicle?.vehicleTypeId ?? newVehicleTypeId.value;

    final servicesAsync = ref.watch(servicesProvider);
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);
    final employeesAsync = ref.watch(employeesProvider);

    final availableServices = (servicesAsync.value ?? [])
        .where((s) => s.isActive && vehicleTypeId != null && s.pricesByVehicleType.containsKey(vehicleTypeId))
        .toList();

    final serviceMatches = availableServices.where((s) => s.id == selectedServiceId.value);
    final selectedService = serviceMatches.isEmpty ? null : serviceMatches.first;
    final servicePrice = selectedService != null && vehicleTypeId != null
        ? selectedService.priceFor(vehicleTypeId) ?? 0.0
        : 0.0;
    final discount = double.tryParse(discountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final total = (servicePrice - discount).clamp(0, double.infinity);

    Future<void> registrar() async {
      errorMessage.value = null;
      final user = ref.read(authProvider).value;
      final register = ref.read(openCashRegisterTodayProvider).value;
      if (user == null || register == null) {
        errorMessage.value = 'No hay un turno abierto.';
        return;
      }
      if (lookupPlate.value == null) {
        errorMessage.value = 'Ingresa una placa válida.';
        return;
      }
      if (selectedServiceId.value == null) {
        errorMessage.value = 'Selecciona un servicio.';
        return;
      }
      if (selectedEmployeeId.value == null) {
        errorMessage.value = 'Selecciona el trabajador asignado.';
        return;
      }

      String? customerId = foundCustomer?.id;
      String? vehicleId = foundVehicle?.id;

      isSaving.value = true;

      if (customerId == null) {
        if (nameController.text.trim().isEmpty) {
          errorMessage.value = 'Ingresa el nombre del cliente.';
          isSaving.value = false;
          return;
        }
        final phoneError = Validators.validateRequired(phoneController.text) ??
            Validators.validatePhone(phoneController.text);
        if (phoneError != null) {
          errorMessage.value = phoneError;
          isSaving.value = false;
          return;
        }
        if (newVehicleTypeId.value == null) {
          errorMessage.value = 'Selecciona el tipo de vehículo.';
          isSaving.value = false;
          return;
        }

        final customerResult = await ref.read(customerRepositoryProvider).create(
              companyId: user.companyId,
              fullName: nameController.text.trim(),
              phone: phoneController.text.trim(),
            );
        final customerFold = customerResult.fold((f) => null, (c) => c);
        if (customerFold == null) {
          errorMessage.value = 'No se pudo crear el cliente.';
          isSaving.value = false;
          return;
        }
        customerId = customerFold.id;

        final vehicleResult = await ref.read(vehicleRepositoryProvider).create(
              companyId: user.companyId,
              customerId: customerId,
              vehicleTypeId: newVehicleTypeId.value,
              plate: lookupPlate.value!,
              brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
              model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
              color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
            );
        final vehicleFold = vehicleResult.fold((f) => null, (v) => v);
        if (vehicleFold == null) {
          errorMessage.value = 'No se pudo crear el vehículo.';
          isSaving.value = false;
          return;
        }
        vehicleId = vehicleFold.id;
      }

      final result = await ref.read(serviceOrderRepositoryProvider).create(
            companyId: user.companyId,
            cashRegisterId: register.id,
            customerId: customerId,
            vehicleId: vehicleId!,
            serviceId: selectedServiceId.value!,
            createdBy: user.id,
            basePrice: servicePrice,
            discountAmount: discount,
            commissionPct: selectedService!.commissionPct,
            employeeId: selectedEmployeeId.value!,
          );

      isSaving.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          ref.invalidate(serviceOrdersByStatusProvider('new'));
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      appBar: const DetroitAppBar(title: 'Registrar servicio'),
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
            DetroitTextField(
              controller: plateController,
              label: 'Placa',
              hint: 'ABC123',
            ),
            const SizedBox(height: 16),
            if (vehicleAsync.isLoading) const LoadingWidget(),
            if (foundVehicle != null) ...[
              DetroitCard(
                accentColor: AppColors.success,
                child: customerAsync.isLoading
                    ? const LoadingWidget()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliente encontrado', style: AppTextStyles.caption),
                          Text(foundCustomer?.fullName ?? '—', style: AppTextStyles.heading4),
                          Text(foundCustomer?.phone ?? '', style: AppTextStyles.body2),
                          const Divider(),
                          Text(
                            [foundVehicle.brand, foundVehicle.model, foundVehicle.color]
                                .where((e) => e != null && (e as String).isNotEmpty)
                                .join(' · '),
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
              ),
            ] else if (lookupPlate.value != null) ...[
              Text('Vehículo nuevo', style: AppTextStyles.heading4),
              const SizedBox(height: 8),
              DetroitTextField(controller: nameController, label: 'Nombre del cliente'),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: phoneController,
                label: 'Celular (obligatorio)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              vehicleTypesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error'),
                data: (types) => DropdownButtonFormField<String>(
                  initialValue: newVehicleTypeId.value,
                  decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
                  dropdownColor: AppColors.surface2,
                  items: types
                      .where((t) => t.isActive)
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                      .toList(),
                  onChanged: (value) {
                    newVehicleTypeId.value = value;
                    selectedServiceId.value = null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              DetroitTextField(controller: brandController, label: 'Marca (opcional)'),
              const SizedBox(height: 16),
              DetroitTextField(controller: modelController, label: 'Modelo (opcional)'),
              const SizedBox(height: 16),
              DetroitTextField(controller: colorController, label: 'Color (opcional)'),
            ],
            const SizedBox(height: 16),
            if (vehicleTypeId != null) ...[
              servicesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error'),
                data: (_) => DropdownButtonFormField<String>(
                  initialValue: selectedServiceId.value,
                  decoration: const InputDecoration(labelText: 'Servicio'),
                  dropdownColor: AppColors.surface2,
                  items: availableServices
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} — ${CurrencyFormatter.format(s.priceFor(vehicleTypeId) ?? 0)}'),
                          ))
                      .toList(),
                  onChanged: (value) => selectedServiceId.value = value,
                ),
              ),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: discountController,
                label: 'Descuento (opcional)',
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 16),
              DetroitCard(
                accentColor: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total a pagar', style: AppTextStyles.heading4),
                    Text(
                      CurrencyFormatter.format(total.toDouble()),
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            DetroitButton(
              text: 'REGISTRAR SERVICIO',
              isLoading: isSaving.value,
              onPressed: registrar,
            ),
          ],
        ),
      ),
    );
  }
}
