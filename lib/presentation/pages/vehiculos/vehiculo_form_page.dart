import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
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

      final result = isEditing
          ? await repo.update(
              id: vehicle!.id,
              vehicleTypeId: selectedVehicleTypeId.value,
              plate: plate,
              brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
              model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
              color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
              year: year,
              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            )
          : await repo.create(
              companyId: ref.read(authProvider).value!.companyId,
              customerId: customerId,
              vehicleTypeId: selectedVehicleTypeId.value,
              plate: plate,
              brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
              model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
              color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
              year: year,
              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            );

      isSaving.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (savedVehicle) {
          ref.invalidate(vehiclesByCustomerProvider(customerId));
          if (context.mounted) context.pop(savedVehicle);
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
              DetroitTextField(controller: brandController, label: 'Marca (opcional)'),
              const SizedBox(height: 16),
              DetroitTextField(controller: modelController, label: 'Modelo (opcional)'),
              const SizedBox(height: 16),
              DetroitTextField(controller: colorController, label: 'Color (opcional)'),
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
            ],
          ),
        ),
      ),
    );
  }
}
