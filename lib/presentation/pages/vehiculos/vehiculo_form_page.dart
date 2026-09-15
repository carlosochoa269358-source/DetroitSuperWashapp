import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/debounce_hook.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class VehiculoFormPage extends HookConsumerWidget {
  final String customerId;
  final VehicleEntity? vehicle;

  const VehiculoFormPage({super.key, required this.customerId, this.vehicle});

  bool get isEditing => vehicle != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final plateController = useTextEditingController(text: vehicle?.plate);
    final brandController = useTextEditingController(text: vehicle?.brand);
    final modelController = useTextEditingController(text: vehicle?.model);
    final colorController = useTextEditingController(text: vehicle?.color);
    final yearController = useTextEditingController(text: vehicle?.year?.toString());
    final notesController = useTextEditingController(text: vehicle?.notes);
    final selectedVehicleTypeId = useState<String?>(vehicle?.vehicleTypeId);
    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      isSaving.value = true;
      errorMessage.value = null;

      final repo = ref.read(vehicleRepositoryProvider);
      final plate = plateController.text.trim().toUpperCase().replaceAll(' ', '');
      final year = yearController.text.trim().isEmpty ? null : int.tryParse(yearController.text.trim());
      final vehicleTypeId = selectedVehicleTypeId.value;
      final brand = brandController.text.trim().isEmpty ? null : brandController.text.trim();
      final model = modelController.text.trim().isEmpty ? null : modelController.text.trim();
      final color = colorController.text.trim().isEmpty ? null : colorController.text.trim();
      final notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();

      if (isEditing) {
        final result = await repo.update(
          id: vehicle!.id,
          vehicleTypeId: vehicleTypeId,
          plate: plate,
          brand: brand,
          model: model,
          color: color,
          year: year,
          notes: notes,
        );
        isSaving.value = false;
        result.fold(
          (failure) => errorMessage.value = failure.message,
          (savedVehicle) {
            ref.invalidate(vehiclesByCustomerProvider(customerId));
            if (context.mounted) context.pop(savedVehicle);
          },
        );
        return;
      }

      // Creando placa nueva: revisa primero si ya existe (activa o no) —
      // es única en toda la empresa y desactivarla no libera el valor, así
      // que sin este chequeo saldría el error crudo de restricción única.
      final companyId = ref.read(authProvider).value!.companyId;
      final existingResult = await repo.getByPlateAny(companyId: companyId, plate: plate);
      String? checkError;
      VehicleEntity? existing;
      existingResult.fold((failure) => checkError = failure.message, (v) => existing = v);
      if (checkError != null) {
        isSaving.value = false;
        errorMessage.value = 'No se pudo verificar la placa: $checkError';
        return;
      }

      if (existing != null) {
        if (existing!.customerId == customerId) {
          isSaving.value = false;
          errorMessage.value = 'Este cliente ya tiene registrada la placa $plate.';
          return;
        }

        isSaving.value = false;
        if (!context.mounted) return;
        final ownerResult = await ref.read(customerRepositoryProvider).getById(existing!.customerId);
        final ownerName = ownerResult.fold((failure) => 'otro cliente', (c) => c.fullName);
        if (!context.mounted) return;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface2,
            title: const Text('La placa ya existe'),
            content: Text(
              'La placa $plate ya está registrada a nombre de $ownerName. ¿Transferirla a este cliente en vez de crear una nueva?',
            ),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Transferir', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;

        isSaving.value = true;
        String? actionError;

        final transferResult =
            await repo.transferToCustomer(vehicleId: existing!.id, newCustomerId: customerId);
        transferResult.fold((failure) => actionError = failure.message, (_) {});

        if (actionError == null && !existing!.isActive) {
          final reactivateResult = await repo.toggleActive(id: existing!.id, isActive: true);
          reactivateResult.fold((failure) => actionError = failure.message, (_) {});
        }

        if (actionError == null) {
          final updateResult = await repo.update(
            id: existing!.id,
            vehicleTypeId: vehicleTypeId,
            plate: plate,
            brand: brand,
            model: model,
            color: color,
            year: year,
            notes: notes,
          );
          updateResult.fold((failure) => actionError = failure.message, (_) {});
        }

        isSaving.value = false;
        if (actionError != null) {
          errorMessage.value = actionError;
          return;
        }
        ref.invalidate(vehiclesByCustomerProvider(customerId));
        if (context.mounted) context.pop(existing);
        return;
      }

      final createResult = await repo.create(
        companyId: companyId,
        customerId: customerId,
        vehicleTypeId: vehicleTypeId,
        plate: plate,
        brand: brand,
        model: model,
        color: color,
        year: year,
        notes: notes,
      );
      isSaving.value = false;
      createResult.fold(
        (failure) => errorMessage.value = failure.message,
        (savedVehicle) {
          ref.invalidate(vehiclesByCustomerProvider(customerId));
          if (context.mounted) context.pop(savedVehicle);
        },
      );
    }

    Future<void> deleteVehicle() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('¿Eliminar placa?'),
          content: Text(
            'Se eliminará la placa ${vehicle!.plate}. Si corrige un error de digitación y no tiene servicios registrados, se borra por completo; si ya tiene historial, solo se ocultará.',
          ),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      isSaving.value = true;
      final result = await ref.read(vehicleRepositoryProvider).delete(vehicle!.id);
      isSaving.value = false;
      if (!context.mounted) return;

      ref.invalidate(vehiclesByCustomerProvider(customerId));
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (hardDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hardDeleted
                    ? 'Placa eliminada'
                    : 'Esta placa tiene historial de servicios: se ocultó en lugar de borrarse',
              ),
            ),
          );
          context.pop();
        },
      );
    }

    Future<void> transferVehicle() async {
      final newCustomer = await showModalBottomSheet<CustomerEntity>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface2,
        builder: (context) => _CustomerPickerSheet(excludeCustomerId: customerId),
      );
      if (newCustomer == null || !context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('¿Transferir placa?'),
          content: Text(
            'La placa ${vehicle!.plate} pasará a pertenecer a ${newCustomer.fullName}. El historial de servicios de esta placa no se pierde.',
          ),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Transferir', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      isSaving.value = true;
      final result = await ref.read(vehicleRepositoryProvider).transferToCustomer(
            vehicleId: vehicle!.id,
            newCustomerId: newCustomer.id,
          );
      isSaving.value = false;
      if (!context.mounted) return;

      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) {
          ref.invalidate(vehiclesByCustomerProvider(customerId));
          ref.invalidate(vehiclesByCustomerProvider(newCustomer.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Placa transferida a ${newCustomer.fullName}')),
          );
          context.go(AppRoutes.clienteDetalleFor(newCustomer.id));
        },
      );
    }

    return Scaffold(
      appBar: DetroitAppBar(title: isEditing ? 'Editar vehículo' : 'Nuevo vehículo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
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
                uppercase: true,
                validator: (v) => Validators.validateRequired(v) ?? Validators.validatePlate(v),
              ),
              const SizedBox(height: 16),
              vehicleTypesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                data: (types) {
                  final activeTypes = types.where((t) => t.isActive).toList();
                  return DropdownButtonFormField<String>(
                    initialValue: selectedVehicleTypeId.value,
                    decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
                    dropdownColor: AppColors.surface2,
                    style: AppTextStyles.body1,
                    items: activeTypes
                        .map((type) => DropdownMenuItem(value: type.id, child: Text(type.name)))
                        .toList(),
                    onChanged: (value) => selectedVehicleTypeId.value = value,
                  );
                },
              ),
              const SizedBox(height: 16),
              DetroitTextField(controller: brandController, label: 'Marca (opcional)', uppercase: true),
              const SizedBox(height: 16),
              DetroitTextField(controller: modelController, label: 'Modelo (opcional)', uppercase: true),
              const SizedBox(height: 16),
              DetroitTextField(controller: colorController, label: 'Color (opcional)', uppercase: true),
              const SizedBox(height: 16),
              DetroitTextField(
                controller: yearController,
                label: 'Año (opcional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DetroitTextField(controller: notesController, label: 'Observaciones (opcional)'),
              const SizedBox(height: 32),
              DetroitButton(
                text: isEditing ? 'GUARDAR CAMBIOS' : 'AGREGAR VEHÍCULO',
                isLoading: isSaving.value,
                onPressed: save,
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: isSaving.value ? null : transferVehicle,
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  label: const Text('Transferir a otro cliente', style: TextStyle(color: AppColors.primary)),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: isSaving.value ? null : deleteVehicle,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  label: const Text('Eliminar placa', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja para buscar y elegir el nuevo dueño de una placa (traspaso de
/// vehículo). Devuelve el cliente elegido, o null si se cancela.
class _CustomerPickerSheet extends HookConsumerWidget {
  final String excludeCustomerId;

  const _CustomerPickerSheet({required this.excludeCustomerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState<String?>(null);
    useDebouncedTextListener(searchController, (text) {
      query.value = text.trim().isEmpty ? null : text.trim();
    });

    final customersAsync = ref.watch(customerSearchProvider(query.value));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Transferir a otro cliente', style: AppTextStyles.heading4),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, teléfono o placa',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: customersAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                  data: (customers) {
                    final filtered = customers.where((c) => c.id != excludeCustomerId).toList();
                    if (filtered.isEmpty) {
                      return Text('No se encontraron clientes', style: AppTextStyles.body2);
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            title: Text(c.fullName, style: AppTextStyles.body1),
                            subtitle: Text(c.phone, style: AppTextStyles.body2),
                            onTap: () => context.pop(c),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
