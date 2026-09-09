import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/customer_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_card.dart';
import '../../widgets/common/detroit_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class BuscarPlacaPage extends HookConsumerWidget {
  const BuscarPlacaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateController = useTextEditingController();
    final searchedPlate = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar por placa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetroitTextField(
              controller: plateController,
              label: 'Placa',
              hint: 'ABC123',
            ),
            const SizedBox(height: 16),
            DetroitButton(
              text: 'BUSCAR',
              onPressed: () => searchedPlate.value = plateController.text.trim().toUpperCase().replaceAll(' ', ''),
            ),
            const SizedBox(height: 24),
            if (searchedPlate.value != null && searchedPlate.value!.isNotEmpty)
              Expanded(child: _VehicleResult(plate: searchedPlate.value!)),
          ],
        ),
      ),
    );
  }
}

class _VehicleResult extends ConsumerWidget {
  final String plate;

  const _VehicleResult({required this.plate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByPlateProvider(plate));

    return vehicleAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      data: (vehicle) {
        if (vehicle == null) {
          return Center(
            child: Text('No se encontró ningún vehículo con placa $plate', style: AppTextStyles.body2),
          );
        }
        final customerAsync = ref.watch(customerByIdProvider(vehicle.customerId));
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetroitCard(
                accentColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.plate, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      [vehicle.brand, vehicle.model, vehicle.color]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' · '),
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              customerAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, stack) => Text('Error: $error', style: const TextStyle(color: AppColors.error)),
                data: (customer) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(AppRoutes.clienteDetalleFor(customer.id)),
                  child: DetroitCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.fullName, style: AppTextStyles.heading4),
                              Text(customer.phone, style: AppTextStyles.body2),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.visitCount} visitas · ${CurrencyFormatter.format(customer.totalSpent)} histórico',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Historial de servicios', style: AppTextStyles.heading4),
              const SizedBox(height: 8),
              Text(
                'Aún no hay servicios registrados. Este módulo se activa en la Fase 4 (Operación de servicios).',
                style: AppTextStyles.body2,
              ),
            ],
          ),
        );
      },
    );
  }
}
