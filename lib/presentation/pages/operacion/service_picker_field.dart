import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/service_entity.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class ServiceSelection {
  final ServiceEntity service;
  final double basePrice;
  final double finalPrice;

  ServiceSelection({required this.service, required this.basePrice, required this.finalPrice});

  double get discountAmount => basePrice - finalPrice;
}

/// Dropdown de servicios (filtrados por tipo de vehículo, con precio ya
/// configurado en Configuración) + precio editable con el sugerido como
/// valor por defecto. Se usa tanto al crear una orden como al agregarle
/// más servicios después.
class ServicePickerField extends HookConsumerWidget {
  final String? vehicleTypeId;
  final ValueChanged<ServiceSelection?> onChanged;

  const ServicePickerField({super.key, required this.vehicleTypeId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServiceId = useState<String?>(null);
    final priceController = useTextEditingController();
    final servicesAsync = ref.watch(servicesProvider);
    final vehicleTypeId = this.vehicleTypeId;

    final availableServices = (servicesAsync.value ?? [])
        .where((s) => s.isActive && vehicleTypeId != null && s.pricesByVehicleType.containsKey(vehicleTypeId))
        .toList();
    final serviceMatches = availableServices.where((s) => s.id == selectedServiceId.value);
    final selectedService = serviceMatches.isEmpty ? null : serviceMatches.first;
    final suggestedPrice =
        selectedService != null && vehicleTypeId != null ? selectedService.priceFor(vehicleTypeId) ?? 0.0 : 0.0;

    void notify() {
      final finalPrice = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (selectedService == null || finalPrice == null || finalPrice <= 0) {
        onChanged(null);
        return;
      }
      onChanged(ServiceSelection(service: selectedService, basePrice: suggestedPrice, finalPrice: finalPrice));
    }

    if (vehicleTypeId == null) {
      return Text(
        'Este vehículo no tiene un tipo asignado, así que no se pueden sugerir servicios.',
        style: AppTextStyles.body2.copyWith(color: AppColors.error),
      );
    }

    return servicesAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Text('Error: $error'),
      data: (_) {
        if (availableServices.isEmpty) {
          return Text(
            'No hay servicios con precio configurado para este tipo de vehículo. Ve a Configuración → Servicios.',
            style: AppTextStyles.body2.copyWith(color: AppColors.error),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
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
                notify();
              },
            ),
            if (selectedService != null) ...[
              const SizedBox(height: 16),
              DetroitTextField(
                controller: priceController,
                label: 'Precio a cobrar (editable)',
                keyboardType: TextInputType.number,
                onChanged: (_) => notify(),
              ),
              const SizedBox(height: 8),
              Text('Precio sugerido: ${CurrencyFormatter.format(suggestedPrice)}', style: AppTextStyles.caption),
            ],
          ],
        );
      },
    );
  }
}
