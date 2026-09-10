import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

/// Primer paso de "Registrar servicio": resuelve placa → cliente → vehículo.
/// Solo crea cliente/vehículo; el servicio se elige en la pantalla siguiente.
class ClienteVehiculoPage extends HookConsumerWidget {
  const ClienteVehiculoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateController = useTextEditingController();
    final lookupPlate = useState<String?>(null);
    final plateError = useState<String?>(null);

    // 'search' = buscar cliente ya existente por nombre/celular; 'new' = crear cliente nuevo.
    final mode = useState<String>('search');
    final searchController = useTextEditingController();
    final searchQuery = useState<String?>(null);
    final selectedCustomer = useState<CustomerEntity?>(null);

    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final brandController = useTextEditingController();
    final modelController = useTextEditingController();
    final colorController = useTextEditingController();
    final selectedVehicleTypeId = useState<String?>(null);

    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 400), () {
        final raw = plateController.text.trim().toUpperCase().replaceAll(' ', '');
        if (raw.isEmpty) {
          lookupPlate.value = null;
          plateError.value = null;
          return;
        }
        final error = Validators.validatePlate(raw);
        plateError.value = error;
        lookupPlate.value = error == null ? raw : null;
      });
      return timer.cancel;
    }, [plateController.text]);

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 350), () {
        final q = searchController.text.trim();
        searchQuery.value = q.isEmpty ? null : q;
      });
      return timer.cancel;
    }, [searchController.text]);

    final vehicleAsync = lookupPlate.value == null
        ? const AsyncValue<dynamic>.data(null)
        : ref.watch(vehicleByPlateProvider(lookupPlate.value!));
    final foundVehicle = vehicleAsync.value;

    final foundCustomerAsync = foundVehicle != null
        ? ref.watch(customerByIdProvider(foundVehicle.customerId))
        : const AsyncValue<dynamic>.data(null);
    final foundCustomer = foundCustomerAsync.value;

    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    Future<void> continuarConVehiculoExistente() async {
      context.push(
        AppRoutes.seleccionarServicio,
        extra: {
          'customerId': foundCustomer.id as String,
          'vehicleId': foundVehicle.id as String,
          'vehicleTypeId': foundVehicle.vehicleTypeId as String?,
        },
      );
    }

    Future<void> crearVehiculoYContinuar() async {
      errorMessage.value = null;
      final user = ref.read(authProvider).value;
      if (user == null) return;

      if (selectedVehicleTypeId.value == null) {
        errorMessage.value = 'Selecciona el tipo de vehículo.';
        return;
      }

      isSaving.value = true;
      try {
        String customerId;
        if (selectedCustomer.value != null) {
          customerId = selectedCustomer.value!.id;
        } else {
          final nameError = Validators.validateRequired(nameController.text);
          if (nameError != null) throw Exception('Falta el nombre del cliente.');
          final phoneError = Validators.validateRequired(phoneController.text) ??
              Validators.validatePhone(phoneController.text);
          if (phoneError != null) throw Exception(phoneError);

          final customerResult = await ref.read(customerRepositoryProvider).create(
                companyId: user.companyId,
                fullName: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );
          customerId = customerResult.fold(
            (failure) => throw Exception('No se pudo crear el cliente: ${failure.message}'),
            (c) => c.id,
          );
        }

        final vehicleResult = await ref.read(vehicleRepositoryProvider).create(
              companyId: user.companyId,
              customerId: customerId,
              vehicleTypeId: selectedVehicleTypeId.value,
              plate: lookupPlate.value!,
              brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
              model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
              color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
            );
        final vehicle = vehicleResult.fold(
          (failure) => throw Exception('No se pudo crear el vehículo: ${failure.message}'),
          (v) => v,
        );

        isSaving.value = false;
        if (context.mounted) {
          context.push(
            AppRoutes.seleccionarServicio,
            extra: {
              'customerId': customerId,
              'vehicleId': vehicle.id,
              'vehicleTypeId': selectedVehicleTypeId.value,
            },
          );
        }
      } catch (e) {
        isSaving.value = false;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
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
              hint: 'ABC123 (carro) o XXX29G (moto)',
              uppercase: true,
            ),
            if (plateError.value != null) ...[
              const SizedBox(height: 4),
              Text(plateError.value!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            if (vehicleAsync.isLoading) const LoadingWidget(),
            if (foundVehicle != null) ...[
              DetroitCard(
                accentColor: AppColors.success,
                child: foundCustomerAsync.isLoading
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
              const SizedBox(height: 24),
              DetroitButton(text: 'CONTINUAR', onPressed: continuarConVehiculoExistente),
            ] else if (lookupPlate.value != null) ...[
              Text('Placa nueva', style: AppTextStyles.heading4),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Buscar cliente existente'),
                    selected: mode.value == 'search',
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    onSelected: (_) => mode.value = 'search',
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Cliente nuevo'),
                    selected: mode.value == 'new',
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    onSelected: (_) {
                      mode.value = 'new';
                      selectedCustomer.value = null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (mode.value == 'search' && selectedCustomer.value == null) ...[
                DetroitTextField(
                  controller: searchController,
                  label: 'Buscar por nombre o celular',
                ),
                const SizedBox(height: 8),
                if (searchQuery.value != null) _CustomerSearchResults(
                  query: searchQuery.value!,
                  onSelected: (c) => selectedCustomer.value = c,
                ),
              ],
              if (mode.value == 'search' && selectedCustomer.value != null) ...[
                DetroitCard(
                  accentColor: AppColors.primary,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedCustomer.value!.fullName, style: AppTextStyles.heading4),
                            Text(selectedCustomer.value!.phone, style: AppTextStyles.body2),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () => selectedCustomer.value = null,
                      ),
                    ],
                  ),
                ),
              ],
              if (mode.value == 'new') ...[
                DetroitTextField(controller: nameController, label: 'Nombre del cliente', uppercase: true),
                const SizedBox(height: 16),
                DetroitTextField(
                  controller: phoneController,
                  label: 'Celular (obligatorio)',
                  keyboardType: TextInputType.phone,
                ),
              ],
              if ((mode.value == 'search' && selectedCustomer.value != null) || mode.value == 'new') ...[
                const SizedBox(height: 24),
                Text('Datos del vehículo', style: AppTextStyles.heading4),
                const SizedBox(height: 12),
                vehicleTypesAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (types) => DropdownButtonFormField<String>(
                    initialValue: selectedVehicleTypeId.value,
                    decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
                    dropdownColor: AppColors.surface2,
                    items: types
                        .where((t) => t.isActive)
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (value) => selectedVehicleTypeId.value = value,
                  ),
                ),
                const SizedBox(height: 16),
                DetroitTextField(controller: brandController, label: 'Marca (opcional)', uppercase: true),
                const SizedBox(height: 16),
                DetroitTextField(controller: modelController, label: 'Modelo (opcional)', uppercase: true),
                const SizedBox(height: 16),
                DetroitTextField(controller: colorController, label: 'Color (opcional)', uppercase: true),
                const SizedBox(height: 32),
                DetroitButton(
                  text: 'CONTINUAR',
                  isLoading: isSaving.value,
                  onPressed: crearVehiculoYContinuar,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerSearchResults extends ConsumerWidget {
  final String query;
  final ValueChanged<CustomerEntity> onSelected;

  const _CustomerSearchResults({required this.query, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(customerSearchProvider(query));

    return resultsAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      data: (customers) {
        if (customers.isEmpty) {
          return Text('No se encontraron clientes con "$query"', style: AppTextStyles.body2);
        }
        return Column(
          children: customers
              .map((c) => InkWell(
                    onTap: () => onSelected(c),
                    child: DetroitCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.fullName, style: AppTextStyles.heading4),
                          Text(c.phone, style: AppTextStyles.body2),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
